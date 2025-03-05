import 'package:flutter/services.dart';
import 'package:gpx/gpx.dart';
import 'common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('mock location', ($) async {
    await createApp($);

    await $('Open map screen').scrollTo().tap();
    await $.pumpAndSettle();

    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.grantPermissionWhenInUse();
    }

    await $.pumpAndSettle();

    await $.native.setMockLocation(55.2297, 21.0122);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await $.pumpAndSettle();
    expect(await $('Location').waitUntilVisible(), findsOneWidget);
    expect(await $('Latitude: 55.2297').waitUntilVisible(), findsOneWidget);
    expect(await $('Longitude: 21.0122').waitUntilVisible(), findsOneWidget);
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    await $.native.setMockLocation(55.5297, 21.0122);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await $.pumpAndSettle();
    expect(await $('Location').waitUntilVisible(), findsOneWidget);
    expect(await $('Latitude: 55.5297').waitUntilVisible(), findsOneWidget);
    expect(await $('Longitude: 21.0122').waitUntilVisible(), findsOneWidget);
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    await $.native.setMockLocation(55.7297, 21.0122);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await $.pumpAndSettle();
    expect(await $('Location').waitUntilVisible(), findsOneWidget);
    expect(await $('Latitude: 55.7297').waitUntilVisible(), findsOneWidget);
    expect(await $('Longitude: 21.0122').waitUntilVisible(), findsOneWidget);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
  });

  // Skip this test for now, as it's too long to run on CI.
  patrol('mock location from GPX', skip: true, ($) async {
    await createApp($);

    await $('Open map screen').scrollTo().tap();
    await $.pumpAndSettle();

    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.grantPermissionWhenInUse();
    }

    await $.pumpAndSettle();

    // Load waypoints from GPX file
    final waypoints = await loadGpxWaypoints($);

    // Ensure we have at least one waypoint
    if (waypoints.isEmpty) {
      $.log('No waypoints found in GPX file');
      return;
    } else {
      $.log('Waypoints found in GPX file: ${waypoints.length}');
    }

    // DateTime? previousTime;

    // Simulate movement through all waypoints
    for (final waypoint in waypoints) {
      if (waypoint.time == null) {
        fail('Waypoint missing timestamp');
      }

      // Unused, but left as an example of how to handle time differences from
      // previous point.
      // Calculate delay based on time difference from previous point
      // if (previousTime != null) {
      //   final difference = waypoint.time!.difference(previousTime);
      // Use actual time difference from GPX file
      // await Future<void>.delayed(difference);
      // }
      // previousTime = waypoint.time;

      await $.native.setMockLocation(
        waypoint.lat!,
        waypoint.lon!,
      );

      await $.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Verify location display is updated
      expect(
        await $('Latitude: ${waypoint.lat!}').waitUntilVisible(),
        findsOneWidget,
      );
      expect(
        await $('Longitude: ${waypoint.lon!}').waitUntilVisible(),
        findsOneWidget,
      );
    }
  });
}

Future<List<Wpt>> loadGpxWaypoints(PatrolIntegrationTester $) async {
  // Load GPX file from assets
  final gpxString = await rootBundle.loadString('assets/gpx.gpx');

  // Parse GPX data
  final gpx = GpxReader().fromString(gpxString);
  $.log('GPX waypoints: ${gpx.wpts.length}');
  return gpx.wpts;
}
