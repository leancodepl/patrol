import 'common.dart';

void main() {
  // Description built from a build-time variable.
  const env = String.fromEnvironment('TARGET_ENV', defaultValue: 'staging');
  patrol('runs against $env environment', ($) async {
    await createApp($);
  });

  // A description computed from a local variable.
  final featureName = ['login', 'checkout'].join('+');
  patrol('feature flow: $featureName', ($) async {
    await createApp($);
  });

  // Tests generated in a loop over a list.
  for (final tab in ['home', 'profile', 'settings']) {
    patrol('navigates to "$tab" tab', ($) async {
      await createApp($);
    });
  }

  // Tests generated in a counting loop.
  for (var i = 1; i <= 3; i++) {
    patrol('retry attempt #$i succeeds', ($) async {
      await createApp($);
    });
  }
}
