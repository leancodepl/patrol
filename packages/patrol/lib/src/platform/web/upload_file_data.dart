import 'package:json_annotation/json_annotation.dart';

part 'upload_file_data.g.dart';

@JsonSerializable()
class UploadFileData {
  UploadFileData({
    required this.name,
    required this.content,
    this.mimeType = 'application/octet-stream',
  });

  Map<String, dynamic> toJson() => _$UploadFileDataToJson(this);

  /// The name of the file (e.g., 'example.txt')
  final String name;

  /// The file content as bytes
  final List<int> content;

  /// The MIME type of the file (e.g., 'text/plain', 'image/png')
  final String mimeType;
}
