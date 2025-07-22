extension DurationExtension on Duration {
  String toFormattedString() {
    final hours = inHours;
    final minutes = inMinutes % 60;
    final seconds = inSeconds % 60;

    final buffer = StringBuffer();
    if (hours > 0) {
      buffer.write('${hours}h ');
    }
    if (minutes > 0 || hours > 0) {
      buffer.write('${minutes}m ');
    }
    buffer.write('${seconds}s');

    return buffer.toString();
  }
}
