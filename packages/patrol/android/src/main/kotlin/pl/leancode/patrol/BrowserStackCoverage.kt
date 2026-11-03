package pl.leancode.patrol

import android.app.Instrumentation
import android.content.Context
import android.os.Build
import android.os.ParcelFileDescriptor
import android.os.Process
import android.system.ErrnoException
import android.system.Os
import androidx.test.uiautomator.Configurator
import java.io.DataOutputStream
import java.io.File
import java.io.FileOutputStream

/**
 * Bridges Dart coverage (gathered on-device by patrol's Dart side) into the
 * JaCoCo `.ec` file that BrowserStack's coverage pipeline picks up.
 *
 * Strategy: patrol's Dart side writes one LCOV file per app process into
 * `<filesDir>/patrol_coverage/` (cumulative within a process; a new file when
 * the orchestrator or the app itself restarts the process). After the JaCoCo
 * agent finishes its own dump, we read every file there, merge them into one
 * cumulative LCOV (see [mergeLcov]), base64-chunk the bytes to fit the
 * 65535-byte cap on JaCoCo UTF strings, and append a series of `SessionInfo`
 * blocks to the existing `coverage.ec`. The header is left
 * untouched (JaCoCo wrote it). `<filesDir>` outlives a process restart only
 * without `clearPackageData`; with it, each test appends its own run (see
 * [appendViaShell]).
 *
 * Each appended block uses the id format:
 *   `PATROL_DART_COV:[<runId>:]<sequence>:<total>:<base64_chunk>`
 * which `patrol coverage pull` reassembles on the host side, per `runId`.
 * The runId is only written in shell-append mode, so a single-run file stays
 * readable by `patrol_cli` releases that predate it.
 */
internal object BrowserStackCoverage {
    private const val TAG = "BrowserStackCoverage"

    // JaCoCo binary format constants (see ExecutionDataWriter).
    private const val BLOCK_SESSIONINFO: Byte = 0x10

    // DataOutputStream.writeUTF uses a 2-byte length prefix → max 65535 bytes
    // for the modified-UTF-8 encoding. Base64 expands ~4/3, and we add a
    // ~30-byte id prefix. Chunk raw payload to keep encoded length comfortably
    // below the limit: 48_000 raw bytes → ~64_000 b64 chars + prefix.
    private const val MAX_CHUNK_BYTES = 48_000

    const val ID_PREFIX = "PATROL_DART_COV:"

    // Read by bs_coverage.dart; set in the app process before Flutter starts.
    const val DART_COVERAGE_DIR_ENV = "PATROL_COVERAGE_DIR"

    fun dartCoverageDir(context: Context): File = File(context.filesDir, "patrol_coverage")

    /** Tells the Dart side, via the process environment, where to write LCOV. */
    fun exportDartCoverageDir(context: Context) {
        val dir = dartCoverageDir(context)
        try {
            Os.setenv(DART_COVERAGE_DIR_ENV, dir.absolutePath, true)
            Logger.i("$TAG: Dart coverage dir -> ${dir.absolutePath}")
        } catch (e: ErrnoException) {
            Logger.e("$TAG: could not export $DART_COVERAGE_DIR_ENV", e)
        }
    }

