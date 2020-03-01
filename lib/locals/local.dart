import 'package:flutter/material.dart';

class Local{
  final int id;
  final String name;
  final String imageUrl;

  Local({
    this.id,
    this.name,
    this.imageUrl
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
  name: 'hanulLuiManuc',
  imageUrl: 'assets/images/HanulLuiManuc.jpg',
);
Cafe bernschutz = Cafe(
  id: 2,
  name: 'bernschutz',
  imageUrl: 'assets/images/bernschutz.jpg',
);
Pub oktoberfest = Pub(
  id: 3,
  name: 'oktoberfest',
  imageUrl: 'assets/images/oktoberfest.jpg',
);
List<Restaurant> restaurantsList = [hanulLuiManuc];
List<Cafe> cafesList = [bernschutz];
List<Pub> pubsList = [oktoberfest];