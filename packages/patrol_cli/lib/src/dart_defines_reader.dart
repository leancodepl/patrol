import 'dart:convert';

import 'package:file/file.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';

class DartDefinesReader {
  DartDefinesReader({required Directory projectRoot})
      : _projectRoot = projectRoot,
        _fs = projectRoot.fileSystem;

  final Directory _projectRoot;
  final FileSystem _fs;

  Map<String, String> fromCli({required List<String> args}) => _parse(args);

  Map<String, String> fromFile() {
    final filePath = _fs.path.join(_projectRoot.path, '.patrol.env');
    final file = _fs.file(filePath);

    if (!file.existsSync()) {
      return {};
    }

    final lines = file.readAsLinesSync()
      ..removeWhere((line) => line.trim().isEmpty);
    return _parse(lines);
  }

  Map<String, String> _parse(List<String> args) {
    final map = <String, String>{};
    var currentKey = ' ';
    for (final arg in args) {
      if (!arg.contains('=') && currentKey != ' ') {
        map[currentKey] = '${map[currentKey]}, $arg';
        continue;
      }
      final parts = arg.splitFirst('=');
      currentKey = parts.first;
      if (currentKey.contains(' ')) {
        throw FormatException('key "$currentKey" contains whitespace');
      }

      final value = parts.elementAt(1);
      map[currentKey] = value;
    }

    return map;
  }

  /// Most of the below code comes from:
  /// https://github.com/flutter/flutter/blob/64dd1ca9bc32fbc767a3f63e4c9c5ae2fc355380/packages/flutter_tools/lib/src/runner/flutter_command.dart
  ///
  /// Copyright 2014 The Flutter Authors. All rights reserved.
  ///
  /// Redistribution and use in source and binary forms, with or without modification,
  /// are permitted provided that the following conditions are met:
  ///
  ///     * Redistributions of source code must retain the above copyright
  ///       notice, this list of conditions and the following disclaimer.
  ///     * Redistributions in binary form must reproduce the above
  ///       copyright notice, this list of conditions and the following
  ///       disclaimer in the documentation and/or other materials provided
  ///       with the distribution.
  ///     * Neither the name of Google Inc. nor the names of its
  ///       contributors may be used to endorse or promote products derived
  ///       from this software without specific prior written permission.
  ///
  /// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  /// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  /// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  /// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
  /// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  /// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  /// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
  /// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  /// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  /// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  Map<String, Object?> extractDartDefineConfigJsonMap(
    List<String> configFilePaths,
  ) {
    final dartDefineConfigJsonMap = <String, Object?>{};

    for (final path in configFilePaths) {
      if (!_fs.isFileSync(path)) {
        throw Exception(
          'Did not find the file passed to "--dart-define-from-file". Path: $path',
        );
      }

      final configRaw = _fs.file(path).readAsStringSync();

      // Determine whether the file content is JSON or .env format.
      String configJsonRaw;
      if (configRaw.trim().startsWith('{')) {
        configJsonRaw = configRaw;
      } else {
        // Convert env file to JSON.
        configJsonRaw = convertEnvFileToJsonRaw(configRaw);
      }

      try {
        // Fix json convert Object value :type '_InternalLinkedHashMap<String, dynamic>' is not a subtype of type 'Map<String, Object>' in type cast
        (json.decode(configJsonRaw) as Map<String, dynamic>)
            .forEach((key, value) {
          dartDefineConfigJsonMap[key] = value;
        });
      } on FormatException catch (err) {
        throw Exception(
            'Unable to parse the file at path "$path" due to a formatting error. '
            'Ensure that the file contains valid JSON.\n'
            'Error details: $err');
      }
    }

    return dartDefineConfigJsonMap;
  }

  /// Converts an .env file string to its equivalent JSON string.
  ///
  /// For example, the .env file string
  ///   key=value # comment
  ///   complexKey="foo#bar=baz"
  /// would be converted to a JSON string equivalent to:
  ///   {
  ///     "key": "value",
  ///     "complexKey": "foo#bar=baz"
  ///   }
  ///
  /// Multiline values are not supported.
  String convertEnvFileToJsonRaw(String configRaw) {
    final lines = configRaw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => !line.startsWith('#')) // Remove comment lines.
        .toList();

    final propertyMap = <String, String>{};
    for (final line in lines) {
      final property = _parseProperty(line);
      propertyMap[property.key] = property.value;
    }

    return jsonEncode(propertyMap);
  }

  /// Parse a property line from an env file.
  /// Supposed property structure should be:
  ///   key=value
  ///
  /// Where: key is a string without spaces and value is a string.
  /// Value can also contain '=' char.
  ///
  /// Returns a record of key and value as strings.
  MapEntry<String, String> _parseProperty(String line) {
    if (DotEnvRegex.multiLineBlock.hasMatch(line)) {
      throw Exception('Multi-line value is not supported: $line');
    }

    final Match? keyValueMatch = DotEnvRegex.keyValue.firstMatch(line);
    if (keyValueMatch == null) {
      throw Exception('Unable to parse file provided for '
          '--dart-define-from-file.\n'
          'Invalid property line: $line');
    }

    final key = keyValueMatch.group(1)!;
    final value = keyValueMatch.group(2) ?? '';

    // Remove wrapping quotes and trailing line comment.
    final Match? doubleQuotedValueMatch =
        DotEnvRegex.doubleQuotedValue.firstMatch(value);
    if (doubleQuotedValueMatch != null) {
      return MapEntry<String, String>(key, doubleQuotedValueMatch.group(1)!);
    }

    final Match? singleQuotedValueMatch =
        DotEnvRegex.singleQuotedValue.firstMatch(value);
    if (singleQuotedValueMatch != null) {
      return MapEntry<String, String>(key, singleQuotedValueMatch.group(1)!);
    }

    final Match? backQuotedValueMatch =
        DotEnvRegex.backQuotedValue.firstMatch(value);
    if (backQuotedValueMatch != null) {
      return MapEntry<String, String>(key, backQuotedValueMatch.group(1)!);
    }

    final Match? unquotedValueMatch =
        DotEnvRegex.unquotedValue.firstMatch(value);
    if (unquotedValueMatch != null) {
      return MapEntry<String, String>(key, unquotedValueMatch.group(1)!);
    }

    return MapEntry<String, String>(key, value);
  }
}

