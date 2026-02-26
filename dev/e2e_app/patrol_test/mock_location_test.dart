import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:gpx/gpx.dart';
import 'common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

// Test coordinates
const _lat1 = 55.2297;
const _lat2 = 55.5297;
const _lat3 = 55.7297;
const _lon = 21.0122;

void main() {
  patrol('mock location', ($) async {
    await createApp($);

    await $('Open map screen').scrollTo().tap();
    await $.pumpAndSettle();

    if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }
    if (io.Platform.isAndroid) {
      try {
        await $.platform.mobile.tap(Selector(text: 'Turn on'));
      } catch (_) {
        // ignore
      }
    }
    await $.pumpAndSettle();
    await $.platform.mobile.setMockLocation(_lat1, _lon);
    await $.pumpAndSettle();
    await $('Location').waitUntilVisible();
    await $('Latitude: $_lat1').waitUntilVisible();
    await $('Longitude: $_lon').waitUntilVisible();
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    await $.platform.mobile.setMockLocation(_lat2, _lon);
    await $.pumpAndSettle();
    await $('Location').waitUntilVisible();
    await $('Longitude: $_lon').waitUntilVisible();
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    await $.platform.mobile.setMockLocation(_lat3, _lon);
    await $.pumpAndSettle();
    await $('Location').waitUntilVisible();
    await $('Latitude: $_lat3').waitUntilVisible();
    await $('Longitude: $_lon').waitUntilVisible();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
  });

  // Skip this test for now, as it's too long to run on CI.
  patrol('mock location from GPX', skip: true, ($) async {
    await createApp($);

    await $('Open map screen').scrollTo().tap();
    await $.pumpAndSettle();

    if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
      await $.platform.mobile.grantPermissionWhenInUse();
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

      await $.platform.mobile.setMockLocation(waypoint.lat!, waypoint.lon!);

      await Future<void>.delayed(const Duration(milliseconds: 500));
      await $.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Verify location display is updated

      await $(
        'Latitude: ${waypoint.lat!.toStringAsFixed(4)}',
      ).waitUntilVisible();

      await $(
        'Longitude: ${waypoint.lon!.toStringAsFixed(4)}',
      ).waitUntilVisible();
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
