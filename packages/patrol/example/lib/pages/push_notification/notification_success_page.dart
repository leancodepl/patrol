import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

Route<void> get notificationRoute =>
    MaterialPageRoute(builder: (_) => const _NotificationSuccessPage());

class _NotificationSuccessPage extends StatefulWidget {
  const _NotificationSuccessPage();

  @override
  State<_NotificationSuccessPage> createState() =>
      _NotificationSuccessPageState();
}

class _NotificationSuccessPageState extends State<_NotificationSuccessPage> {
  late ConfettiController _confettiController;
  late final StreamSubscription<Position> _locationStream;
  String _location = '';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _locationStream = Geolocator.getPositionStream().listen(_onPositionUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      top: AppBar(
        backgroundColor: PTColors.textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PTColors.lcWhite),
          onPressed: () => Navigator.of(context).popUntil(
            (route) => route.isFirst,
          ),
        ),
      ),
      body: Column(
        children: [
          const Spacer(),
          Text(_location),
          Center(
            child: ConfettiWidget(
              confettiController: _confettiController..play(),
              blastDirectionality: BlastDirectionality.explosive,
              gravity: 0.05,
              shouldLoop: true,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _locationStream.cancel();
    super.dispose();
  }

  Future<void> _onPositionUpdated(Position pos) async {
    final placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);
    setState(() {
      _location = 'Your location: ${placemarks.firstOrNull?.street ?? ''}';
    });
  }
}
