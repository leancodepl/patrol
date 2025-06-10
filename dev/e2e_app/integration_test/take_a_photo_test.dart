import 'common.dart';

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
    final nativeTree = await $.native.getNativeViews(null);
    print('PATROL NATIVE TREE:');
    $.log(nativeTree.toString());
    print(nativeTree.map((e) => e.toString()).toList());

    await $.native.takeCameraPhoto();
    await $.pumpAndSettle();
    await $(#smallImagePreview).waitUntilVisible();
  });
}
