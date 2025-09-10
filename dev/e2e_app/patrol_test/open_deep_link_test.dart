import 'common.dart';

void main() {
  patrol('Open url in the app', ($) async {
    await createApp($);
    await $.native.pressHome();

    await $.native.openUrl('patrol://check/somepath?query=10');
    await $.pumpAndSettle();

    expect($('Applink Screen'), findsOneWidget);
    expect($('Uri: patrol://check/somepath?query=10'), findsOneWidget);
    expect($('Path: /somepath'), findsOneWidget);
    expect($('Query: query=10'), findsOneWidget);
  });
}
