import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/bigquery/v2.dart';
import 'package:googleapis/logging/v2.dart';
import 'package:http/http.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/manager/ActiveGuests_Page.dart';
import 'package:hyuga_app/screens/manager/AnalysisPage.dart';
import 'package:hyuga_app/screens/manager/EditorPage.dart';
import 'package:hyuga_app/screens/manager/ReservationsPage.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/manager/ManagerQRScan_Page.dart';
import 'package:hyuga_app/widgets/drawer.dart';
import 'package:provider/provider.dart';

class AdminPanel extends StatelessWidget {
  
  Future<void> fetchBigQueryData() async {
    try{
      
      Client client = Client();
      
      String str = BigqueryApi.BigqueryReadonlyScope;
      BigqueryApi bigqueryApi = BigqueryApi(
        client,
        rootUrl: 'https://bigquery.googleapis.com/',
        servicePath: 'bigquery/v2/'
      );
      var data = bigqueryApi.tables;
      await data.get(
        'hyuga-app',
        'hyuga-app:analytics_223957065',
        'hyuga-app:analytics_223957065.events_20200909'
      );
      print(data);
    }
    catch(error){
      print('ERROR');
      print(error);
      print('/////');
    }
  }

  Future<Map<String,dynamic>> _getPlaceAnalytics(String placeID) async{

    fetchBigQueryData();

    QuerySnapshot scannedCodes = await FirebaseFirestore.instance.collection('users').doc(authService.currentUser.uid)
    .collection('managed_locals').doc(placeID).collection('scanned_codes').where('approved_by_user',isEqualTo: true).get();
    double sum = 0;
    scannedCodes.docs.forEach((element) {
      sum += element.data()['total'];
    });
    Map<String,dynamic> result = {};
    result.addAll({'scanned_codes': scannedCodes.docs});
    result.addAll({"all_time_income": sum});
    return result;
  }

  Future<ManagedLocal> _getLocalData() async{
    ManagedLocal _managedLocal = ManagedLocal();

    // Queryes data about the place from the manager's directory
    DocumentSnapshot placeData = (await FirebaseFirestore.instance
    .collection('users').doc(authService.currentUser.uid)
    .collection('managed_locals')
    .get())
    .docs.first;

    String localDocumentID = placeData.id;
    print(localDocumentID);
    Map<String,dynamic> analytics = {};
    analytics.addAll(await _getPlaceAnalytics(localDocumentID));
    
    print("start");
    DocumentSnapshot localDocument = await FirebaseFirestore.instance
    .collection('locals_bucharest')
    .doc(localDocumentID)
    .get();
    print(localDocument.data);
    _managedLocal = ManagedLocal( 
      id: localDocumentID,
      name: localDocument.data()['name'],
      description: localDocument.data()['description'],
      cost: localDocument.data()['cost'],
      capacity: localDocument.data()['capacity'],
      ambiance: localDocument.data()['ambiance'],
      profile: localDocument.data()['profile'],
      discounts: localDocument.data()['discounts'],
      analytics: analytics,
      reservations: localDocument.data()['reservations']
    );
    print("finished");
    return _managedLocal;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getLocalData(),
      builder: (context, _managedLocal) {
        if(!_managedLocal.hasData)
          return Scaffold(body: Center(child: CircularProgressIndicator(),));
        else 
          return DefaultTabController(
            length: 4,
            child: Scaffold(
              drawer: ProfileDrawer(),
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: AppBar(
                actions: [IconButton(
                  icon: Icon(Icons.camera_alt),
                  iconSize: 30,
                  tooltip: "Scan a code",
                  highlightColor: Colors.white30,
                  color: Theme.of(context).highlightColor,
                  onPressed: () async {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                    Provider(
                      create: (context) => _managedLocal,
                      child: ManagerQRScan()
                    ),
                    ));
                  },
                ),],
                backgroundColor: Theme.of(context).accentColor,
                centerTitle: true,
                title: Text(_managedLocal.data.name),
                bottom: TabBar(
                  labelPadding: EdgeInsets.all(5),
                  tabs: [Text("Mese active"),Text("Rezervari"),Text("Analiza"), Text("Editor")]
                ),
              ),
              body: TabBarView(
                children: [
                  Provider(
                    create: (context) => _managedLocal,
                    child: ActiveGuestsPage()
                  ),
                  Provider(
                    create: (context) => _managedLocal,
                    child: ReservationsPage()
                  ),
                  Provider(
                    create: (context) => _managedLocal,
                    child: AnalysisPage()
                  ),
                  Provider(
                    create: (context) => _managedLocal,
                    child: EditorPage()
                  ),
                ]
              )
            ),
          );
      }
    );
  }
}