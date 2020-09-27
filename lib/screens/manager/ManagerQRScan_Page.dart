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
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


class ManagerQRScan extends StatefulWidget {
  ManagerQRScan(){
    // textController.addListener(() { 
    //   receiptValue = double.parse(textController.value.text);
    // });
  }  

  @override
  _ManagerQRScanState createState() => _ManagerQRScanState();
}

class _ManagerQRScanState extends State<ManagerQRScan> {

  bool cameraAccessDenied = false;
  ManagedLocal managedLocal;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DocumentSnapshot scannedUser;
  String uid = "";
  int tableNumber;
  int numberOfGuests;
  TextEditingController _tableNumberTextController = new TextEditingController();
  TextEditingController _noOfGuestsTextController = new TextEditingController();
  GlobalKey<FormState> _tableNoFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _noOfGuestsFormKey = GlobalKey<FormState>();


  _ManagerQRScanState(){
    _tableNumberTextController.addListener(() {
      tableNumber = int.parse(_tableNumberTextController.value.text);
    });
    _noOfGuestsTextController.addListener(() {
      numberOfGuests = int.parse(_noOfGuestsTextController.value.text);
    });
  }

  @override
  void initState(){
    initializeDateFormatting('ro',null);
    print("initialized format");
    super.initState();
  }
  
  /// Increseas the user's scan count with 1
  Future incrementUserScore(String uid) async{
    DocumentReference ref = _db.collection('users').doc(uid); // a reference to the scanned user's profile
      scannedUser = await ref.get();
      if(scannedUser != null){
        print(scannedUser.data());
        ref.set(({
          'score' : scannedUser.data()['score'] + 1
        }),
        SetOptions(
          merge: true
        )
        );
      }
  }

