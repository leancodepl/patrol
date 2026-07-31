import 'dart:convert';

import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('file upload', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    expect($(#uploaded_file_name), findsNothing);

    final fileContent = utf8.encode('Hello from Patrol file upload test!');
    final file = UploadFileData(
      name: 'example_file.txt',
      content: fileContent,
      mimeType: 'text/plain',
    );

    final uploadFuture = $.platform.web.uploadFile(files: [file]);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $('Upload File').scrollTo().tap();

    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await uploadFuture;
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect($(#uploaded_file_name), findsOneWidget);
    expect($('Uploaded: example_file.txt'), findsOneWidget);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
