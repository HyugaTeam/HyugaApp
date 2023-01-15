import 'package:authentication/authentication.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:hyuga_app/models/models.dart';
export 'package:provider/provider.dart';

class HistoryPageProvider with ChangeNotifier{
  List<Reservation>? pastReservations;
  List<Reservation>? upcomingReservations;
  List<Ticket>? pastTickets;
  List<Ticket>? upcomingTickets;
  bool isLoading = false;
  ViewType viewType = ViewType.reservations;

  HistoryPageProvider(){
    getData();
  }

  Future<void> getData() async{
    _loading();

    /// Get past reservations
    await FirebaseFirestore.instance.collection("users").doc(Authentication.auth.currentUser!.uid).collection("reservations")
    .where('date_start', isLessThan: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .get()
    .then((query) => pastReservations = query.docs.map((doc) => docToReservation(doc)).toList());
    await FirebaseFirestore.instance.collection("users").doc(Authentication.auth.currentUser!.uid).collection("reservations")
    .where('date_start', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .where('canceled', isEqualTo: true)
    .get()
    .then((query) => pastReservations!.addAll(query.docs.map((doc) => docToReservation(doc)).toList()));
    await FirebaseFirestore.instance.collection("users").doc(Authentication.auth.currentUser!.uid).collection("reservations")
    .where('date_start', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .where('claimed', isEqualTo: true)
    .get()
    .then((query) => pastReservations!.addAll(query.docs.map((doc) => docToReservation(doc)).toList()));
    pastReservations!.sort((a, b) => b.dateStart.millisecondsSinceEpoch - a.dateStart.millisecondsSinceEpoch);

    /// Get upcoming reservations
    await FirebaseFirestore.instance.collection("users").doc(Authentication.auth.currentUser!.uid).collection("reservations")
    .where('date_start', isGreaterThan: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .get()
    .then((query) => upcomingReservations = query.docs.map((doc) => docToReservation(doc)).toList());
    upcomingReservations!.removeWhere((reservation) => reservation.accepted == false || reservation.canceled == true || reservation.claimed == true);
    upcomingReservations!.sort((a, b) => b.dateStart.millisecondsSinceEpoch - a.dateStart.millisecondsSinceEpoch);

    /// Get past tickets
    await FirebaseFirestore.instance.collection("users").doc(Authentication.auth.currentUser!.uid).collection("tickets")
    .where('date_end', isLessThan: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .get()
    .then((query) => pastTickets = query.docs.map<Ticket>((doc) => docToTicket(doc)).toList());

    /// Get upcoming tickets
    await FirebaseFirestore.instance.collection("users").doc(Authentication.auth.currentUser!.uid).collection("tickets")
    .where('date_end', isGreaterThan: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .get()
    .then((query) => upcomingTickets = query.docs.map<Ticket>((doc) => docToTicket(doc)).toList());

    _loading();

    notifyListeners();
  }

  Future<Image> getReservationImage(String id) async{
    var imageUrl = await FirebaseStorage.instance.ref("photos/europe/bucharest/$id/${id}_profile.jpg").getDownloadURL();
    
    return Image.network(
      imageUrl,
      alignment: FractionalOffset.topCenter,
      fit: BoxFit.cover,
      frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          child: child,
          opacity: frame == null ? 0 : 1,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    );
  }

  Image getTicketImage(String photoUrl){
    
    return Image.network(
      photoUrl,
      alignment: FractionalOffset.topCenter,
      fit: BoxFit.cover,
      frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          child: child,
          opacity: frame == null ? 0 : 1,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    );
  }

  void changeViewType() async{
    _loading();
    if(viewType == ViewType.reservations)
      viewType = ViewType.tickets;
    else viewType = ViewType.reservations;
    notifyListeners();
    _loading();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }
}


enum ViewType{
  reservations,
  tickets
}