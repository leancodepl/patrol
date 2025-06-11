import 'common.dart';

void main() {
  patrol('pick photo from gallery', ($) async {
    await createApp($);

    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#chooseFromGalleryButton).tap();
    if (await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native2.grantPermissionWhenInUse();
    }
    await $.native2.pickPhotoFromGallery();
    await $.pumpAndSettle();

    await $(#smallImagePreview).waitUntilVisible();
  });
}
