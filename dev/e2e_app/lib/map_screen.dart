import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? position;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          if (position == null)
            const Text('Waiting for location...')
          else ...[
            Text('Location'),
            const SizedBox(height: 10),
            Text('Latitude: ${position?.latitude}'),
            const SizedBox(height: 10),
            Text('Longitude: ${position?.longitude}'),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: GoogleMap(
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 12,
              ),
              onMapCreated: manageLocation,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> manageLocation(GoogleMapController controller) async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    Geolocator.getPositionStream().listen((position) {
      setState(() {
        this.position = position;
      });

      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 12,
          ),
        ),
      );
    });
  }
}
