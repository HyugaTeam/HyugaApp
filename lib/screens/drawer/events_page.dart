import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/services/auth_service.dart';

class EventsPage extends StatelessWidget {

  int itemCount = 0;

  Future<Map<String,dynamic>?> getUpcomingReservations() async{
    QuerySnapshot scanHistory = await FirebaseFirestore.instance.collection('users')
    .doc(authService.currentUser!.uid).collection('reservations_history')
    .where('date_start',isGreaterThan: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .where('claimed', isNull: true)     
    .get();
    itemCount = scanHistory.docs.length;
    bool allAreDenied = true;
    DocumentSnapshot? reservation;
    scanHistory.docs.forEach((element) {
      if((element.data() as Map)['accepted'] != false){
        reservation = element;
        allAreDenied = false;
      }
    });
    print(reservation);
    if(allAreDenied) return null;

    return reservation!.data() as FutureOr<Map<String, dynamic>?>;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}