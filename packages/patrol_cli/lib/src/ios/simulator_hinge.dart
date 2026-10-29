import 'dart:async';
import 'dart:convert' show LineSplitter, Utf8Decoder;
import 'dart:io' show Process;

import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:process/process.dart';

/// Moves the hinge of a booted foldable iOS simulator, such as the iPhone Duo.
///
/// Runs a helper that sends Device Hub's hinge event over private XPC.
class SimulatorHinge {
  SimulatorHinge({
    required String deviceId,
    required ProcessManager processManager,
    required FileSystem fs,
    required Logger logger,
  }) : _deviceId = deviceId,
       _processManager = processManager,
       _fs = fs,
       _logger = logger;

  final String _deviceId;
  final ProcessManager _processManager;
  final FileSystem _fs;
  final Logger _logger;

  Future<_Helper>? _helper;

  /// The last angle set, or null before the first [setAngle].
  double? get angle => _angle;
  double? _angle;

  /// Moves the hinge to [degrees], from 0 (closed) to 180 (fully open).
  Future<void> setAngle(double degrees) async {
    final helper = await (_helper ??= _startHelper());

    _logger.detail('Setting hinge angle of $_deviceId to $degrees°');

    helper.process.stdin.writeln(degrees);
    final replies = helper.replies;
    if (await replies.moveNext()) {
      final reply = replies.current;
      if (reply == 'ok') {
        _angle = degrees;

        return;
      }

      throw SimulatorHingeException(reply);
    }

    final exitCode = await helper.process.exitCode;
    final errors = await helper.errors;
    throw SimulatorHingeException(
      'Hinge helper exited with code $exitCode: $errors',
    );
  }

  Future<_Helper> _startHelper() async {
    final directory = _fs.systemTempDirectory.createTempSync('patrol_hinge');
    try {
      final source = directory.childFile('patrol_hinge.m')
        ..writeAsStringSync(_helperSource);
      final binary = directory.childFile('patrol_hinge').path;

      await _run([
        'xcrun',
        'clang',
        '-fobjc-arc',
        '-framework',
        'Foundation',
        '-o',
        binary,
        source.path,
      ]);
      final developerDir = (await _run([
        'xcode-select',
        '--print-path',
      ])).trim();

      final process = await _processManager.start([
        binary,
        developerDir,
        _deviceId,
      ]);

      return (
        directory: directory,
        process: process,
        replies: StreamIterator(
          process.stdout
              .transform(const Utf8Decoder(allowMalformed: true))
              .transform(const LineSplitter()),
        ),
        errors: process.stderr
            .transform(const Utf8Decoder(allowMalformed: true))
            .join(),
      );
    } on Exception {
      directory.deleteSync(recursive: true);
      rethrow;
    }
  }

  Future<String> _run(List<String> command) async {
    final result = await _processManager.run(command);
    if (result.exitCode != 0) {
      throw SimulatorHingeException(
        '`${command.join(' ')}` failed: ${result.stdErr}',
      );
    }

    return result.stdOut;
  }

  /// Stops the helper. The hinge stays where it is.
  Future<void> close() async {
    final helper = _helper;
    _helper = null;
    try {
      if (await helper case final started?) {
        started.process.kill();
        // macOS kills a running process whose binary is deleted.
        started.directory.deleteSync(recursive: true);
      }
    } on Exception {
      // The helper never started.
    }
  }
}

typedef _Helper = ({
  Directory directory,
  Process process,
  StreamIterator<String> replies,
  Future<String> errors,
});

class SimulatorHingeException implements Exception {
  const SimulatorHingeException(this.message);

  final String message;

  @override
  String toString() => 'SimulatorHingeException: $message';
}

