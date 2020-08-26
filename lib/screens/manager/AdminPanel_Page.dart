import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/manager/AnalysisPage.dart';
import 'package:hyuga_app/screens/manager/EditorPage.dart';
import 'package:hyuga_app/screens/manager/ReservationsPage.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/manager/ManagerQRScan_Page.dart';
import 'package:hyuga_app/widgets/drawer.dart';
import 'package:provider/provider.dart';

class AdminPanel extends StatelessWidget {
  
  Future<Map<String,dynamic>> _getPlaceAnalytics(String placeID) async{
    QuerySnapshot scannedCodes = await Firestore.instance.collection('users').document(authService.currentUser.uid)
    .collection('managed_locals').document(placeID).collection('scanned_codes').where('approved_by_user',isEqualTo: true).getDocuments();
    double sum = 0;
    scannedCodes.documents.forEach((element) {
      sum += element.data['total'];
    });
    Map<String,dynamic> result = {};
    result.addAll({'scanned_codes': scannedCodes.documents});
    result.addAll({"all_time_income": sum});
    return result;
  }

  Future<ManagedLocal> _getLocalData() async{
    ManagedLocal _managedLocal = ManagedLocal();

    // Queryes data about the place from the manager's directory
    DocumentSnapshot placeData = (await Firestore.instance
    .collection('users').document(authService.currentUser.uid)
    .collection('managed_locals')
    .getDocuments())
    .documents.first;

    String localDocumentID = placeData.documentID;
    print(localDocumentID);
    Map<String,dynamic> analytics = {};
    analytics.addAll(await _getPlaceAnalytics(localDocumentID));
    
    print("start");
    DocumentSnapshot localDocument = await Firestore.instance
    .collection('locals_bucharest')
    .document(localDocumentID)
    .get();
    print(localDocument.data);
    _managedLocal = ManagedLocal( 
      id: localDocumentID,
      name: localDocument.data['name'],
      description: localDocument.data['description'],
      cost: localDocument.data['cost'],
      capacity: localDocument.data['capacity'],
      ambiance: localDocument.data['ambiance'],
      profile: localDocument.data['profile'],
      discounts: localDocument.data['discounts'],
      analytics: analytics,
      reservations: localDocument.data['reservations']
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
            length: 3,
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
                  tabs: [Text("Analiza"), Text("Editor"),Text("Rezervari")]
                ),
              ),
              body: TabBarView(
                children: [
                  Provider(
                    create: (context) => _managedLocal,
                    child: AnalysisPage()
                  ),
                  Provider(
                    create: (context) => _managedLocal,
                    child: EditorPage()
                  ),
                  Provider(
                    create: (context) => _managedLocal,
                    child: ReservationsPage()
                  )
                ]
              )
            ),
          );
      }
    );
  }
}