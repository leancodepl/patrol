// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_file_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadFileData _$UploadFileDataFromJson(Map<String, dynamic> json) =>
    UploadFileData(
      name: json['name'] as String,
      content: (json['content'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
    );

Map<String, dynamic> _$UploadFileDataToJson(UploadFileData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'content': instance.content,
      'mimeType': instance.mimeType,
    };
