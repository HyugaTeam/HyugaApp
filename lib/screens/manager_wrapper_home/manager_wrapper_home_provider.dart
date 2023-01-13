
import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/managed_place/managed_place.dart';

class ManagerWrapperHomePageProvider with ChangeNotifier{
  ManagedPlace? managedPlace;
  bool isLoading = false;

  ManagerWrapperHomePageProvider(){
    getData();
  }

  Future<Map<String,dynamic>> _getPlaceAnalytics(String placeID, int maturityDay, num retainedPercentage) async{

    //fetchBigQueryData();

    DateTime today = DateTime.now().toLocal();
    QuerySnapshot scannedCodes = await FirebaseFirestore.instance.collection('users').doc(Authentication.auth.currentUser!.uid)
    .collection('managed_locals').doc(placeID).collection('scanned_codes').where("is_active", isEqualTo: false).get();
    double allTimeIncome = 0;
    int allTimeGuests = 0;
    double thirtyDaysIncome = 0;
    int thirtyDaysGuests = 0;
    double currentBillTotal = 0;

    int maturityMonth;
    if(today.day >= maturityDay)
      maturityMonth = (today.month + 12) % 12;
    else maturityMonth = (today.month-12)%12 - 1;
    DateTime emissionDate = DateTime(today.year, maturityMonth,maturityDay);
    DateTime maturityDate = DateTime(today.year, (maturityMonth + 1) % 12, (maturityDay-1)%31);
    scannedCodes.docs.forEach((element) {
      dynamic elementData = element.data() as Map;
      if(!elementData["is_active"]){
        allTimeIncome += elementData['total'] == null? 0 : elementData['total'];
        allTimeGuests += elementData['number_of_guests'] as int;
        if(today.difference(DateTime.fromMillisecondsSinceEpoch(elementData['date_start'].millisecondsSinceEpoch)).abs().inDays < 30){
          thirtyDaysIncome += elementData['total'] == null? 0 : elementData['total'];
          thirtyDaysGuests += elementData['number_of_guests'] as int;
        }
        if(DateTime.fromMillisecondsSinceEpoch(elementData['date_start'].millisecondsSinceEpoch).compareTo(emissionDate) > 0 
          && 
          (elementData['discount'] != 0 || elementData['deals'] != [])
        ){
          currentBillTotal += (elementData['total'] == null? 0 : elementData['total']);
        }
      }
    });
    currentBillTotal *= retainedPercentage/100;
    Map<String,dynamic> result = {};
    result.addAll(
      {
        'scanned_codes': scannedCodes.docs,
        "all_time_income" : allTimeIncome,
        "all_time_guests": allTimeGuests,
        "thirty_days_guests": thirtyDaysGuests,
        "thirty_days_income": thirtyDaysIncome,
        "current_bill_total": currentBillTotal,
        "emission_date": emissionDate,
        "maturity_date": maturityDate
      }
    );
    return result;
  }

  Future<void> getData() async{
    _loading();

    ManagedPlace _managedLocal = ManagedPlace();

    // Queries data about the place from the manager's directory
    DocumentSnapshot place = (await FirebaseFirestore.instance
    .collection('users').doc(Authentication.auth.currentUser!.uid)
    .collection('managed_locals')
    .get())
    .docs.first;
    dynamic placeData = place.data() as Map;
    String placeDocumentID = place.id;
    Map<String,dynamic> analytics = {};
        print("START1");

    analytics.addAll(await _getPlaceAnalytics(
      placeDocumentID, 
      placeData['maturity'],
      placeData['retained_percentage']
    ));
        print("START2");

    DocumentSnapshot placeDocument = await FirebaseFirestore.instance
    .collection('locals_bucharest')
    .doc(placeDocumentID)
    .get();
    dynamic placeDocumentData = placeDocument.data() as Map;
    print("START3");
    print("");
    try{
      _managedLocal = ManagedPlace( 
        id: placeDocumentID,
        name: placeDocumentData['name'],
        description: placeDocumentData['description'],
        cost: placeDocumentData['cost'],
        capacity: placeDocumentData['capacity'],
        ambiance: placeDocumentData['ambiance'],
        profile: placeDocumentData['profile'],
        discounts: placeDocumentData['discounts'],
        deals: placeDocumentData['deals'],
        analytics: analytics,
        reservations: placeDocumentData['reservations'],
        retainedPercentage: double.tryParse(placeData['retained_percentage'].toString()),
        schedule: placeDocumentData['schedule'],
        maturity: placeData['maturity']
      );
    }
    catch(err){print(err);}
    print("END");
    
    managedPlace = _managedLocal;

    _loading();
    
    notifyListeners();
  }

  _loading(){
    isLoading = !isLoading;
  }
}