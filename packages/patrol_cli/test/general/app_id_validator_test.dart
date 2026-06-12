import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/app_id_validator.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  group('warnIfIosBundleIdMissing', () {
    test('warns when value is null', () {
      final logger = _MockLogger();

      warnIfIosBundleIdMissing(null, logger);

      verify(() => logger.warn(any(that: contains('iOS')))).called(1);
    });

    test('warns when value is empty', () {
      final logger = _MockLogger();

      warnIfIosBundleIdMissing('', logger);

      verify(() => logger.warn(any(that: contains('bundle_id')))).called(1);
    });

    test('is silent when value is set', () {
      final logger = _MockLogger();

      warnIfIosBundleIdMissing('com.example.MyApp', logger);

      verifyNever(() => logger.warn(any()));
    });
  });

  group('warnIfMacosBundleIdMissing', () {
    test('warns when value is null', () {
      final logger = _MockLogger();

      warnIfMacosBundleIdMissing(null, logger);

      verify(() => logger.warn(any(that: contains('macOS')))).called(1);
    });

    test('warns when value is empty', () {
      final logger = _MockLogger();

      warnIfMacosBundleIdMissing('', logger);

      verify(() => logger.warn(any(that: contains('bundle_id')))).called(1);
    });

    test('is silent when value is set', () {
      final logger = _MockLogger();

      warnIfMacosBundleIdMissing('com.example.MyApp', logger);

      verifyNever(() => logger.warn(any()));
    });
  });

  group('warnIfAndroidPackageNameMissing', () {
    test('warns when value is null', () {
      final logger = _MockLogger();

      warnIfAndroidPackageNameMissing(null, logger);

      verify(() => logger.warn(any(that: contains('Android')))).called(1);
    });

    test('warns when value is empty', () {
      final logger = _MockLogger();

      warnIfAndroidPackageNameMissing('', logger);

      verify(() => logger.warn(any(that: contains('package_name')))).called(1);
    });

    test('is silent when value is set', () {
      final logger = _MockLogger();

      warnIfAndroidPackageNameMissing('com.example.myapp', logger);

      verifyNever(() => logger.warn(any()));
    });
  });
}
