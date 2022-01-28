import 'package:flutter/material.dart';

import 'dart:developer';
import 'dart:io';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:QRReader/utils/string_validator.dart';

void main() {
  runApp(const MaterialApp(home: QRScannerView()));
}

class QRScannerView extends StatefulWidget {
  const QRScannerView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool displayText = false;
  StringValidator stringValidator = StringValidator();

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
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 11, child: _buildQrView(context)),
          Expanded(flex: 1, child: _buildBottomBar(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderRadius: 10,
          borderWidth: 5,
          borderColor: Colors.white,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          child: IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
          ),
        ),
        Container(
          child: IconButton(
            icon: Icon(Icons.flip_camera_android),
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      bool dataIsURL = stringValidator.isStringURL(scanData.code!);
      if (dataIsURL) {
        showLinkAlertDialog(context, scanData.code!, controller);
        controller.pauseCamera();
      } else {
        showAlertDialog(context, scanData.code!, controller);
        controller.pauseCamera();
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  bool isStringURL(String message) {
    return isURL(message);
  }
}

showAlertDialog(
    BuildContext context, String message, QRViewController controller) {
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () async {
      Navigator.of(context).pop();
      await controller.resumeCamera();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text("Message Scanned!"),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showLinkAlertDialog(
    BuildContext context, String message, QRViewController controller) {
  Widget okButton = TextButton(
    child: Text("Ok"),
    onPressed: () async {
      launch(message);
      Navigator.of(context).pop();
      await controller.resumeCamera();
    },
  );

  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () async {
      Navigator.of(context).pop();
      await controller.resumeCamera();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text("URL found! Open Link?"),
    content: Text(message),
    actions: [okButton, cancelButton],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
