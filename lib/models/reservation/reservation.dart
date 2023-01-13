import 'package:authentication/authentication.dart';

class Reservation{
  String id;
  List<dynamic>? deals;
  DateTime dateCreated;
  DateTime dateStart;
  String? guestId;
  String? guestName;
  String? placeId;
  String? placeName;
  int numberOfGuests;
  String? contactPhoneNumber;
  bool? accepted;
  bool? claimed;
  bool canceled;
  bool? active;
  DocumentReference userReservationRef;
  DocumentReference placeReservationRef;

  Reservation({
    required this.id,
    required this.dateCreated,
    required this.dateStart,
    required this.guestId,
    required this.guestName,
    required this.placeId,
    required this.placeName,
    required this.deals,
    required this.numberOfGuests,
    required this.contactPhoneNumber,
    required this.accepted,
    required this.active,
    required this.canceled,
    required this.claimed,
    required this.userReservationRef,
    required this.placeReservationRef,
  });
}

Reservation docToReservation(QueryDocumentSnapshot<Map<String, dynamic>> doc){
  Map<String, dynamic> data = doc.data();
  return Reservation(
    id: doc.id,
    deals: data['deals'],
    dateCreated: DateTime.fromMillisecondsSinceEpoch(data['date_created'].millisecondsSinceEpoch),
    dateStart: DateTime.fromMillisecondsSinceEpoch(data['date_start'].millisecondsSinceEpoch),
    numberOfGuests: data['number_of_guests'],
    accepted: data['accepted'],
    claimed: data['claimed'],
    active: data['active'],
    canceled: data['canceled'] == true ? true : false,
    guestId: data['guest_id'],
    guestName: data['guest_name'],
    placeId: data['place_id'],
    placeName: data['place_name'],
    contactPhoneNumber: data['contact_phone_number'],
    placeReservationRef: data['place_reservation_ref'] != null ? data['place_reservation_ref'] : doc.reference,
    userReservationRef: data['user_reservation_ref'] != null ? data['user_reservation_ref'] : doc.reference
  );
}

Reservation docWithIdAndDataAsArgsToReservation(String id, Map<String, dynamic> data, DocumentReference placeReservationRef, DocumentReference userReservationRef){
  return Reservation(
    id: id,
    deals: data['deals'],
    dateCreated: DateTime.fromMillisecondsSinceEpoch(data['date_created'].millisecondsSinceEpoch),
    dateStart: DateTime.fromMillisecondsSinceEpoch(data['date_start'].millisecondsSinceEpoch),
    numberOfGuests: data['number_of_guests'],
    accepted: data['accepted'],
    claimed: data['claimed'],
    active: data['active'],
    canceled: data['canceled'] == true ? true : false,
    guestId: data['guest_id'],
    guestName: data['guest_name'],
    placeId: data['place_id'],
    placeName: data['place_name'],
    contactPhoneNumber: data['contact_phone_number'],
    placeReservationRef: placeReservationRef,
    userReservationRef: userReservationRef
  );
}