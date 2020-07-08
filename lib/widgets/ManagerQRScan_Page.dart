import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/LevelProgressBar.dart';
import 'package:provider/provider.dart';


class ManagerQRScan extends StatelessWidget {
  @override

  ManagedLocal managedLocal;
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
          'score' : scannedUser.data['score'] + 1
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
      if(qrResult == null || refData == null)
        return null;
      else
        return refData;
    } on PlatformException
    catch(error){
      if(error.code == BarcodeScanner.cameraAccessDenied)
        print("Camera access is denied");
    }
  }
  
  int getLevel(int score){
    if(score != null){
      if(score < 1) // level 0
        return 0;
      else if(score < 3) // level 1
        return 1;
      else if(score < 8) // level 2
        return 2;
      else if(score < 23) // level 3
        return 3;
      else if(score < 48) // level 4
        return 4;
      else return 5; // level 5/
    }
  }

  void getAppliedDiscount(){
    /// TODO: implement
  }

/// TODO: FINISH SCANNING PROCESS
/// 1) GET THE RIGHT DISCOUNTS FOR THE USER
/// 2) UPDATE THE SCAN HISTORY OF THE USER WITH THE NEW DOCUMENT
/// 3) AFTER THE DOCUMENT IS CREATED, THE USER WILL RECEIVE A QUESTION WITH THE...
///   ...RECEIPT DATA AND HE WILL BE ASKED WHETHER IT IS CORRECT OR NOT
/// 4) IF IT IS CORRECT, THE DOCUMENT WILL REMAIN THERE, WITH THE 'OK' FLAG SET TO 'YES'
/// 5) IF THE USER INVALIDATES THE RECEIPT, THE SCAN WILL REMAIN IN THE DATABASE... 
/// ...WITH THE 'OK' FLAG SET TO 'NO'


  Future<bool> tryToSendDataToUser(userData)async {
    
    bool ok = false;

    DocumentReference ref = _db.collection('users').document(userData.documentID).collection('scan_history').document();
    String docName = userData.documentID;
    int usersLevel = getLevel(userData['score']);
    
    await ref.setData(
      {
          'date': DateTime.now().toUtc(),
          'applied_discount': 20,
          'max_discount': 10,
          'score' : scannedUser.data['score'] + 1,
          'total' : receiptValue
      },
      merge: true
    ).then((value) => ok = true);
    return ok;
  }

  void addScannedCodeToDatabase(userData){

  }

  ManagerQRScan(){
    // textController.addListener(() { 
    //   receiptValue = double.parse(textController.value.text);
    // });
  }  

  @override
  Widget build(BuildContext context) {

    managedLocal =  Provider.of<AsyncSnapshot<dynamic>>(context).data;

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
                    title: Wrap(
                      children: <Widget>[
                        Text("Reducerea care trebuie aplicata:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("20%",style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                    content: Text("Introduceti valoarea bonului (cu reducerea deja aplicata):"),
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
                                    receiptValue = double.parse(str);
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
                            onPressed: () {
                              tryToSendDataToUser(scanResult);
                              showDialog(context: context, builder: (context){
                                  return FutureBuilder(
                                    future: Future<bool>.delayed(Duration(milliseconds: 1500)).then((value) { Navigator.pop(context); }),
                                    builder:(context,finished){ 
                                      if(!finished.hasData)
                                        return AlertDialog(
                                          title: Text(
                                            "Cod scanat cu succes!"
                                          ),
                                          content: FaIcon(FontAwesomeIcons.checkCircle, color: Colors.green,),
                                        );
                                        return Container();
                                    });
                                }).then((value) { Navigator.pop(context); });
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