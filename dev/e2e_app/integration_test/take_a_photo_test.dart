import 'common.dart';

void main() {
  patrol('take a photo', ($) async {
    await createApp($);

    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#takePhotoButton).tap();
    await $.native.grantPermissionWhenInUse();

    await $.native.takeCameraPhoto();
    await $.pumpAndSettle();
    await $(#smallImagePreview).waitUntilVisible();
  });
}
