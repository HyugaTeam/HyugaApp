import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/widgets/LevelProgressBar.dart';


class ManagerQRScan extends StatelessWidget {
  @override

  final Firestore _db = Firestore.instance;
  DocumentSnapshot scannedUser;
  String uid = "";
  TextEditingController textController;
  double receiptValue;

  Future incrementUserScore(String uid) async{
    DocumentReference ref = _db.collection('users').document(uid); // a reference to the scanned user's profile
      scannedUser = await ref.get();
      if(scannedUser != null){
        print(scannedUser.data);
        ref.setData(({
          'score' : scannedUser.data['score'] + 100
        }),
      merge:  true);
      }
  }

  

  Future _scanQR() async{
    try{
      String qrResult = await BarcodeScanner.scan().then((ScanResult scanResult) => scanResult.rawContent);
      DocumentReference ref = _db.collection('users').document(qrResult); // a reference to the scanned user's profile
      var refData = await ref.get();
      print(uid);
      if(qrResult == null && refData != null)
        return null;
      else
        return refData;
    } on PlatformException
    catch(error){
      if(error.code == BarcodeScanner.cameraAccessDenied)
        print("Camera access is denied");
    }
  }


  ManagerQRScan(){
    textController.addListener(() { 
      receiptValue = double.parse(textController.value.text);
    });
  }  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _scanQR(),
      builder:(context,scanResult) {
        print(scanResult);
        if(!scanResult.hasData)
          return Scaffold(
            body: Container(
              child: Column(
                children: <Widget>[
                  Center(child: Text("")),
                  //LevelProgressBar(),
                  // FutureBuilder(
                  //   future: _scanQR(),
                  //   builder: null
                  // ),
                ],
              )
            )
          );
        else if(scanResult.data.data!= null){
          print("valid code///////");
          uid = scanResult.data.documentID;
          return Scaffold(
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Center(
                  //   child: Text(
                  //     scanResult.data.data['displayName']
                  //   )
                  // ),
                  AlertDialog(
                    title: Text("Valoare bon:", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: Text("Introduceti valoarea bonului:"),
                    actionsPadding: EdgeInsets.only(right: 20),
                    actions: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                height: 100,
                                width: 200,
                                child: TextField(
                                  controller: textController,
                                  keyboardType: TextInputType.number,
                                  onSubmitted: (String str){

                                  },
                                ),
                              ),
                              Text(
                                "Lei"
                              ),
                            ],
                          ),
                          RaisedButton(
                            child: Text(
                              "GATA",
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            onPressed: (){

                            }
                          )
                        ],
                      ),
                      
                    ],
                  )
                ],
              )
            )
          );
        }
        else return Scaffold(
          body: Center(child: Text("Invalid code", style:  TextStyle( fontSize: 20))),
        );
      
      }
    );
  }
}