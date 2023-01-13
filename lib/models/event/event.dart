import 'package:cloud_firestore/cloud_firestore.dart';

class Event{
  String id;
  String content;
  String title;
  String name;
  String organiserName;
  String locationName;
  GeoPoint location;
  DateTime dateCreated;
  DateTime? dateEnd;
  DateTime dateStart;
  // DocumentReference placeRef;
  DocumentReference ref;
  String photoUrl;
  Map<String, dynamic> originalPrices;
  Map<String, dynamic> prices;
  bool? favourite;
  String mainCategory;

  Event({
    required this.id,
    required this.content,
    required this.title,
    required this.name,
    required this.organiserName,
    required this.locationName,
    required this.location,
    required this.dateCreated,
    required this.dateStart,
    this.dateEnd,
    // required this.placeRef,
    required this.photoUrl,
    required this.originalPrices,
    required this.prices,
    required this.favourite,
    required this.ref,
    required this.mainCategory,
  });
}

Event docToEvent(DocumentSnapshot<Map<String, dynamic>> doc){
  var data = doc.data()!;
    return Event(
      id: data['id'],
      title: data['title'],
      content: data['content'],
      name: data['name'],
      organiserName: data['organiser_name'],
      locationName: data['location_name'],
      location: data['location'],
      dateCreated: data['date_created'].toDate(),
      dateStart: data['date_start'].toDate(),
      dateEnd: data['date_end'].toDate(),
      // placeRef: data['place_ref'],
      photoUrl: data['photo_url'],
      originalPrices: data['original_prices'],
      prices: data['prices'],
      favourite: false,
      ref: doc.reference,
      mainCategory: data['main_category']
    );
  }