// Reads one angle per stdin line and answers "ok" or "error <reason>".
// Keeps one connection, because dtuhidd drops its HID services on close.
const _helperSource = r'''
// Usage: patrol_hinge <developer-dir> <udid>

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <objc/message.h>
#import <xpc/xpc.h>

extern xpc_endpoint_t xpc_endpoint_create_mach_port_4sim(mach_port_t port);
extern xpc_connection_t xpc_connection_create_from_endpoint(xpc_endpoint_t endpoint);
extern void xpc_connection_enable_sim2host_4sim(xpc_connection_t connection);

static const char *kVendorDefinedService = "com.apple.coredevice.feature.remote.hid.vendordefined";
static const uint64_t kHingeUsagePage = 0xFF61;
static const uint64_t kHingeUsage = 91;

static void fail(NSString *reason) {
  fprintf(stderr, "%s\n", reason.UTF8String);
  exit(1);
}

// The event payload is an IOKit binary-serialized dictionary.
static const uint32_t kSerializeSignature = 0x000000d3;
static const uint32_t kSerializeEnd = 0x80000000;
static const uint32_t kSerializeDictionary = 0x01000000;
static const uint32_t kSerializeNumber = 0x04000000;
static const uint32_t kSerializeSymbol = 0x08000000;
static const uint32_t kSerializeString = 0x09000000;
// Device Hub's size field for a double.
static const uint32_t kSerializeDoubleSize = 0x3f;

static void appendWord(NSMutableData *data, uint32_t word) {
  [data appendBytes:&word length:sizeof(word)];
}

static void appendAligned(NSMutableData *data, const void *bytes, size_t length) {
  [data appendBytes:bytes length:length];
  [data increaseLengthBy:(4 - data.length % 4) % 4];
}

static void appendKey(NSMutableData *data, const char *key) {
  size_t length = strlen(key) + 1;
  appendWord(data, kSerializeSymbol | (uint32_t)length);
  appendAligned(data, key, length);
}

static void appendString(NSMutableData *data, const char *value) {
  size_t length = strlen(value);
  appendWord(data, kSerializeString | (uint32_t)length);
  appendAligned(data, value, length);
}

static void appendLastDouble(NSMutableData *data, double value) {
  appendWord(data, kSerializeNumber | kSerializeDoubleSize | kSerializeEnd);
  appendAligned(data, &value, sizeof(value));
}

static NSData *hingeEventData(double degrees) {
  NSMutableData *data = [NSMutableData data];
  appendWord(data, kSerializeSignature);
  appendWord(data, kSerializeDictionary | kSerializeEnd | 4);
  appendKey(data, "source");
  appendString(data, "hinge-slider-control");
  appendKey(data, "provider");
  appendString(data, "com.apple.Virtualization.VirtualMachines");
  appendKey(data, "type");
  appendString(data, "range");
  appendKey(data, "value");
  appendLastDouble(data, degrees);

  return data;
}

static id findBootedDevice(NSString *developerDir, NSString *udid) {
  if (!dlopen("/Library/Developer/PrivateFrameworks/CoreSimulator.framework/CoreSimulator", RTLD_NOW)) {
    fail([NSString stringWithFormat:@"Could not load CoreSimulator: %s", dlerror()]);
  }

  NSError *error = nil;
  id context = ((id(*)(id, SEL, NSString *, NSError **))objc_msgSend)(
      NSClassFromString(@"SimServiceContext"), NSSelectorFromString(@"sharedServiceContextForDeveloperDir:error:"),
      developerDir, &error);
  id deviceSet =
      ((id(*)(id, SEL, NSError **))objc_msgSend)(context, NSSelectorFromString(@"defaultDeviceSetWithError:"), &error);
  if (!deviceSet) {
    fail([NSString stringWithFormat:@"Could not read simulators: %@", error]);
  }

  for (id device in [deviceSet valueForKey:@"devices"]) {
    NSString *deviceUdid = [[device valueForKey:@"UDID"] UUIDString];
    if ([deviceUdid caseInsensitiveCompare:udid] != NSOrderedSame) {
      continue;
    }

    // SimDeviceStateBooted
    if ([[device valueForKey:@"state"] unsignedLongLongValue] != 3) {
      fail([NSString stringWithFormat:@"Simulator %@ is not booted", udid]);
    }

    return device;
  }

  fail([NSString stringWithFormat:@"No simulator with UDID %@", udid]);
  return nil;
}

static xpc_connection_t connectToVendorDefinedService(id device) {
  NSError *error = nil;
  mach_port_t port = ((mach_port_t(*)(id, SEL, NSString *, NSError **))objc_msgSend)(
      device, NSSelectorFromString(@"lookup:error:"), @(kVendorDefinedService), &error);
  if (port == MACH_PORT_NULL) {
    fail([NSString stringWithFormat:@"Could not look up %s: %@", kVendorDefinedService, error]);
  }

  xpc_connection_t connection = xpc_connection_create_from_endpoint(xpc_endpoint_create_mach_port_4sim(port));
  xpc_connection_enable_sim2host_4sim(connection);
  xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
    if (event == XPC_ERROR_CONNECTION_INVALID) {
      fail(@"Simulator closed the HID connection");
    }
  });
  xpc_connection_resume(connection);

  return connection;
}

static NSString *setHingeAngle(xpc_connection_t connection, double degrees) {
  NSData *eventData = hingeEventData(degrees);
  xpc_object_t payload = xpc_dictionary_create(NULL, NULL, 0);
  xpc_dictionary_set_uint64(payload, "usagePage", kHingeUsagePage);
  xpc_dictionary_set_uint64(payload, "usage", kHingeUsage);
  xpc_dictionary_set_uint64(payload, "version", 0);
  xpc_dictionary_set_data(payload, "data", eventData.bytes, eventData.length);

  xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
  xpc_dictionary_set_string(message, "messageType", "IndigoVendorDefinedEvent");
  xpc_dictionary_set_string(message, "featureIdentifier", kVendorDefinedService);
  xpc_dictionary_set_value(message, "payload", payload);
  xpc_connection_send_message(connection, message);

  // Waits until dtuhidd has dispatched the event.
  xpc_object_t barrier = xpc_dictionary_create(NULL, NULL, 0);
  xpc_dictionary_set_bool(barrier, "isBarrier", true);
  xpc_object_t reply = xpc_connection_send_message_with_reply_sync(connection, barrier);
  if (xpc_get_type(reply) == XPC_TYPE_ERROR) {
    const char *description = xpc_dictionary_get_string(reply, XPC_ERROR_KEY_DESCRIPTION);
    return @(description ?: "unknown XPC error");
  }

  return nil;
}

int main(int argc, const char **argv) {
  @autoreleasepool {
    if (argc != 3) {
      fail(@"Usage: patrol_hinge <developer-dir> <udid>");
    }

    id device = findBootedDevice(@(argv[1]), @(argv[2]));
    xpc_connection_t connection = connectToVendorDefinedService(device);

    char line[64];
    while (fgets(line, sizeof(line), stdin)) {
      char *end = NULL;
      double degrees = strtod(line, &end);
      NSString *error = nil;
      if (end == line || degrees < 0 || degrees > 180) {
        error = @"angle must be a number from 0 to 180";
      } else {
        error = setHingeAngle(connection, degrees);
      }

      if (error) {
        printf("error %s\n", error.UTF8String);
      } else {
        printf("ok\n");
      }
      fflush(stdout);
    }
  }

  return 0;
}
''';
