import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Binding that enables some of Maestro's custom functionality, such as tapping
/// on WebViews during a test.
class MaestroBinding extends IntegrationTestWidgetsFlutterBinding {
  /// Default constructor that only calls the superclass constructor.
  MaestroBinding() : super();

  // Remove once https://github.com/flutter/flutter/pull/108430 is merged
  @override
  TestBindingEventSource get pointerEventSource => TestBindingEventSource.test;

  // @override
  // LiveTestWidgetsFlutterBindingFramePolicy get framePolicy =>
  //     LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  /// The singleton instance of this object.
  ///
  /// Provides access to the features exposed by this class. The binding must
  /// be initialized before using this getter; this is typically done by calling
  /// [MaestroBinding.ensureInitialized].
  static MaestroBinding get instance => BindingBase.checkInstance(_instance);
  static MaestroBinding? _instance;

  /// Returns an instance of the [MaestroBinding], creating and
  /// initializing it if necessary.
  static MaestroBinding ensureInitialized() {
    if (_instance == null) {
      MaestroBinding();
    }
    return _instance!;
  }
}
