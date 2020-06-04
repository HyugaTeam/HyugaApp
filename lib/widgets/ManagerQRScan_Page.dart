import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/widgets/LevelProgressBar.dart';


class ManagerQRScan extends StatelessWidget {
  @override

  GlobalKey _qrKey = GlobalKey();
  String uid = "";
  User scannedUser;
  final Firestore _db = Firestore.instance;
  

  Future _scanQR() async{
    try{
      String qrResult = await BarcodeScanner.scan().then((ScanResult scanResult) => scanResult.rawContent);
      //if(qrResult == )
      DocumentReference ref = _db.collection('users').document(qrResult); // a reference to the scanned user's profile
      var refData = await ref.get();
      if(refData != null)
        ref.setData(({
          'score' : refData.data['score'] + 100
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
        child: Column(
          children: <Widget>[
            Text(uid),
            
            //LevelProgressBar(),
            // FutureBuilder(
            //   future: _scanQR(),
            //   builder: null
            // ),
          ],
        )
      )
    );
  }
}