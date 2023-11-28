import 'package:example/pages/quiz/form_page.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/images.dart';
import 'package:example/ui/style/colors.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:example/ui/widgets/logos_hero.dart';
import 'package:example/ui/widgets/utils.dart';
import 'package:flutter/material.dart';

Route<void> get quizWelcomeRoute =>
    MaterialPageRoute(builder: (_) => const _WelcomePage());

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 76),
          const LogoHero(),
          const Spacer(),
          Text.rich(
            TextSpan(
              style: PTTextStyles.h2.copyWith(color: PTColors.textWhite),
              children: <InlineSpan>[
                const TextSpan(text: 'Welcome to Patrol Testing Quiz for'),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 10, 10, 5),
                    child: PTImages.flutterconLogo,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PTElevatedButton(
            caption: 'Start',
            onPressed: () => Navigator.push(context, formRoute),
          ),
          const SizedBox(height: 40),
        ],
      ).horizontallyPadded24,
    );
  }
}
