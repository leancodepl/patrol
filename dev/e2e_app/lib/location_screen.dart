import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  var _permissionGranted = false;

  Future<Position> _getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _permissionGranted = status == PermissionStatus.granted;
    });
  }

  @override
  void initState() {
    super.initState();
    Permission.location.isGranted.then(
      (value) {
        setState(() => _permissionGranted = value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            if (!_permissionGranted) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No location',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  Text(
                    'Permission not granted',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    child: Text(
                      'Grant permission',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ],
              );
            }

            return FutureBuilder<Position>(
              future: Future.delayed(Duration(seconds: 3), _getPosition),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Waiting for location...',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  );
                }

                final lat = snapshot.data?.latitude;
                final lng = snapshot.data?.longitude;

                if (lat == null || lng == null) {
                  return const Text('failed to get location');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your location',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      'lat: $lat',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text(
                      'lng: $lng',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
