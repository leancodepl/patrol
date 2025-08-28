import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/native/patrol_app_service_web.dart';

void main() {
  patrolTest('grant geolocation permission', ($) async {
    await $.pumpWidgetAndSettle(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('App Test 1')),
          backgroundColor: Colors.blue,
          body: const LocationWidget(),
        ),
      ),
    );

    expect($('App Test 1'), findsOneWidget);

    await Future<void>.delayed(const Duration(seconds: 1));

    await $(#check_permission).tap();

    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('Current location permission: denied'), findsOneWidget);

    // Grant geolocation permission via Playwright (native)
    await callPlaywright('grantPermissions', {
      'permissions': ['geolocation'],
    });

    await Future<void>.delayed(const Duration(seconds: 2));

    await $(#check_permission).tap();

    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('Current location permission: whileInUse'), findsOneWidget);
  });
}

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  LocationPermission? currentLocationPermission;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Current location permission: ${currentLocationPermission?.name}',
          ),
          ElevatedButton(
            key: const Key('check_permission'),
            onPressed: () async {
              final permission = await Geolocator.checkPermission();
              setState(() {
                currentLocationPermission = permission;
              });
            },
            child: const Text('Check Permission'),
          ),
        ],
      ),
    );
  }
}
