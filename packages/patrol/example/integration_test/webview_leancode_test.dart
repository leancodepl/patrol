import 'common.dart';

void main() {
  patrol('interacts with the LeanCode website in a webview', ($) async {
    await createApp($);

    await $('Open webview (LeanCode)').scrollTo().tap();

    try {
      await $.native.tap(Selector(text: 'Accept cookies'));
    } on PatrolActionException catch (_) {
      // ignore
    }

    await $.native.tap(Selector(text: 'What do you do in IT?', instance: 1));
    await $.native.tap(Selector(text: 'Developer'));
    // TODO: This doesn't work for unknown reason.
    // await $.native.enterTextByIndex('test@leancode.pl', index: 0);
  });
}
