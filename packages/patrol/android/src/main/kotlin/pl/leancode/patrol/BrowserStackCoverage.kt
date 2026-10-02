package pl.leancode.patrol

import android.content.Context
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
 * without `clearPackageData`, which coverage runs require anyway.
 *
 * Each appended block uses the id format:
 *   `PATROL_DART_COV:<sequence>:<total>:<base64_chunk>`
 * which `patrol bs pull-coverage` reassembles on the host side.
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

    /**
     * Reads any LCOV files in `<filesDir>/patrol_coverage/`, encodes them, and
     * appends JaCoCo session blocks to [coverageFile]. Safe to call even when
     * no Dart coverage was produced.
     */
    fun appendDartCoverage(context: Context, coverageFile: File) {
        val t0 = android.os.SystemClock.elapsedRealtime()
        val sourceDir = File(context.filesDir, "patrol_coverage")
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
                chunks.forEachIndexed { index, chunk ->
                    val b64 = android.util.Base64.encodeToString(
                        chunk,
                        android.util.Base64.NO_WRAP
                    )
                    val id = "$ID_PREFIX${index + 1}:${chunks.size}:$b64"
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
 * `patrol bs pull-coverage` side.
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
