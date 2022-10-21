import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Binding that enables some of Patrol's custom functionality, such as tapping
/// on WebViews during a test.
class PatrolBinding extends IntegrationTestWidgetsFlutterBinding {
  /// Default constructor that only calls the superclass constructor.
  PatrolBinding() : super();

  /// Returns an instance of the [PatrolBinding], creating and initializing it
  /// if necessary.
  factory PatrolBinding.ensureInitialized() {
    if (_instance == null) {
      PatrolBinding();
    }
    return _instance!;
  }

  // TODO: Remove once https://github.com/flutter/flutter/pull/108430 is
  // available on the stable channel
  @override
  TestBindingEventSource get pointerEventSource => TestBindingEventSource.test;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  /// The singleton instance of this object.
  ///
  /// Provides access to the features exposed by this class. The binding must be
  /// initialized before using this getter; this is typically done by calling
  /// [PatrolBinding.ensureInitialized].
  static PatrolBinding get instance => BindingBase.checkInstance(_instance);
  static PatrolBinding? _instance;
}
