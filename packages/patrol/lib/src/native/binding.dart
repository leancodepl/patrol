import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vm_service/vm_service.dart' as vm;

// ignore: avoid_print
void _defaultPrintLogger(String message) => print('PatrolBinding: $message');

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

  final _logger = _defaultPrintLogger;

  /// ID of the Isolate which the host driver script is running in.
  ///
  /// Has the form of e.g "isolates/1566121372315359".
  late String driverIsolateId;

  /// Dart VM service (aka Dart Observatory server) running in the main isolate
  /// of the Dart VM which is running the test driver script.
  late vm.VmService vmService;

  // TODO: Remove once https://github.com/flutter/flutter/pull/108430 is
  // available on the stable channel
  @override
  TestBindingEventSource get pointerEventSource => TestBindingEventSource.test;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;

    if (!extensionStreamHasListener) {
      _logger("Extension stream has no listeners, so host features won't work");
    }
  }

  /// Takes a screenshot using the `flutter screenshot` command.
  ///
  /// The screenshot is placed in [path], named [name], and has .png extension.
  Future<void> takeFlutterScreenshot({
    required String name,
    required String path,
  }) async {
    postEvent('patrol', <String, dynamic>{
      'method': 'take_screenshot',
      'args': {'name': name, 'path': path}
    });
  }

  /// The singleton instance of this object.
  ///
  /// Provides access to the features exposed by this class. The binding must be
  /// initialized before using this getter; this is typically done by calling
  /// [PatrolBinding.ensureInitialized].
  static PatrolBinding get instance => BindingBase.checkInstance(_instance);
  static PatrolBinding? _instance;
}
