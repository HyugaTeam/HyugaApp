import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class ActiveGuestsPage extends StatefulWidget {
  @override
  _ActiveGuestsPageState createState() => _ActiveGuestsPageState();
}

class _ActiveGuestsPageState extends State<ActiveGuestsPage> {

  ManagedLocal _managedLocal;

  Stream activeGuestsStream(){
    FirebaseFirestore _db = FirebaseFirestore.instance;
    return   _db.collection('users').doc(authService.currentUser.uid).collection('managed_locals')
    .doc(_managedLocal.id).collection('reservations')
    .where('accepted',isNull: true)
    .snapshots();
  }

  @override
  Widget build(BuildContext context) {

    _managedLocal = Provider.of<AsyncSnapshot<dynamic>>(context).data;
    
    return Scaffold(
      body: Container(
        child: ListView.separated(
          itemCount: 0,
          itemBuilder: (context,index){

          },
          separatorBuilder: (context,index){
            
          },
        )
      ),
    );
  }
}