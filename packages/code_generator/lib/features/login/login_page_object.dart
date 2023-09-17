import 'package:code_generator/annotations.dart';
import 'package:flutter/widgets.dart';

part 'login_page_object.keys.dart';

@GenerateKeys()
@GenerateObjectModel()
final class LoginPageObject<LoginPage> {
  late Key loginButton;
  late Key emailField;
  late Key emailBox;
}
