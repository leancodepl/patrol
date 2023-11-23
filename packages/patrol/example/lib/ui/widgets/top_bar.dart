import 'package:flutter/widgets.dart';
import 'package:patrol_challenge/ui/style/colors.dart';
import 'package:patrol_challenge/ui/widgets/logos_hero.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PTColors.backgroundGrey,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).viewPadding.top),
          const SizedBox(
            height: 56,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: LogoHero(),
            ),
          ),
        ],
      ),
    );
  }
}
