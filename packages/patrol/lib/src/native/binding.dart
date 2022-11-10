import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vm_service/vm_service_io.dart' as vmsio;

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

  /// ID of the Isolate which the host driver script is running in.
  ///
  /// Has the form of e.g "isolates/1566121372315359".
  late String driverIsolateId;

  /// Address where the driver VM service lives.
  late String driverVMServiceWsUri;

  // TODO: Remove once https://github.com/flutter/flutter/pull/108430 is
  // available on the stable channel
  @override
  TestBindingEventSource get pointerEventSource => TestBindingEventSource.test;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();

    if (!kReleaseMode) {
      registerServiceExtension(
        name: 'patrol',
        callback: (args) async {
          print('Hello! Service extension called with args $args');
          driverIsolateId = args['DRIVER_ISOLATE_ID']!;
          driverVMServiceWsUri = args['DRIVER_VM_SERVICE_WS_URI']!;

          return <String, String>{'status': 'ok'};
        },
      );
    }
  }

  Future<void> pingDriver() async {
    final vmService = await vmsio.vmServiceConnectUri(driverVMServiceWsUri);

    // Call an extension that is registered in the driver
    await vmService.callServiceExtension(
      'ext.leancode.patrol.hello',
      isolateId: driverIsolateId,
      args: <String, String>{'message': 'Hello from inside of the test!'},
    );
  }

  /// The singleton instance of this object.
  ///
  /// Provides access to the features exposed by this class. The binding must be
  /// initialized before using this getter; this is typically done by calling
  /// [PatrolBinding.ensureInitialized].
  static PatrolBinding get instance => BindingBase.checkInstance(_instance);
  static PatrolBinding? _instance;
}
