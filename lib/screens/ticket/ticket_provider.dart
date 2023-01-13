import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
export 'package:provider/provider.dart';

class TicketPageProvider with ChangeNotifier{
  Event? event;
  bool isLoading = false;
  Ticket ticket;

  TicketPageProvider(this.ticket){
    getData();
  }

  Future<void> getData() async{
    _loading();

    await FirebaseFirestore.instance.collection('events').doc(ticket.eventId).get()
    .then((doc) => event = docToEvent(doc));

    _loading();
    notifyListeners();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }
}