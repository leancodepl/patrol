import 'dart:convert';
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
  patrol('ip geolocation via dart http client with proxy', ($) async {
    // Read the system proxy from the native side
    final proxy = await $.platform.mobile.getSystemProxy();
    $.log('System proxy: host=${proxy.host}, port=${proxy.port}');

    final client = io.HttpClient();
    if (proxy.host != null) {
      final proxyHost = proxy.host!;
      final proxyPort = proxy.port ?? 80;
      $.log('Configuring HttpClient with proxy $proxyHost:$proxyPort');
      client.findProxy = (uri) => 'PROXY $proxyHost:$proxyPort';
    }

    final request = await client.getUrl(
      Uri.parse('https://ipinfo.io/json'),
    );
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    $.log('IP geolocation response: $body');

    final json = jsonDecode(body) as Map<String, dynamic>;
    final country = json['country'] as String;
    $.log('Country: $country');
    // When geolocation is set, the country should match.
    // When not set, it will be IN (India, where TestMu devices are).
    $.log('Country code from IP geolocation: $country');
    client.close();
  }, tags: ['android']);

  patrol('ip geolocation via webview', ($) async {
    await createApp($);

    await $('Open webview (IP Check)').scrollTo().tap();
    await $.pump(const Duration(seconds: 10));

    await $.platform.mobile.waitUntilVisible(
      Selector(textContains: '"country"'),
      timeout: const Duration(seconds: 15),
    );

    final response = await $.platform.android.getNativeViews(
      AndroidSelector(textContains: '"country"'),
    );
    final views = response.roots;
    $.log('Found ${views.length} views with country');
    for (final view in views) {
      $.log('View text: ${view.text}');
    }

    expect(views, isNotEmpty);
    final responseText = views.first.text ?? '';
    $.log('Response text: $responseText');

    final json = jsonDecode(responseText) as Map<String, dynamic>;
    final country = json['country'] as String;
    $.log('WebView country: $country');
  }, tags: ['android']);

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
    await $('Latitude: $_lat2').waitUntilVisible();
    await $('Longitude: $_lon').waitUntilVisible();
    await $.platform.mobile.stopMockLocation();
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    await $.platform.mobile.setMockLocation(_lat3, _lon);
    await $.pumpAndSettle();
    await $('Location').waitUntilVisible();
    await $('Latitude: $_lat3').waitUntilVisible();
    await $('Longitude: $_lon').waitUntilVisible();
    await $.platform.mobile.stopMockLocation();
  }, tags: ['android', 'emulator', 'ios', 'simulator']);

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
  }, tags: ['android', 'emulator', 'ios', 'simulator']);
}

Future<List<Wpt>> loadGpxWaypoints(PatrolIntegrationTester $) async {
  // Load GPX file from assets
  final gpxString = await rootBundle.loadString('assets/gpx.gpx');

  // Parse GPX data
  final gpx = GpxReader().fromString(gpxString);
  $.log('GPX waypoints: ${gpx.wpts.length}');
  return gpx.wpts;
}
