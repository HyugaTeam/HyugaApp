import 'package:flutter/material.dart';

// class Local extends StatelessWidget {
//   @override


//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(40)
//       ),
//     );
//   }
// }

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

var restaurants = new List<Restaurant>();