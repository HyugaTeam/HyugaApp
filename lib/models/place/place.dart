import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Place{
  final int? score; // Dynamic (depends on the score of the category)
  final String? id; // Imported from the database
  final String name; // Imported from the database
  final Future<Image>? image; // Imported from the database
  final String? description; // Imported from the database
  final GeoPoint location; // Imported from the database
  final int? cost; // Imported from the database
  final int? capacity;
  final Map<String,dynamic>? discounts;
  //final Future<List<Uint8List>> images; // The Local images from Firebase Storage
  final String? address; // The Street&No of the Local
  /// A reference to the 'users/{usersId}/managed_local/{managed_local}' in the database
  /// Contains some data about the place, and the 'reservations' and 'scanned_codes' subcollections. 
  final DocumentReference? reference;
  final Map<String,dynamic>? schedule;
  final Map<String,dynamic>? deals;
  final String ambience;
  final List<dynamic>? types;
  final Map<String, dynamic>? menu; // A link to a webpage containing the Place's menu
  final bool? hasOpenspace;
  final bool? hasReservations;
  final bool? isPartner;
  final bool? preferPhone;
  final int? phoneNumber;
  final String? tipMessage;
  Image? finalImage;
  bool favourite = false;
  final String profileImageURL;
  final String? importantInformation;
  final String? area;

  Place({
    this.cost,
    this.score, 
    this.id,
    required this.name,
    this.image,
    this.description,
    required this.location,
    this.capacity,
    this.discounts,
    //this.images,
    this.address,
    this.reference,
    this.schedule,
    this.deals,
    this.menu,
    this.types,
    this.hasOpenspace,
    this.hasReservations,
    this.isPartner,
    this.preferPhone,
    this.phoneNumber,
    this.tipMessage,
    required this.favourite,
    required this.profileImageURL,
    required this.importantInformation,
    required this.ambience,
    required this.area
  }){
    image!.then((image) => finalImage = image);
  }
}

Place docToPlace(DocumentSnapshot<Map<String, dynamic>> doc){
  
  var profileImage = getImage(doc.id);
  Map<String, dynamic> data = doc.data()!;
  // print(data['name']);
  return Place(
    cost: data['cost'],
    score: data['score'],
    id: doc.id,
    image: profileImage,
    name: data['name'],
    location:data['location'],
    description: data['description'],
    capacity: data['capacity'],
    discounts: data['discounts'],
    address: data['address'] == null ? "" : data['address'] ,
    reference: data.containsKey('manager_reference') ? data['manager_reference']: null,
    schedule: data.containsKey('schedule') ? data['schedule']: null,
    deals: data.containsKey('deals') ? data['deals']: null,
    types: data.containsKey('types') ? data['types'] : [],
    menu: data.containsKey('menu') ? data['menu']: null,
    hasOpenspace: data.containsKey('open_space') ? data['open_space']: null,
    hasReservations: data.containsKey('reservations') ? data['reservations']: null,
    isPartner: data.containsKey('partner') ? data['partner']: false,
    preferPhone: data.containsKey('prefer_phone') ? data['prefer_phone'] : null,
    phoneNumber: data.containsKey('phone_number') ? data['phone_number'] : null,
    tipMessage: data.containsKey('tip_message') ? data['tip_message'] : null,
    favourite: false,
    profileImageURL: data.containsKey('profile_image_url') ? data['profile_image_url'] : null,
    importantInformation: data['important_information'],
    ambience: data['ambience'],
    area: data['area']
  );
}

// Obtains the images from Firebase Storage
  Future<Image> getImage(String? fileName) async {
      Uint8List? imageFile;
      int maxSize = 10*1024*1024;
      String pathName = 'photos/europe/bucharest/$fileName';
      print(pathName);
      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      imageFile = await storageRef.child('$fileName'+'_profile.jpg').getData(maxSize);
      // print(imageFile);
      return Image.memory(
        imageFile!,
        fit: BoxFit.fill,
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