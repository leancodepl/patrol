extension StopwatchX on Stopwatch {
  String get timeElapsed {
    final elapsedTime = elapsed.inMilliseconds;
    final displayInMilliseconds = elapsedTime < 100;
    final time = displayInMilliseconds ? elapsedTime : elapsedTime / 1000;
    final formatted = displayInMilliseconds
        ? '${time.toString()}ms'
        : '${time.toStringAsFixed(1)}s';

    return formatted;
  }
}
