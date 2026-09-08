import 'package:file/memory.dart';
import 'package:patrol_cli/src/android/android_test_layout.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:test/test.dart';

void main() {
  late MemoryFileSystem fs;

  setUp(() {
    fs = MemoryFileSystem.test();
  });

  test('uses legacy when patrolTest is absent', () {
    final layout = AndroidTestLayoutDetector(fs.directory('android')).detect();

    expect(layout, AndroidTestLayout.inApp);
  });

  test('uses self-instrumenting layout when patrolTest is included', () {
    final android = fs.directory('android');
    android.childDirectory('patrolTest').createSync(recursive: true);
    android
        .childFile('settings.gradle.kts')
        .writeAsStringSync('include(":app", ":patrolTest")');
    android
        .childFile('patrolTest/src/main/java/example/MainActivityTest.java')
        .createSync(recursive: true);

    expect(
      AndroidTestLayoutDetector(android).detect(),
      AndroidTestLayout.selfInstrumenting,
    );
  });

  test('fails when patrolTest exists but is not included', () {
    final android = fs.directory('android');
    android.childDirectory('patrolTest').createSync(recursive: true);
    android.childFile('settings.gradle').writeAsStringSync("include ':app'");

    expect(
      () => AndroidTestLayoutDetector(android).detect(),
      throwsA(isA<ToolExit>()),
    );
  });

  test('ignores commented-out includes', () {
    final android = fs.directory('android');
    android.childDirectory('patrolTest').createSync(recursive: true);
    android
        .childFile('settings.gradle.kts')
        .writeAsStringSync('// include(":patrolTest")');

    expect(
      () => AndroidTestLayoutDetector(android).detect(),
      throwsA(isA<ToolExit>()),
    );
  });

  test('fails when patrolTest is included without a host source', () {
    final android = fs.directory('android');
    android.childDirectory('patrolTest').createSync(recursive: true);
    android
        .childFile('settings.gradle.kts')
        .writeAsStringSync('include(":app", ":patrolTest")');

    expect(
      () => AndroidTestLayoutDetector(android).detect(),
      throwsA(isA<ToolExit>()),
    );
  });
}
