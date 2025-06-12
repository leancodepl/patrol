import 'common.dart';

void main() {
  patrol('pick image from gallery', ($) async {
    await createApp($);

    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#chooseFromGalleryButton).tap();
    if (await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native2.grantPermissionWhenInUse();
    }
    await $.native2.pickImageFromGallery();
    await $.pumpAndSettle();

    await $(#smallImagePreview).waitUntilVisible();
  });
}
