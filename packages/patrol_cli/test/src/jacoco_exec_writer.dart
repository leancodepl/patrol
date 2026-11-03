import 'dart:convert';
import 'dart:typed_data';

/// Mirrors the subset of JaCoCo's binary writer that the splitter reads, so the
/// tests can build realistic `.ec` byte streams (big-endian primitives,
/// Java-style modified UTF-8, CompactDataOutput packed boolean arrays).
class JacocoExecWriter {
  final BytesBuilder _b = BytesBuilder();

  Uint8List toBytes() => _b.toBytes();

  void _u8(int v) => _b.addByte(v & 0xFF);

  void _u16(int v) {
    _b
      ..addByte((v >> 8) & 0xFF)
      ..addByte(v & 0xFF);
  }

  void _i64(int v) {
    final d = ByteData(8)..setInt64(0, v);
    _b.add(d.buffer.asUint8List());
  }

  void _utf(String s) {
    final bytes = utf8.encode(s);
    _u16(bytes.length);
    _b.add(bytes);
  }

  void _varInt(int value) {
    var v = value;
    while ((v & ~0x7F) != 0) {
      _u8((v & 0x7F) | 0x80);
      v >>= 7;
    }
    _u8(v & 0x7F);
  }

  void header() {
    _u8(0x01); // BLOCK_HEADER
    _u16(0xC0C0); // magic
    _u16(0x1007); // version
  }

  void sessionInfo(String id, {int start = 0, int dump = 0}) {
    _u8(0x10); // BLOCK_SESSIONINFO
    _utf(id);
    _i64(start);
    _i64(dump);
  }

  void dartChunk(int seq, int total, String lcov) {
    final b64 = base64.encode(utf8.encode(lcov));
    sessionInfo('PATROL_DART_COV:$seq:$total:$b64');
  }

  void executionData(int classId, String name, int probeCount) {
    _u8(0x11); // BLOCK_EXECUTIONDATA
    _i64(classId);
    _utf(name);
    _varInt(probeCount);
    final byteCount = (probeCount + 7) >> 3;
    _b.add(Uint8List(byteCount)); // packed bits, content irrelevant to reader
  }
}
