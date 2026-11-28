/// Splits [input] into arguments on whitespace.
///
/// Text in single or double quotes is kept together and the quotes are
/// removed, so `--dart-define "MY_VAR=some value"` gives
/// `['--dart-define', 'MY_VAR=some value']`. A quote without a closing pair,
/// like the one in `/Users/o'brien/flutter`, is kept as a normal character.
/// Backslashes have no special meaning, so Windows paths are kept as they are.
List<String> splitCommandLine(String input) {
  final args = <String>[];
  final current = StringBuffer();
  var inArg = false;
  String? quote;

  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (quote != null) {
      if (char == quote) {
        quote = null;
      } else {
        current.write(char);
      }
    } else if ((char == '"' || char == "'") &&
        input.indexOf(char, i + 1) != -1) {
      quote = char;
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

  if (inArg) {
    args.add(current.toString());
  }
  return args;
}

/// Joins [args] into a line [splitCommandLine] splits back into [args].
///
/// An argument holding whitespace or a quote is wrapped in the quote it does
/// not contain; one holding both kinds of quote cannot be joined that way.
String joinCommandLine(List<String> args) => [
  for (final arg in args)
    if (!arg.contains(RegExp('[\\s"\']')) && arg.isNotEmpty)
      arg
    else if (arg.contains('"'))
      "'$arg'"
    else
      '"$arg"',
].join(' ');
