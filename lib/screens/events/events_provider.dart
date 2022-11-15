import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
export 'package:provider/provider.dart';

class EventsPageProvider with ChangeNotifier{
  List<Event> events = [
    Event(
      title: "DJ mix", 
      content: 'Vineri, 18 Noiembrie, incepand cu ora 22:00, ne vedem in Kristal CLUB pentru o petrecere in stilul anilor 2000.\nDescopera o seara plina de amintiri, muzica pe care o iubim si un concept fresh by 2k Party #tuceculoareesti #getyourneon \nIa-ti bratara care te reprezinta: single, intr-o relatie sau e complicat si vino sa petrecem pe cele mai tari hituri impreuna cu DJ Mara Ognean, Jorge si DJ Megrov.\nDress code: 2000s fashion inspired\nREZERVARE MASA + alte detalii -\n0736688445\nSee you there!', 
      dateCreated: DateTime.now(), 
      dateStart: DateTime.now().add(Duration(days: 2)), 
      name: 'Halloween Party', organiserName: 'Nostalgia', 
      photoUrl: 'https://dnwp63qf32y8i.cloudfront.net/da95bd742d4fa9f7114cb40200635966f98b4a40', 
      placeRef: FirebaseFirestore.instance.collection("locals_bucharest").doc("martina_ristorante_pizzeria")
    )
  ];
  bool isLoading = false;

  EventsPageProvider(){
    //getData();
  }

  Future<void> getData() async{
    _loading();

    var query = await FirebaseFirestore.instance.collection('events')
    .where('date_start',isGreaterThan: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .get();
    events = query.docs.map((doc) => docToEvent(doc.data())).toList();

    notifyListeners();
    
    _loading();
  }

  _loading(){
    isLoading = !isLoading;
  }
}