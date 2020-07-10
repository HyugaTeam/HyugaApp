import 'package:flutter/material.dart';

class PlaceListProfile extends StatelessWidget {
  final String _image;
  final String _name;
  final String _street;
  final int _price;

  PlaceListProfile(this._image, this._name, this._street, this._price);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210.0,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            bottom: 15.0,
            child: Container(
              height: 120.0,
              width: 220.0,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _name,
                        style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2),
                      ),
                      Text(_street),
                    ]),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0.0, 2.0),
                    blurRadius: 6.0),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image(
                height: 180.0,
                width: 180.0,
                image: AssetImage(_image),
                fit: BoxFit.cover, //look into this
              ),
            ),
          )
        ],
      ),
    );
  }
}
