import '../common.dart';

void main() {
  patrol('take a photo', ($) async {
    await createApp($);
    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#takePhotoButton).tap();
    if (await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native2.grantPermissionWhenInUse();
    }
    try {
      await $.native.tap(Selector(text: 'NEXT'));
    } on Exception {/* ignore */}

    await $.native2.takeCameraPhoto();
    await $.pumpAndSettle();
    await $(#smallImagePreview).waitUntilVisible();
  });
}
