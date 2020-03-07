import 'dart:io';
import 'package:flutter/material.dart';

class Local{
  final int id;
  final String name; // Imported from the database
  final String imageUrl; // Imported from the database
  final String description; 

  Local({
    this.id,
    this.name,
    this.imageUrl,
    this.description
  });
}

class Restaurant extends Local{
  @override
  final int id;
  final String name;
  final String imageUrl;

  Restaurant({
    this.id,
    this.name,
    this.imageUrl
  });
}
class Cafe extends Local{
  @override
  final int id;
  final String name;
  final String imageUrl;

  Cafe({
    this.id,
    this.name,
    this.imageUrl
  });
}
class Pub extends Local{
  @override
  final int id;
  final String name;
  final String imageUrl;

  Pub({
    this.id,
    this.name,
    this.imageUrl
  });
}


Restaurant hanulLuiManuc = Restaurant(
  id: 1,
  name: 'Hanul lui Manuc', 
  imageUrl: 'assets/images/HanulLuiManuc.jpg', 
);
Restaurant caruCuBere =  Restaurant(
  id: 2,
  name: "Caru' cu bere",
  imageUrl: 'assets/images/carucubere.jpg'
);
Restaurant hanuBerarilor = Restaurant(
  id:3,
  name : "Hanu' Berarilor",
  imageUrl: 'assets/images/hanuberarilor.jpg'
);

Cafe bernschutz = Cafe(
  id: 1,
  name: 'Bernschutz&Co',
  imageUrl: 'assets/images/bernschutz.jpg',
);
Cafe secondCup = Cafe(
  id: 2,
  name: 'Second Cup Universitate',
  imageUrl: 'assets/images/secondcup.jpg'
); 
Cafe cameraDinFata = Cafe(
  id:3,
  name: 'Camera din Fata',
  imageUrl: 'assets/images/cameradinfata.jpg'
);

Pub kulturhaus = Pub(
  id: 1,
  name: 'Kulturhaus Bukarest',
  imageUrl: 'assets/images/kulturhaus.jpg'
);
Pub silverChurch = Pub(
  id: 2,
  name: 'Silver Church',
  imageUrl: 'assets/images/silverchurch.jpg'
);
Pub oktoberfest = Pub(
  id: 3,
  name: 'Oktoberfest Pub',
  imageUrl: 'assets/images/oktoberfest.jpg',
);

List<Restaurant> restaurantsList = [hanulLuiManuc,caruCuBere,hanuBerarilor];
List<Cafe> cafesList = [bernschutz,secondCup,cameraDinFata];
List<Pub> pubsList = [oktoberfest,silverChurch,kulturhaus];
var localsList = [cafesList,restaurantsList,pubsList];