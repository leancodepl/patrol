import 'package:http/http.dart' as http;

extension IsOk on http.Response {
  bool get successful {
    return (statusCode ~/ 100) == 2;
  }
}

extension SymbolX on Symbol {
  String get name {
    final symbol = toString();
    return symbol.substring(8, symbol.length - 2);
  }
}
