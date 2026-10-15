/// Splits [input] into arguments on whitespace.
///
/// Text in single or double quotes is kept together and the quotes are
/// removed, so `--dart-define "MY_VAR=some value"` gives
/// `['--dart-define', 'MY_VAR=some value']`. Backslashes have no special
/// meaning, so Windows paths are kept as they are.
///
/// Throws a [FormatException] if a quote is not closed.
List<String> splitCommandLine(String input) {
  final args = <String>[];
  final current = StringBuffer();
  var inArg = false;
  String? quote;
  var quoteStart = 0;

  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (quote != null) {
      if (char == quote) {
        quote = null;
      } else {
        current.write(char);
      }
    } else if (char == '"' || char == "'") {
      quote = char;
      quoteStart = i;
      inArg = true;
    } else if (char.trim().isEmpty) {
      if (inArg) {
        args.add(current.toString());
        current.clear();
        inArg = false;
      }
    } else {
      current.write(char);
      inArg = true;
    }
  }

  if (quote != null) {
    throw FormatException('Unclosed $quote quote', input, quoteStart);
  }
  if (inArg) {
    args.add(current.toString());
  }
  return args;
}
