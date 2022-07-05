import 'package:http/http.dart' as http;

/// Provides a method to easily check the meaning of the HTTP status code.
extension IsResponseSuccessul on http.Response {
  /// Returns true if the status code is 2xx, false otherwise.
  bool get successful {
    return (statusCode ~/ 100) == 2;
  }
}

/// Makes it possible to retrieve a name that this [Symbol] was created with.
extension SymbolName on Symbol {
  /// Returns the name that this [Symbol] was created with.
  ///
  /// It's kinda hacky, but works well. Might require adjustements to work on
  /// the web though.
  String get name {
    final symbol = toString();
    return symbol.substring(8, symbol.length - 2);
  }
}
