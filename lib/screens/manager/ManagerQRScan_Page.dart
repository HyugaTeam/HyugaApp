import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rxdart/rxdart.dart';

class ManagerQRScan extends StatefulWidget {
  ManagerQRScan();

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
  GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController _qrViewController;
  PublishSubject<String> scanStream;

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
    scanStream = PublishSubject<String>();
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

  Widget scanQr(){
    return Scaffold(
      appBar: AppBar(
        actions: [
          RaisedButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("Renunta"),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Text("s")
          ),
          Expanded(
            flex: 5,
            child: QRView(
              key: _qrKey, 
              onQRViewCreated: _onQRViewCreated
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller){
    this._qrViewController = controller;
    _qrViewController.scannedDataStream.listen((scanResult) {
      scanStream.add(scanResult);
      print(scanResult);
    });  
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
    return null;
  }

  // Gets the current discount percentage
  int getDiscount(){
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
        if(startHour.compareTo(currentTime) <=0 
        && endHour.compareTo(currentTime) >=0)
          return int.parse(todayDiscounts[i].toString().substring(12,14));
      }
    }
    return 0;
  }

  List<Map<String,dynamic>> getDeals(){
    Map<String, dynamic> deals = managedLocal.deals;
    List todayDeals;
    String currentWeekday = DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase();
    /// Checks if the place has deals in the current weekday
    if(deals.containsKey(currentWeekday) != true)
      return null;
    else {
      todayDeals = deals[currentWeekday];
      List<Map<String,dynamic>> result = <Map<String,dynamic>>[];
      for(int i = 0 ; i< todayDeals.length; i++){
        String startHour = todayDeals[i]['interval'].toString().substring(0,5); 
        String endHour = todayDeals[i]['interval'].toString().substring(6,11);
        String currentTime = DateTime.now().toLocal().hour.toString() + ':' + DateTime.now().toLocal().minute.toString();
        print(startHour+endHour);
        if(startHour.compareTo(currentTime) <=0 
        && endHour.compareTo(currentTime) >=0)
          result.add(todayDeals[i]);
      }
      return result;
    }
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
    await userRef.set(
      {
          'place_id' : managedLocal.id,
          'place_name' : managedLocal.name,
          'date_start': FieldValue.serverTimestamp(),
          'discount': getDiscount(),
          'deals': getDeals(),
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
          'discount': getDiscount(),
          'deals': getDeals(),
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

    AnalyticsService().analytics.logEvent(
      name: 'new_scan',
      parameters: {
        'place_name': managedLocal.name,
        'place_id': managedLocal.id,
        'date_start': FieldValue.serverTimestamp(),
        'number_of_guests': numberOfGuests,
        'reservation': false,
        'discount': getDiscount(),
        'deals': getDeals()
      }
    );
    return ok;
  }

  @override
  Widget build(BuildContext context) {

    managedLocal =  Provider.of<AsyncSnapshot<dynamic>>(context).data;

    return StreamBuilder(
      stream: scanStream,
      builder:(context,scanResult) {
        print(scanResult);
        if(!scanResult.hasData)
          return Scaffold(
            appBar: AppBar(
              actions: [
                RaisedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Renunta"),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: QRView(
                    key: _qrKey, 
                    onQRViewCreated: _onQRViewCreated
                  ),
                ),
              ],
            ),
          );
        if(scanResult.data!= null){
          print("valid code///////");
          uid = scanResult.data;
          return Scaffold(
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                            Expanded(
                              child:Container()
                            ),
                          ],
                        )
                      ),
                    ),
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