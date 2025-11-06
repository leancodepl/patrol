import 'package:patrol/src/platform/android/contracts/contracts.dart'
    as android_contracts;
import 'package:patrol/src/platform/ios/contracts/contracts.dart'
    as ios_contracts;

class Selector {
  Selector({required this.android, required this.ios});

  final android_contracts.Selector android;
  final ios_contracts.Selector ios;
}