    /**
     * Reads any LCOV files in `<filesDir>/patrol_coverage/`, encodes them, and
     * appends JaCoCo session blocks to [coverageFile]. Safe to call even when
     * no Dart coverage was produced. [runId] tags the chunks when one file
     * holds several runs; no ':' allowed, the host splits the id on it.
     */
    fun appendDartCoverage(context: Context, coverageFile: File, runId: String?) {
        val t0 = android.os.SystemClock.elapsedRealtime()
        val sourceDir = dartCoverageDir(context)
        if (!sourceDir.exists() || !sourceDir.isDirectory) {
            Logger.i("$TAG: no patrol_coverage dir at ${sourceDir.absolutePath}, skipping")
            return
        }

        val lcovFiles = sourceDir.listFiles { f -> f.isFile && f.length() > 0 }
            ?.sortedBy { it.name }
            ?: emptyList()
        if (lcovFiles.isEmpty()) {
            Logger.i("$TAG: no Dart coverage files to merge, skipping")
            return
        }
        Logger.i("$TAG: t+${android.os.SystemClock.elapsedRealtime() - t0}ms list ${lcovFiles.size} file(s)")

        if (!coverageFile.exists() || coverageFile.length() == 0L) {
            // Without a JaCoCo header the file is unreadable. Patrol can't write
            // a header itself (would require duplicating JaCoCo's magic + version).
            // In practice this only happens when testCoverageEnabled is off — log
            // and bail loudly so the misconfig is obvious.
            Logger.e(
                "$TAG: ${coverageFile.absolutePath} is missing or empty. Is testCoverageEnabled=true on the app under test?",
                null
            )
            return
        }

        val sources = lcovFiles.map { it.readText() }
        val rawChars = sources.sumOf { it.length }
        val merged = mergeLcov(sources)
        Logger.i(
            "$TAG: t+${android.os.SystemClock.elapsedRealtime() - t0}ms " +
                "read $rawChars chars, merged to ${merged.length}"
        )

        val payload = merged.toByteArray(Charsets.UTF_8)
        val chunks = chunkBytes(payload, MAX_CHUNK_BYTES)
        Logger.i("$TAG: t+${android.os.SystemClock.elapsedRealtime() - t0}ms chunked ${chunks.size} (${payload.size} bytes)")

        FileOutputStream(coverageFile, /* append = */ true).use { fos ->
            DataOutputStream(fos).use { out ->
                val now = System.currentTimeMillis()
                val run = if (runId == null) "" else "$runId:"
                chunks.forEachIndexed { index, chunk ->
                    val b64 = android.util.Base64.encodeToString(
                        chunk,
                        android.util.Base64.NO_WRAP
                    )
                    val id = "$ID_PREFIX$run${index + 1}:${chunks.size}:$b64"
                    out.writeByte(BLOCK_SESSIONINFO.toInt())
                    out.writeUTF(id)
                    out.writeLong(now)
                    out.writeLong(now)
                }
                out.flush()
                fos.fd.sync()
            }
        }
        Logger.i("$TAG: t+${android.os.SystemClock.elapsedRealtime() - t0}ms append complete, file now ${coverageFile.length()} bytes")
    }

    /** Deletes LCOV already handed off, so the next append in this process doesn't repeat it. */
    fun clearDartCoverage(context: Context) {
        dartCoverageDir(context).listFiles()?.forEach { it.delete() }
    }

    /** Whether [appendViaShell] can run here (`executeShellCommandRw` is API 31+). */
    fun canAppendViaShell(): Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S

    /** A run id unique per append: wall clock plus this process's pid. */
    fun newRunId(): String = "${System.currentTimeMillis()}-${Process.myPid()}"

    /**
     * Appends [bytes] to [path] as the `shell` user. Unlike the app, `shell`
     * can still write a shared-storage file that `pm clear` orphaned, so every
     * test under `clearPackageData` adds its own block instead of hitting EACCES.
     * Throws when the append can't be confirmed, so the caller keeps its data.
     */
    fun appendViaShell(instrumentation: Instrumentation, path: String, bytes: ByteArray) {
        // Commands are split on whitespace, and `path` lands inside sh quotes.
        require(path.none { it.isWhitespace() || it == '\'' }) { "unsupported coverage path: $path" }
        val automation = instrumentation.getUiAutomation(Configurator.getInstance().uiAutomationFlags)
        File(path).parent?.let { runShell(automation, "mkdir -p $it") }

        // Stream into a side file first: if this process dies mid-write, only
        // that file is torn, never the coverage file every earlier test is in.
        val part = "$path.patrol-part"
        val fds = automation.executeShellCommandRw("sh -c cat>'$part'")
        ParcelFileDescriptor.AutoCloseInputStream(fds[0]).use { stdout ->
            ParcelFileDescriptor.AutoCloseOutputStream(fds[1]).use { it.write(bytes) }
            // stdout hits EOF once `cat` exits, i.e. after the write landed.
            stdout.readBytes()
        }
        val staged = fileSize(automation, part)
        check(staged == bytes.size.toLong()) { "staged $staged of ${bytes.size} bytes in $part" }

        val before = fileSize(automation, path)
        runShell(automation, "sh -c cat<'$part'>>'$path'")
        val after = fileSize(automation, path)
        runShell(automation, "rm -f $part")
        check(after - before == bytes.size.toLong()) { "shell append to $path failed ($before -> $after)" }
        Logger.i("$TAG: shell-appended ${bytes.size} bytes to $path ($before -> $after)")
    }

