import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket{
  String id;
  String eventName;
  String eventId;
  String guestName;
  String guestId;
  int numberOfPeople;
  String? category;
  int originalPrice;
  int price;
  String email;
  String? cardLast4;
  DocumentReference? eventTicketRef;
  DocumentReference? userTicketRef;
  DateTime dateCreated;
  DateTime dateStart;
  DateTime dateEnd;
  String photoUrl;
  String eventLocationName;
  
  Ticket({
    required this.id,
    required this.eventName,
    required this.eventId,
    required this.guestName,
    required this.guestId,
    required this.numberOfPeople,
    required this.email,
    required this.cardLast4,
    required this.originalPrice,
    required this.price,
    required this.category,
    required this.dateCreated,
    required this.dateEnd,
    required this.dateStart,
    required this.eventTicketRef,
    required this.userTicketRef,
    required this.photoUrl,
    required this.eventLocationName
  });
}

Ticket docToTicket(QueryDocumentSnapshot<Map<String, dynamic>> doc){
  var data = doc.data();
  return Ticket(
    id: doc.id,
    email: data['email'],
    eventName: data['event_name'],
    eventId: data['event_id'],
    guestName: data['guest_name'],
    guestId: data['guest_id'],
    numberOfPeople: data['number_of_people'],
    category: data['category'],
    originalPrice: data['original_price'],
    price: data['price'],
    dateCreated: DateTime.fromMillisecondsSinceEpoch(data['date_created'].millisecondsSinceEpoch),
    dateStart: DateTime.fromMillisecondsSinceEpoch(data['date_start'].millisecondsSinceEpoch),
    dateEnd: DateTime.fromMillisecondsSinceEpoch(data['date_end'].millisecondsSinceEpoch),
    cardLast4: data['card_last_4'],
    eventTicketRef: data['event_ticket_ref'],
    userTicketRef: data['user_ticket_ref'],
    photoUrl: data['photo_url'],
    eventLocationName: data['event_location_name']
  );
}
/// Used in return upon booking a succesful ticket on payment page (since we don't have a document snapshot) 
Ticket docWithIdAndDataAsArgsToTicket(String id, Map<String, dynamic> data, DocumentReference eventTicketRef, DocumentReference userTicketRef){
  return Ticket(
    id: id,
    email: data['email'],
    eventName: data['event_name'],
    eventId: data['event_id'],
    guestName: data['guest_name'],
    guestId: data['guest_id'],
    numberOfPeople: data['number_of_people'],
    category: data['category'],
    originalPrice: data['original_price'],
    price: data['price'],
    dateCreated: DateTime.fromMillisecondsSinceEpoch(data['date_created'].millisecondsSinceEpoch),
    dateStart: DateTime.fromMillisecondsSinceEpoch(data['date_start'].millisecondsSinceEpoch),
    dateEnd: DateTime.fromMillisecondsSinceEpoch(data['date_end'].millisecondsSinceEpoch),
    cardLast4: data['card_last_4'],
    eventTicketRef: eventTicketRef,
    userTicketRef: userTicketRef,
    photoUrl: data['photo_url'],
    eventLocationName: data['event_location_name']
  );
}