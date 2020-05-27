import 'package:flutter/material.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';

class ManagerQRScan extends StatefulWidget {
  @override
  _QRScanState createState() => _QRScanState();
}

class _QRScanState extends State<ManagerQRScan> {

  GlobalKey _qrKey = GlobalKey();
  var qrText = "";
  //QRViewController controller;

  @override
  void dispose(){
     // controller?.dispose();
      super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          // child: QRView(
          //   key: _qrKey,
          //   onQRViewCreated: (controller){
          //     this.controller = controller;
          //     controller.scannedDataStream.listen(
          //       (code) { 
          //         setState(() => qrText = code);
          //       });
          //   },
          // )
        )

    );
  }
}