import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/models/user.dart';
import 'package:hyuga_app/screens/manager/AnalysisPage.dart';
import 'package:hyuga_app/screens/manager/EditorPage.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/ManagerQRScan_Page.dart';
import 'package:hyuga_app/widgets/drawer.dart';

class AdminPanel extends StatelessWidget {

  ManagedLocal _managedLocal;
  Future<bool> _getLocalData() async{
    User managerUser = authService.currentUser;
    QuerySnapshot localDocument = await Firestore.instance.collection('users').document(authService.currentUser.uid).collection('managed_locals').getDocuments();
    _managedLocal = ManagedLocal(
      name: localDocument.documents.first.data['name']
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: 100)).then((value) => true),
      builder: (context, finished) {
        if(!finished.hasData)
          return Scaffold(body: Center(child: CircularProgressIndicator(),));
        else 
          return DefaultTabController(
            length: 2,
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
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ManagerQRScan()));
                  },
                ),],
                backgroundColor: Theme.of(context).accentColor,
                centerTitle: true,
                title: Text('smth'),
                bottom: TabBar(
                  labelPadding: EdgeInsets.all(5),
                  tabs: [Text("Analiza"), Text("Editor")]
                ),
              ),
              body: TabBarView(
                children: [
                  AnalysisPage(),
                  EditorPage()
                ]
              )
            ),
          );
      }
    );
  }
}