import 'package:flutter/cupertino.dart';

class MyClipper extends CustomClipper<Rect>{
  @override
  Rect getClip(Size size) {
    Rect rect = Rect.fromLTRB(0.0, 10, size.width, size.height*0.94);
    return rect;
  }
  @override
  bool shouldReclip(dynamic oldClipper) {
    return true;
  }
}