import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannerPage extends StatefulWidget {
  final String comingFrom;

  const ScannerPage({Key key, this.comingFrom}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  QRViewController controller;
  var platform = const MethodChannel('eimzoDemoChannel');

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _handledQrCode = false;

  String signInResult = '';
  String displayHash = '';
  String displayDomain = '';

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          Expanded(child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      cameraFacing: CameraFacing.back,
      onQRViewCreated: _onScannerViewCreated,
      formatsAllowed: [BarcodeFormat.qrcode],
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 5,
        borderLength: 10,
        borderWidth: 5,
        cutOutSize: 250,
      ),
    );
  }

  Future<void> _onScannerViewCreated(QRViewController controller) async {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (_handledQrCode) {
        return;
      }
      _handledQrCode = true;
      _launchURL(scanData.code);
    });
  }

  Future<bool> _launchURL(String code) async {
    String _deepLink;
    if (Platform.isAndroid) {
      _deepLink = 'eimzo://sign?qc=$code';
    } else if (Platform.isIOS) {
      _deepLink = 'eimzo://sign?qc=$code';
    } else
      return throw 'Could not launch $_deepLink';
    return await canLaunch(_deepLink)
        ? await launch(_deepLink)
        : throw 'Could not launch $_deepLink';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
