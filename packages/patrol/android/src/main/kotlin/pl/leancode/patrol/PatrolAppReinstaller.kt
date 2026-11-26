package pl.leancode.patrol

/**
 * Uninstalls the app under test and installs the same APKs again.
 *
 * The runner has no APK of the app, so it copies the installed ones aside before it uninstalls
 * the app. This works only when the runner lives outside the app, in the self-instrumenting
 * test APK: uninstalling the app would otherwise kill the runner too.
 *
 * @param shell runs a command as the shell user and returns its standard output.
 * @param user the `--user` argument for `pm`, e.g. `current`, or null to let `pm` pick all users.
 */
class PatrolAppReinstaller(
    private val shell: (String) -> String,
    private val user: String? = null,
) {
    fun reinstall(appId: String) {
        require(appId.matches(PACKAGE_NAME)) { "Invalid Android package name: $appId" }

        val installed = parseApkPaths(shell("pm path ${userOption()}$appId"))
        check(installed.isNotEmpty()) { "Cannot reinstall $appId, because it is not installed" }

        shell("rm -rf $STAGING_DIR")
        shell("mkdir -p $STAGING_DIR")
        val staged = try {
            stage(appId, installed)
        } catch (e: Exception) {
            shell("rm -rf $STAGING_DIR")
            throw e
        }

        expectSuccess("pm uninstall ${userOption()}$appId")

        // From here on the copies are the only way to get the app back, so they stay on the
        // device until it is installed again.
        var failure: Exception? = null
        repeat(INSTALL_ATTEMPTS) {
            try {
                install(staged)
                shell("rm -rf $STAGING_DIR")
                return
            } catch (e: Exception) {
                failure = e
            }
        }
        throw IllegalStateException(
            "Uninstalled $appId but could not install it again. Its APKs are kept in " +
                "$STAGING_DIR: ${staged.joinToString(" ")}",
            failure,
        )
    }

    /** Copies [installed] to the staging directory and checks that every copy is complete. */
    private fun stage(appId: String, installed: List<String>): List<String> {
        return installed.mapIndexed { index, apk ->
            val copy = "$STAGING_DIR/$index.apk"
            shell("cp $apk $copy")
            // `executeShellCommand` returns neither stderr nor the exit code, so a failed or
            // truncated copy shows up only in its size.
            val expected = sizeOf(apk)
            val actual = sizeOf(copy)
            val complete = if (expected != null) actual == expected else copyExists(copy)
            check(complete) {
                "Cannot reinstall $appId, because copying $apk failed " +
                    "($actual of $expected bytes)"
            }
            copy
        }
    }

    /** The size of [path] in bytes, or null if `stat` is not available (API 22 and older). */
    private fun sizeOf(path: String): Long? {
        return shell("stat -c %s $path").trim().toLongOrNull()
    }

    private fun copyExists(path: String): Boolean {
        return shell("ls $STAGING_DIR").split(Regex("\\s+")).contains(path.substringAfterLast('/'))
    }

    /**
     * Installs [apks] as one package. A session takes split APKs too, and `pm` supports it on
     * every API level Patrol supports.
     */
    private fun install(apks: List<String>) {
        val created = expectSuccess("pm install-create ${userOption()}-t")
        val sessionId = SESSION_ID.find(created)?.groupValues?.get(1)
            ?: throw IllegalStateException("Unexpected output of pm install-create: $created")
        try {
            apks.forEachIndexed { index, apk ->
                expectSuccess("pm install-write $sessionId $index $apk")
            }
            expectSuccess("pm install-commit $sessionId")
        } catch (e: Exception) {
            shell("pm install-abandon $sessionId")
            throw e
        }
    }

    private fun userOption(): String = if (user == null) "" else "--user $user "

    private fun expectSuccess(command: String): String {
        val output = shell(command)
        check(output.contains("Success")) { "$command failed: ${output.trim()}" }
        return output
    }

    companion object {
        private const val STAGING_DIR = "/data/local/tmp/patrol_reinstall"
        private const val INSTALL_ATTEMPTS = 2
        private val PACKAGE_NAME = Regex("[A-Za-z0-9._]+")
        private val SESSION_ID = Regex("\\[(\\d+)]")

        /** Returns the APK paths listed by `pm path`, base APK first. */
        @JvmStatic
        fun parseApkPaths(output: String): List<String> {
            return output.lines()
                .map { it.trim() }
                .filter { it.startsWith("package:") }
                .map { it.removePrefix("package:") }
                .filter { it.isNotEmpty() }
        }
    }
}
