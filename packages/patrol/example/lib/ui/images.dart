import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class PTImages {
  static final patrolLogo = SvgPicture.asset('assets/image/patrol_logo.svg');
  static final flutterconLogo = SvgPicture.asset(
    'assets/image/fluttercon_logo.svg',
    placeholderBuilder: (_) => const SizedBox(height: 26, width: 166),
  );
  static final leancodeLogo = SvgPicture.asset(
    'assets/image/leancode_logo.svg',
  );
  static final confetti = SvgPicture.asset(
    'assets/image/confetti.svg',
    fit: BoxFit.cover,
  );
}
