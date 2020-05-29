import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/models/user.dart';

// class ManagerQRScan extends StatefulWidget {
//   @override
//   _QRScanState createState() => _QRScanState();
// }

// class _QRScanState extends State<ManagerQRScan> {

//   GlobalKey _qrKey = GlobalKey();
//   String uid = "";
//   User scannedUser;

//   //QRViewController controller;

//   @override
//   void dispose(){
//      // controller?.dispose();
//       super.dispose();
//   }


//   Future _scanQR() async{
//     try{
//       String qrResult = await BarcodeScanner.scan().then((ScanResult scanResult) => scanResult.rawContent);
//       setState(() {
//         uid = qrResult;
//       });
//       print(uid);
//     } on PlatformException
//     catch(error){
//       if(error.code == BarcodeScanner.cameraAccessDenied)
//         print("Camera access is denied");
//     }
//   }

//   _QRScanState(){
//     _scanQR().then((value) => null);
//   }

  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: Column(
//           children: <Widget>[
//             FutureBuilder(
//               future: _scanQR(),
//               builder: null
//             ),
//           ],
//         )
//       )
//     );
//   }
// }

class ManagerQRScan extends StatelessWidget {
  @override

  GlobalKey _qrKey = GlobalKey();
  String uid = "";
  User scannedUser;
  final Firestore _db = Firestore.instance;
  //QRViewController controller;


  Future _scanQR() async{
    try{
      String qrResult = await BarcodeScanner.scan().then((ScanResult scanResult) => scanResult.rawContent);
      DocumentReference ref = _db.collection('users').document(qrResult); // a reference to the scanned user's profile
      var refData = await ref.get();
      int valueToBeAdded = 1;
    
      // if(refData.data['points'] != null)
      //   switch (refData.data['points']) {
      //     case :
            
      //       break;
      //     default:
      //   }

      ref.setData(({
        'points' : refData.data['points'] + valueToBeAdded 
      }),
      merge:  true);

      if(ref != null)
        scannedUser = null;
      uid = qrResult;
      print(uid);
    } on PlatformException
    catch(error){
      if(error.code == BarcodeScanner.cameraAccessDenied)
        print("Camera access is denied");
    }
  }

  ManagerQRScan(){
    _scanQR().then((value) => null);
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // child: Column(
        //   children: <Widget>[
        //     FutureBuilder(
        //       future: _scanQR(),
        //       builder: null
        //     ),
        //   ],
        // )
      )
    );
  }
}