import 'package:example/ui/style/colors.dart';
import 'package:flutter/cupertino.dart';

abstract class PTTextStyles {
  static const _baseStyle = TextStyle(
    color: PTColors.textWhite,
    fontFamily: 'Inter',
    fontStyle: FontStyle.normal,
  );

  static final h1 = _baseStyle.copyWith(
    fontSize: 42,
    height: 1.43,
    fontWeight: FontWeight.w600,
  );
  static final h2 = _baseStyle.copyWith(
    fontSize: 36,
    height: 1.44,
    fontWeight: FontWeight.w600,
  );
  static final h3 = _baseStyle.copyWith(
    fontSize: 24,
    height: 1.50,
    fontWeight: FontWeight.w600,
  );
  static final h4 = _baseStyle.copyWith(
    fontSize: 20,
    height: 1.40,
    fontWeight: FontWeight.w600,
  );
  static final bodyBold = _baseStyle.copyWith(
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static final bodyMedium = _baseStyle.copyWith(
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  static final label = _baseStyle.copyWith(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
  );
}
