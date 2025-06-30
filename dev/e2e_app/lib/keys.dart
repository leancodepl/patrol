import 'package:flutter/foundation.dart';

typedef K = Keys;

class Keys {
  const Keys();

  static const topText = Key('topText');
  static const bottomText = Key('bottomText');
  static const backButton = Key('backButton');

  // autofocus text field flow
  static const usernameTextField = Key('usernameTextField');
  static const usernameNextButton = Key('usernameNextButton');
  static const passwordTextField = Key('passwordTextField');
  static const passwordNextButton = Key('passwordNextButton');
  static const welcomeText = Key('welcomeText');

  // main screen
  static const scaffold = Key('scaffold');
  static const listViewKey = Key('listViewKey');
  static const counterText = Key('counterText');
  static const textField = Key('textField');
  static const box1 = Key('box1');
  static const box2 = Key('box2');
  static const tile1 = Key('tile1');
  static const tile2 = Key('tile2');
  static const icon1 = Key('icon1');
  static const icon2 = Key('icon2');
  static const cameraFeaturesButton = Key('cameraFeaturesButton');

  // text fields screen
  static const textField1 = Key('textField1');
  static const textField2 = Key('textField2');
  static const buttonFocus = Key('buttonFocus');
  static const buttonUnfocus = Key('buttonUnfocus');

  // permissions screen
  static const statusText = Key('statusText');
  static const cameraPermissionTile = Key('camera');
  static const microphonePermissionTile = Key('microphone');
  static const locationPermissionTile = Key('location');
  static const galleryPermissionTile = Key('gallery');
  static const permissionsScreen = Key('permissionsScreen');

  // camera screen
  static const cameraScaffold = Key('cameraScaffold');
  static const takePhotoButton = Key('takePhotoButton');
  static const chooseFromGalleryButton = Key('chooseFromGalleryButton');
  static const pickMultiplePhotosButton = Key('pickMultiplePhotosButton');
  static const smallImagePreview = Key('smallImagePreview');
  static const selectedPhotosCount = Key('selectedPhotosCount');
}
