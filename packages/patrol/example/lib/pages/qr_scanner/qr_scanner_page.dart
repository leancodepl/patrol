import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Route<void> get qrScannerRoute =>
    MaterialPageRoute(builder: (_) => const _QrScannerPage());

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  late final MobileScannerController _controller;
  String? _scannedValue;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,

              onDetect: (capture) {
                final barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final value = barcodes.first.rawValue;
                  if (value != null) {
                    setState(() {
                      _scannedValue = value;
                    });
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          if (_scannedValue != null)
            Text(_scannedValue!)
          else
            const Text('No QR code detected'),
          const SizedBox(height: 40),
        ],
      ).horizontallyPadded24,
    );
  }
}