abstract class DotEnvRegex {
  // Dot env multi-line block value regex
  static final RegExp multiLineBlock =
      RegExp(r'^\s*([a-zA-Z_]+[a-zA-Z0-9_]*)\s*=\s*"""\s*(.*)$');

  // Dot env full line value regex (eg FOO=bar)
  // Entire line will be matched including key and value
  static final RegExp keyValue =
      RegExp(r'^\s*([a-zA-Z_]+[a-zA-Z0-9_]*)\s*=\s*(.*)?$');

  // Dot env value wrapped in double quotes regex (eg FOO="bar")
  // Value between double quotes will be matched (eg only bar in "bar")
  static final RegExp doubleQuotedValue = RegExp(r'^"(.*)"\s*(\#\s*.*)?$');

  // Dot env value wrapped in single quotes regex (eg FOO='bar')
  // Value between single quotes will be matched (eg only bar in 'bar')
  static final RegExp singleQuotedValue = RegExp(r"^'(.*)'\s*(\#\s*.*)?$");

  // Dot env value wrapped in back quotes regex (eg FOO=`bar`)
  // Value between back quotes will be matched (eg only bar in `bar`)
  static final RegExp backQuotedValue = RegExp(r'^`(.*)`\s*(\#\s*.*)?$');

  // Dot env value without quotes regex (eg FOO=bar)
  // Value without quotes will be matched (eg full value after the equals sign)
  static final RegExp unquotedValue =
      RegExp(r'^([^#\n\s]*)\s*(?:\s*#\s*(.*))?$');
}
