import 'package:cloud_firestore/cloud_firestore.dart';

class Event{
  String content;
  String title;
  String name;
  String organiserName;
  DateTime dateCreated;
  DateTime dateStart;
  DocumentReference placeRef;
  String photoUrl;

  Event({
    required this.content,
    required this.title,
    required this.name,
    required this.organiserName,
    required this.dateCreated,
    required this.dateStart,
    required this.placeRef,
    required this.photoUrl
  });
}

Event docToEvent(Map<String, dynamic> data){
    return Event(
      title: data['title'],
      content: data['content'],
      name: data['name'],
      organiserName: data['organiser_name'],
      dateCreated: data['date_created'].toDate(),
      dateStart: data['date_start'].toDate(),
      placeRef: data['place_ref'],
      photoUrl: data['photo_url']
    );
  }