  Future<DocumentSnapshot> _scanQR() async{
    try{
      String qrResult = await BarcodeScanner.scan().then((ScanResult scanResult) {
        print("GATA");
        if(scanResult.type == ResultType.Cancelled)
          return null;
        return scanResult.rawContent;
      });
      DocumentReference ref = _db.collection('users').doc(qrResult); // a reference to the scanned user's profile
      var refData = await ref.get();
      print(uid);
      if(qrResult == null || refData == null)
        return null;
      else
        return refData;
    } //on PlatformException
    catch(error){
      if(error.code == BarcodeScanner.cameraAccessDenied){
        print("Camera access is denied");
        setState(() {
          cameraAccessDenied = true;
        });
      }
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

  // Gets the current discount percentage
  double getAppliedDiscount(){
    Map<String, dynamic> discounts = managedLocal.discounts;
    List todayDiscounts;
    String currentWeekday = DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase();
    /// Checks if the place has discounts in the current weekday
    if(discounts.containsKey(currentWeekday) != true)
      return null;
    else {
      todayDiscounts = discounts[currentWeekday];
      for(int i = 0 ; i< todayDiscounts.length; i++){
        String startHour = todayDiscounts[i].toString().substring(0,5);
        String endHour = todayDiscounts[i].toString().substring(6,11);
        String currentTime = DateTime.now().toLocal().hour.toString() + ':' + DateTime.now().toLocal().minute.toString();
        print(startHour+endHour);

        //print(DateTime.now().toLocal().toString());
        //print(DateTime.now().toUtc().toString());
        if(startHour.compareTo(currentTime) <=0 
        && endHour.compareTo(currentTime) >=0)
          return double.parse(todayDiscounts[i].toString().substring(12));
      }
    }
    return 0;
  }

/// TODO: FINISH SCANNING PROCESS
/// 1) GET THE RIGHT DISCOUNTS FOR THE USER
/// 2) UPDATE THE SCAN HISTORY OF THE USER WITH THE NEW DOCUMENT
/// 3) AFTER THE DOCUMENT IS CREATED, THE USER WILL RECEIVE A QUESTION WITH THE...
///   ...RECEIPT DATA AND HE WILL BE ASKED WHETHER IT IS CORRECT OR NOT
/// 4) IF IT IS CORRECT, THE DOCUMENT WILL REMAIN THERE, WITH THE 'OK' FLAG SET TO 'YES'
/// 5) IF THE USER INVALIDATES THE RECEIPT, THE SCAN WILL REMAIN IN THE DATABASE... 
/// ...WITH THE 'OK' FLAG SET TO 'NO'


  Future<bool> addNewScan(DocumentSnapshot userData,context)async {
    
    bool ok = false; // This decides whether the scan process has been approved by the user or not
    DocumentReference userRef = _db.collection('users').doc(userData.id).collection('scan_history').doc();
    DocumentReference placeRef = _db.collection('users').doc(authService.currentUser.uid)
    .collection('managed_locals').doc(managedLocal.id).collection('scanned_codes').doc();
    String docName = userData.id;
    int usersLevel = getLevel(userData.data()['score']);
    //Stream<QuerySnapshot> scanResult = _db.collection('users').doc(authService.currentUser.uid).collection('scan_history').snapshots().skip(1);
    await userRef.set(
      {
          'place_id' : managedLocal.id,
          'place_name' : managedLocal.name,
          'date_start': FieldValue.serverTimestamp(), 
          'discount': getAppliedDiscount(),
          'is_active': true,
          'number_of_guests': numberOfGuests,
          'score' : userData.data()['score'],
          'approved_by_user' : null,
          'reservation' : false,
          'reservation_ref' : null,
          'place_scan_ref' : placeRef
      },
      SetOptions(
        merge: true
      )
    );
    await placeRef.set(
      {
          'guest_id' : userData.id,
          'guest_name' : userData.data()['displayName'],
          'date_start': FieldValue.serverTimestamp(), 
          'discount': getAppliedDiscount(),
          'is_active': true,
          'number_of_guests': numberOfGuests,
          'retained_percentage': managedLocal.retainedPercentage,
          'score' : userData.data()['score'],
          'table_number' : tableNumber,
          'approved_by_user' : null,
          'reservation' : false,
          'reservation_ref' : null,
          'user_scan_ref' : userRef
      },
      SetOptions(
        merge: true
      )
    );
    // scanResult.first.then((value) {
    //   if(value.docChanges.first.doc.data()['approved_by_user'] == true)
    //     ok = true;
    // }
    // );

    //incrementUserScore(userData.documentID);

    //Set data about the scanned code in the database
    // DocumentReference newScannedCodeRef = _db.collection('users')
    // .doc(authService.currentUser.uid).collection('managed_locals')
    // .doc(managedLocal.id).collection('scanned_codes').doc();
    // newScannedCodeRef.set({
    //   'guest_id' : userData.documentID,
    //   'date': DateTime.now().toUtc(),
    //   'applied_discount': getAppliedDiscount(),
    //   'retained_percentage': 5,
    //   'score' : userData.data['score'] + 1,
    //   'total' : tableNumber,
    //   'guest_name' : userData.data()['name'],
    //   'approved_by_user' : true
    // });
    return ok;
  }

  @override
  Widget build(BuildContext context) {

    managedLocal =  Provider.of<AsyncSnapshot<dynamic>>(context).data;

    return FutureBuilder<DocumentSnapshot>(
      future: _scanQR(),
      builder:(context,scanResult) {
        print(scanResult);
        if(!scanResult.hasData)
          return Scaffold(
            body: Container(
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Ceva a mers gresit, incearca sa scanezi din nou!"),
                  cameraAccessDenied
                  ? TextButton(
                    onPressed: (){
                      Permission.camera.request().then((value) => setState((){
                        cameraAccessDenied = value.isGranted;
                      }));
                    }, 
                    child: Text("Permite acces camerei.")
                  )
                  : Container()
                ],
              ))
            )
          );
        else if(scanResult.data.data()!= null){
          print("valid code///////");
          uid = scanResult.data.id;
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
                  Dialog(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                              height: MediaQuery.of(context).size.height*0.5,
                              width: MediaQuery.of(context).size.height*0.8,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Introduceti numarul mesei:",
                                      style: TextStyle(
                                        fontSize: 20
                                      ),
                                    ),
                                    Form(
                                      key: _tableNoFormKey,
                                      child: TextFormField(
                                        onChanged: (input) => tableNumber = int.tryParse(input),
                                        //onChanged: (input) => setState(()=>tableNumber = int.tryParse(input)),
                                        onFieldSubmitted: (input) => _tableNoFormKey.currentState.validate(),
                                        cursorColor: Colors.blueGrey,
                                        keyboardType: TextInputType.number,
                                        validator: (String input) => int.tryParse(input) == null 
                                          ? "Numarul introdus nu este corect!"
                                          : null,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      "Introduceti numarul de oaspeti:",
                                      style: TextStyle(
                                        fontSize: 20
                                      ),
                                    ),
                                    Form(
                                      key: _noOfGuestsFormKey,
                                      child: TextFormField(
                                        onChanged: (input) => numberOfGuests = int.tryParse(input),
                                        //onChanged: (input) => setState(()=>tableNumber = int.tryParse(input)),
                                        onFieldSubmitted: (input) => _noOfGuestsFormKey.currentState.validate(),
                                        cursorColor: Colors.blueGrey,
                                        keyboardType: TextInputType.number,
                                        validator: (String input) => int.tryParse(input) == null 
                                          ? "Numarul introdus nu este corect!"
                                          : null,
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height*0.05,
                                    ),
                                    
                                    ButtonBar(
                                      children: [
                                        RaisedButton(
                                          color: Colors.blueGrey,
                                          child: Text("Continua"),
                                          onPressed: () async{
                                            if(_tableNoFormKey.currentState.validate()){
                                              addNewScan(scanResult.data,context).then((value)=> Navigator.pop(context,value));
                                            }
                                          }
                                        ),
                                        RaisedButton(
                                          color: Colors.white,
                                          child: Text("Renunta"),
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    ),
                                    // SizedBox(
                                    //   height: MediaQuery.of(context).size.height*0.1
                                    // ),
                                    Expanded(
                                      child:Container()
                                    ),
                                    // isLoading == true
                                    // ? CircularProgressIndicator()
                                    // : SizedBox(height: 6,)
                                  ],
                                )
                              ),
                            ),
                          )
                          
                  // AlertDialog(
                  //   title: Wrap(
                  //     children: <Widget>[
                  //       Text("Reducerea care trebuie aplicata:", style: TextStyle(fontWeight: FontWeight.bold)),
                  //       Text(getAppliedDiscount().toString(),style: TextStyle(fontWeight: FontWeight.bold))
                  //     ],
                  //   ),
                  //   content: Text("Introduceti numarul mesei"),
                  //   actionsPadding: EdgeInsets.only(right: 20),
                  //   actions: <Widget>[
                  //     Column(
                  //       children: <Widget>[
                  //         Row(
                  //           children: <Widget>[
                  //             Container(
                  //               height: 100,
                  //               width: 200,
                  //               child: TextField(
                  //                 controller: textController,
                  //                 keyboardType: TextInputType.number,
                  //                 onSubmitted: (String str){
                  //                   setState((){tableNumber = int.parse(str);});
                  //                 },
                  //               ),
                  //             ),
                  //             Text(
                  //               "Lei"
                  //             ),
                  //           ],
                  //         ),
                  //         RaisedButton(
                  //           child: Text(
                  //             "GATA",
                  //             style: TextStyle(
                  //               fontWeight: FontWeight.bold
                  //             )
                  //           ),
                  //           onPressed: () {
                  //             tryToSendDataToUser(scanResult.data, context);
                  //             showDialog(context: context, builder: (context){
                  //                 return FutureBuilder(
                  //                   future: Future<bool>.delayed(Duration(milliseconds: 1500)).then((value) { Navigator.pop(context); }),
                  //                   builder:(context,finished){ 
                  //                     if(!finished.hasData)
                  //                       return AlertDialog(
                  //                         title: Text(
                  //                           "Cod scanat cu succes!"
                  //                         ),
                  //                         content: FaIcon(FontAwesomeIcons.checkCircle, color: Colors.green,),
                  //                       );
                  //                       return Container();
                  //                   });
                  //               }).then((value) { Navigator.pop(context); });
                  //           } 
                  //         )
                  //       ],
                  //     ),
                      
                  //   ],
                  // )
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