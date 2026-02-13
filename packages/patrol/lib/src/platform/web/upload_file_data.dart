import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'upload_file_data.g.dart';

/// Represents a file to be uploaded via the web automator.
@JsonSerializable()
class UploadFileData {
  /// Creates a file upload data object.
  UploadFileData({
    required this.name,
    required this.content,
    this.mimeType = 'application/octet-stream',
  });

  /// Converts this object to JSON, encoding the content as base64.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'base64Data': base64Encode(content),
      'mimeType': mimeType,
    };
  }

  /// The name of the file (e.g., 'example.txt')
  final String name;

  /// The file content as bytes
  final List<int> content;

  /// The MIME type of the file (e.g., 'text/plain', 'image/png')
  final String mimeType;
}
