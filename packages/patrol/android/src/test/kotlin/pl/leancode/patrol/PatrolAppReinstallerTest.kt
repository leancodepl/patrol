package pl.leancode.patrol

import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class PatrolAppReinstallerTest {
    private class FakeShell(
        private val pmPath: String = "package:/data/app/~~a==/com.example-b==/base.apk\n",
        /** Bytes that `cp` writes, or null for a full copy. */
        private val copiedBytes: Long? = null,
        /** Whether `stat` is available, as on API 23 and newer. */
        private val hasStat: Boolean = true,
        private val commitOutputs: List<String> = listOf("Success\n"),
    ) {
        val commands = mutableListOf<String>()
        private val files = mutableMapOf<String, Long>()
        private var commits = 0

        init {
            PatrolAppReinstaller.parseApkPaths(pmPath).forEach { files[it] = APK_SIZE }
        }

        fun run(command: String): String {
            commands.add(command)
            val args = command.split(" ")
            return when {
                command.startsWith("pm path ") -> pmPath
                command.startsWith("cp ") -> {
                    files[args[2]] = copiedBytes ?: files.getValue(args[1])
                    ""
                }
                command.startsWith("stat ") ->
                    if (hasStat) files[args.last()]?.toString() ?: "" else "stat: not found"
                command.startsWith("ls ") ->
                    files.keys.filter { it.startsWith(args[1]) }
                        .joinToString("\n") { it.substringAfterLast('/') }
                command.startsWith("pm uninstall ") -> "Success\n"
                command.startsWith("pm install-create") -> "Success: created install session [1234]\n"
                command.startsWith("pm install-write ") -> "Success: streamed 100 bytes\n"
                command.startsWith("pm install-commit ") ->
                    commitOutputs[minOf(commits++, commitOutputs.size - 1)]
                else -> ""
            }
        }

        companion object {
            const val APK_SIZE = 1000L
        }
    }

    @Test
    fun `reinstalls the base APK and its splits in one session`() {
        val shell = FakeShell(
            pmPath = """
                package:/data/app/~~a==/com.example-b==/base.apk
                package:/data/app/~~a==/com.example-b==/split_config.arm64_v8a.apk
            """.trimIndent(),
        )

        PatrolAppReinstaller(shell::run).reinstall("com.example")

        val uninstall = shell.commands.indexOf("pm uninstall com.example")
        val lastCopy = shell.commands.indexOfLast { it.startsWith("cp ") }
        assertTrue(lastCopy in 0 until uninstall, "copies the APKs before uninstalling")
        assertEquals(
            listOf(
                "pm install-create -t",
                "pm install-write 1234 0 /data/local/tmp/patrol_reinstall/0.apk",
                "pm install-write 1234 1 /data/local/tmp/patrol_reinstall/1.apk",
                "pm install-commit 1234",
                "rm -rf /data/local/tmp/patrol_reinstall",
            ),
            shell.commands.subList(uninstall + 1, shell.commands.size),
        )
    }

    @Test
    fun `passes the user to every pm command that takes one`() {
        val shell = FakeShell()

        PatrolAppReinstaller(shell::run, user = "current").reinstall("com.example")

        assertTrue("pm path --user current com.example" in shell.commands)
        assertTrue("pm uninstall --user current com.example" in shell.commands)
        assertTrue("pm install-create --user current -t" in shell.commands)
    }

    @Test
    fun `keeps the app installed when a copy is truncated`() {
        val shell = FakeShell(copiedBytes = 10)

        assertFailsWith<IllegalStateException> {
            PatrolAppReinstaller(shell::run).reinstall("com.example")
        }
        assertFalse(shell.commands.any { it.startsWith("pm uninstall") })
    }

    @Test
    fun `checks only that the copy exists when stat is missing`() {
        val shell = FakeShell(hasStat = false)

        PatrolAppReinstaller(shell::run).reinstall("com.example")

        assertTrue("pm install-commit 1234" in shell.commands)
    }

    @Test
    fun `fails when the app is not installed`() {
        val shell = FakeShell(pmPath = "")

        assertFailsWith<IllegalStateException> {
            PatrolAppReinstaller(shell::run).reinstall("com.example")
        }
        assertFalse(shell.commands.any { it.startsWith("pm uninstall") })
    }

    @Test
    fun `retries a failed install`() {
        val shell = FakeShell(
            commitOutputs = listOf("Failure [INSTALL_FAILED_INTERNAL_ERROR]\n", "Success\n"),
        )

        PatrolAppReinstaller(shell::run).reinstall("com.example")

        assertEquals(2, shell.commands.count { it.startsWith("pm install-commit") })
        assertTrue("pm install-abandon 1234" in shell.commands)
    }

    @Test
    fun `keeps the copies when the app cannot be installed again`() {
        val shell = FakeShell(commitOutputs = listOf("Failure [INSTALL_FAILED_INVALID_APK]\n"))

        val error = assertFailsWith<IllegalStateException> {
            PatrolAppReinstaller(shell::run).reinstall("com.example")
        }
        assertTrue(error.message!!.contains("/data/local/tmp/patrol_reinstall/0.apk"))
        assertTrue(error.cause!!.message!!.contains("INSTALL_FAILED_INVALID_APK"))
        val uninstall = shell.commands.indexOf("pm uninstall com.example")
        assertFalse(shell.commands.drop(uninstall).any { it.startsWith("rm ") })
    }

    @Test
    fun `rejects an invalid package name`() {
        assertFailsWith<IllegalArgumentException> {
            PatrolAppReinstaller(FakeShell()::run).reinstall("com.example; reboot")
        }
    }
}
