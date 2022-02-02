import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Local{
  final int? score; // Dynamic (depends on the score of the category)
  final String? id; // Imported from the database
  final String? name; // Imported from the database
  final Future<Image>? image; // Imported from the database
  final String? description; // Imported from the database
  final GeoPoint? location; // Imported from the database
  final int? cost; // Imported from the database
  final int? capacity;
  final Map<String,dynamic>? discounts;
  //final Future<List<Uint8List>> images; // The Local images from Firebase Storage
  final Future<String>? address; // The Street&No of the Local
  /// A reference to the 'users/{usersId}/managed_local/{managed_local}' in the database
  /// Contains some data about the place, and the 'reservations' and 'scanned_codes' subcollections. 
  final DocumentReference? reference;
  final Map<String,dynamic>? schedule;
  final Map<String,dynamic>? deals;
  final String? menu; // A link to a webpage containing the Place's menu
  final bool? hasOpenspace;
  final bool? hasReservations;
  final bool? isPartner;
  final bool? preferPhone;
  final int? phoneNumber;
  final String? tipMessage;
  Image? finalImage;

  Local({
    this.cost,
    this.score, 
    this.id,
    this.name,
    this.image,
    this.description,
    this.location,
    this.capacity,
    this.discounts,
    //this.images,
    this.address,
    this.reference,
    this.schedule,
    this.deals,
    this.menu,
    this.hasOpenspace,
    this.hasReservations,
    this.isPartner,
    this.preferPhone,
    this.phoneNumber,
    this.tipMessage
  }){
    image!.then((image) => finalImage = image);
  }
}