    /** Size of [path] as the shell user sees it, 0 when missing. */
    private fun fileSize(automation: android.app.UiAutomation, path: String): Long =
        runShell(automation, "stat -c %s $path").trim().toLongOrNull() ?: 0L

    private fun runShell(automation: android.app.UiAutomation, command: String): String =
        ParcelFileDescriptor.AutoCloseInputStream(automation.executeShellCommand(command))
            .use { it.readBytes().toString(Charsets.UTF_8) }

    private fun chunkBytes(bytes: ByteArray, chunkSize: Int): List<ByteArray> {
        if (bytes.isEmpty()) return emptyList()
        val out = ArrayList<ByteArray>((bytes.size + chunkSize - 1) / chunkSize)
        var offset = 0
        while (offset < bytes.size) {
            val end = minOf(offset + chunkSize, bytes.size)
            out += bytes.copyOfRange(offset, end)
            offset = end
        }
        return out
    }
}

/**
 * Merges LCOV records from several sources into one, keeping the highest hit
 * count seen for each line. Mirrors `mergeLcovRecords` on the
 * `patrol coverage pull` side.
 *
 * Under the Android test orchestrator each test runs in a fresh process and
 * leaves its own LCOV file behind. Concatenating them would re-embed every
 * earlier snapshot on every dump, so the payload grew with the test count -
 * hundreds of MB by the end of a large suite, and a write window long enough
 * to be killed mid-append. Merging keeps it the size of one cumulative
 * snapshot no matter how many tests ran.
 */
internal fun mergeLcov(sources: List<String>): String {
    val byFile = LinkedHashMap<String, LinkedHashMap<Int, Int>>()
    var current: LinkedHashMap<Int, Int>? = null

    for (source in sources) {
        for (rawLine in source.lineSequence()) {
            val line = rawLine.trimEnd()
            when {
                line.startsWith("SF:") -> current = byFile.getOrPut(line.substring(3)) { LinkedHashMap() }
                line == "end_of_record" -> current = null
                line.startsWith("DA:") -> {
                    val target = current ?: continue
                    val rest = line.substring(3)
                    val comma = rest.indexOf(',')
                    if (comma < 0) continue
                    val lineNo = rest.substring(0, comma).toIntOrNull() ?: continue
                    val count = rest.substring(comma + 1).toIntOrNull() ?: continue
                    val existing = target[lineNo]
                    if (existing == null || count > existing) {
                        target[lineNo] = count
                    }
                }
            }
        }
    }

    val out = StringBuilder()
    for ((file, lines) in byFile) {
        out.append("SF:").append(file).append('\n')
        var hit = 0
        for (lineNo in lines.keys.sorted()) {
            val count = lines.getValue(lineNo)
            out.append("DA:").append(lineNo).append(',').append(count).append('\n')
            if (count > 0) hit++
        }
        out.append("LF:").append(lines.size).append('\n')
        out.append("LH:").append(hit).append('\n')
        out.append("end_of_record").append('\n')
    }
    return out.toString()
}
