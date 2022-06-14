import 'package:http/http.dart' as http;

extension IsOk on http.Response {
  bool get successful {
    return (statusCode ~/ 100) == 2;
  }
}
