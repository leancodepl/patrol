import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  Future<Position> get _determinePosition async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
      ),
      body: Center(
        child: FutureBuilder<Position>(
          future: _determinePosition,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Text(
                'No location',
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
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
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'lat: $lat',
                  style: Theme.of(context).textTheme.headline3,
                ),
                Text(
                  'lng: $lng',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
