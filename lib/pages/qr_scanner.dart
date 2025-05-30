import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: QRScannerScreen());
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;
  bool isTrigger = false;

  @override
  void initState() {
    _requestCameraPermission();
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(flex: 4, child: _buildQrView(context)),
        Expanded(
          flex: 1,
          child: Center(child: Text('Please scan the QR code')),
        ),
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
                MediaQuery.of(context).size.height < 400)
            ? 200.0
            : 300.0;
    return QRView(
      key: qrKey,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _toHandleQrScan(Barcode scanData) {
    try {
      var encodedData = scanData.code;
      if (encodedData != null) {
        FlutterLogs.logInfo(
          'QRScanner',
          'QR code scanned',
          'Scann successful: ${scanData.code}',
        );
        if (!isTrigger) {
          FlutterLogs.logWarn(
            'QRScanner',
            'QR code already scanned',
            'Ignoring duplicate scan',
          );
          setState(() {
            isTrigger = true;
          });
          Navigator.pop(context, {'data': encodedData});
        }
      } else {
        FlutterLogs.logWarn(
          'QRScanner',
          'Invalid QR code format',
          'QR code does not contain required fields',
        );
      }
    } catch (e) {
      FlutterLogs.logError(
        'QRScanner',
        'QR code scan error',
        'Error scanning QR code: $e',
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen(_toHandleQrScan);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // Permission granted, proceed with QR scanner
    } else if (status.isDenied) {
      if (!mounted) return;
      // Permission denied, show a message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
      FlutterLogs.logInfo(
        'QRScanner',
        'Camera permission denied',
        'User denied camera permission for QR scanner',
      );
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
    }
  }
}
