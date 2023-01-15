import 'package:authentication/authentication.dart';
import 'package:barcode_widget/barcode_widget.dart';
// import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
export 'package:provider/provider.dart';

class TicketPageProvider with ChangeNotifier{
  Event? event;
  bool isLoading = false;
  Ticket ticket;
  BarcodeWidget barcode;


  TicketPageProvider(this.ticket, this.barcode){
    getData();
  }

  Future<void> getData() async{
    _loading();

    await FirebaseFirestore.instance.collection('events').doc(ticket.eventId).get()
    .then((doc) => event = docToEvent(doc));

    // var barcode = Barcode.code39().toSvg(ticket.id, width: 200, height: 100);


    _loading();
    notifyListeners();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }
}