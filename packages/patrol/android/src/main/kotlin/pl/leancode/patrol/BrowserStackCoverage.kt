package pl.leancode.patrol

import android.content.Context
import java.io.DataOutputStream
import java.io.File
import java.io.FileOutputStream

/**
 * Bridges Dart coverage (gathered on-device by patrol's Dart side) into the
 * JaCoCo `.ec` file that BrowserStack's coverage pipeline picks up.
 *
 * Strategy: patrol's Dart side writes one or more LCOV-formatted files into
 * `<filesDir>/patrol_coverage/`. After the JaCoCo agent finishes its own dump,
 * we read those files, base64-chunk the bytes to fit the 65535-byte cap on
 * JaCoCo UTF strings, and append a series of `SessionInfo` blocks to the
 * existing `coverage.ec`. The header is left untouched (JaCoCo wrote it).
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
                null,
            )
            return
        }

        val merged = StringBuilder()
        for (file in lcovFiles) {
            merged.append(file.readText())
            if (!merged.endsWith("\n")) merged.append('\n')
        }
        Logger.i("$TAG: t+${android.os.SystemClock.elapsedRealtime() - t0}ms read ${merged.length} chars")

        val payload = merged.toString().toByteArray(Charsets.UTF_8)
        val chunks = chunkBytes(payload, MAX_CHUNK_BYTES)
        Logger.i("$TAG: t+${android.os.SystemClock.elapsedRealtime() - t0}ms chunked ${chunks.size} (${payload.size} bytes)")

        FileOutputStream(coverageFile, /* append = */ true).use { fos ->
            DataOutputStream(fos).use { out ->
                val now = System.currentTimeMillis()
                chunks.forEachIndexed { index, chunk ->
                    val b64 = android.util.Base64.encodeToString(
                        chunk,
                        android.util.Base64.NO_WRAP,
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
