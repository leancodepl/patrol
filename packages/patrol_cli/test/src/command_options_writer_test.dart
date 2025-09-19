import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/command_options_writer.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  group('CommandOptionsWriter', () {
    late FileSystem fs;
    late Directory projectRoot;
    late CommandOptionsWriter writer;
    late MockLogger mockLogger;

    setUp(() {
      fs = MemoryFileSystem.test();
      projectRoot = fs.directory('/project')..createSync();
      mockLogger = MockLogger();
      writer = CommandOptionsWriter(
        fileSystem: fs,
        projectRoot: projectRoot,
        logger: mockLogger,
      );
    });

    test('writeCommandOptions creates integration_test directory if it does not exist', () async {
      // Arrange
      final commandData = CommandOptionsData(
        command: 'build',
        platform: 'android',
        buildMode: 'debug',
        device: 'emulator-5554',
      );

      // Act
      await writer.writeCommandOptions(commandData);

      // Assert
      expect(projectRoot.childDirectory('integration_test').existsSync(), isTrue);
    });

    test('writeCommandOptions creates patrol_options.json with correct content', () async {
      // Arrange
      final commandData = CommandOptionsData(
        command: 'build',
        platform: 'android',
        buildMode: 'debug',
        device: 'emulator-5554',
        targets: ['integration_test/app_test.dart'],
        flavor: 'dev',
        dartDefines: {'API_URL': 'https://api.dev.example.com'},
        tags: 'smoke',
        buildName: '1.0.0',
        buildNumber: '123',
        appServerPort: 8082,
        testServerPort: 8081,
        additionalOptions: {'packageName': 'com.example.app'},
      );

      // Act
      await writer.writeCommandOptions(commandData);

      // Assert
      final optionsFile = projectRoot
          .childDirectory('integration_test')
          .childFile('patrol_options.json');
      
      expect(optionsFile.existsSync(), isTrue);
      
      final content = optionsFile.readAsStringSync();
      final Map<String, dynamic> json = jsonDecode(content);
      
      expect(json['command'], equals('build'));
      expect(json['platform'], equals('android'));
      expect(json['buildMode'], equals('debug'));
      expect(json['device'], equals('emulator-5554'));
      expect(json['targets'], equals(['integration_test/app_test.dart']));
      expect(json['flavor'], equals('dev'));
      expect(json['dartDefines'], equals({'API_URL': 'https://api.dev.example.com'}));
      expect(json['tags'], equals('smoke'));
      expect(json['buildName'], equals('1.0.0'));
      expect(json['buildNumber'], equals('123'));
      expect(json['appServerPort'], equals(8082));
      expect(json['testServerPort'], equals(8081));
      expect(json['coverage'], equals(false));
      expect(json['label'], equals(true));
      expect(json['uninstall'], equals(false));
      expect(json['generateBundle'], equals(true));
      expect(json['additionalOptions'], equals({'packageName': 'com.example.app'}));
      expect(json['timestamp'], isA<String>());
    });

    test('writeCommandOptions handles minimal data correctly', () async {
      // Arrange
      final commandData = CommandOptionsData(
        command: 'test',
        platform: 'ios',
        buildMode: 'release',
        device: 'iPhone 14',
      );

      // Act
      await writer.writeCommandOptions(commandData);

      // Assert
      final optionsFile = projectRoot
          .childDirectory('integration_test')
          .childFile('patrol_options.json');
      
      expect(optionsFile.existsSync(), isTrue);
      
      final content = optionsFile.readAsStringSync();
      final Map<String, dynamic> json = jsonDecode(content);
      
      expect(json['command'], equals('test'));
      expect(json['platform'], equals('ios'));
      expect(json['buildMode'], equals('release'));
      expect(json['device'], equals('iPhone 14'));
      expect(json['targets'], equals([]));
      expect(json.containsKey('flavor'), isFalse);
      expect(json['dartDefines'], equals({}));
      expect(json.containsKey('tags'), isFalse);
    });

    test('toCommandOptionsData extension creates correct data from FlutterAppOptions', () {
      // Arrange
      const flutterOpts = FlutterAppOptions(
        command: FlutterCommand('flutter'),
        target: 'integration_test/app_test.dart',
        flavor: 'staging',
        buildMode: BuildMode.profile,
        dartDefines: {'ENV': 'staging', 'DEBUG': 'true'},
        dartDefineFromFilePaths: ['config/staging.json'],
        buildName: '2.0.0',
        buildNumber: '456',
      );

      // Act
      final commandData = flutterOpts.toCommandOptionsData(
        command: 'develop',
        platform: 'macos',
        device: 'macOS',
        targets: ['integration_test/feature_test.dart'],
        tags: 'integration',
        appServerPort: 9000,
        testServerPort: 9001,
        additionalOptions: {'bundleId': 'com.example.macos'},
      );

      // Assert
      expect(commandData.command, equals('develop'));
      expect(commandData.platform, equals('macos'));
      expect(commandData.buildMode, equals('profile'));
      expect(commandData.device, equals('macOS'));
      expect(commandData.targets, equals(['integration_test/feature_test.dart']));
      expect(commandData.flavor, equals('staging'));
      expect(commandData.dartDefines, equals({'ENV': 'staging', 'DEBUG': 'true'}));
      expect(commandData.dartDefineFromFilePaths, equals(['config/staging.json']));
      expect(commandData.tags, equals('integration'));
      expect(commandData.buildName, equals('2.0.0'));
      expect(commandData.buildNumber, equals('456'));
      expect(commandData.appServerPort, equals(9000));
      expect(commandData.testServerPort, equals(9001));
      expect(commandData.additionalOptions, equals({'bundleId': 'com.example.macos'}));
    });
  });
}
