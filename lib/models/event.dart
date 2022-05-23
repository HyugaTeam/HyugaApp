import 'package:cloud_firestore/cloud_firestore.dart';

class Event{
  String content;
  String title;
  DateTime dateCreated;
  DateTime dateStart;
  DocumentReference placeRef;
  String photoUrl;

  Event({
    required this.content,
    required this.title,
    required this.dateCreated,
    required this.dateStart,
    required this.placeRef,
    required this.photoUrl
  });
}