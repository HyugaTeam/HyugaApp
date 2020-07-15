import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'dart:math';

//asta trebuie pusa intr-o clasa separata
class _InkWrapper extends StatelessWidget {
  final Color splashColor;
  final Color highlightColor;
  final Widget child;
  final VoidCallback onTap;

  _InkWrapper({
    this.splashColor,
    this.highlightColor,
    @required this.child,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              //splashFactory: null,
              highlightColor: highlightColor,
              splashColor: splashColor,
              //radius: 60,   //poate arata bine
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
}

//-------------------pana aici----------------------


///The rendered element in the 'Places' List on the Second Page
class PlaceListProfile extends StatelessWidget {
  //final String _image;

  final GeoPoint location;
  final Future<Image> image;
  final String name;
  final Future<Address> address;
  final String distance;
  final int price;
  final VoidCallback onTap;
  double discount = 0; //TREBUIE UN IF PENTRU discount 0


  PlaceListProfile(
      {this.address, this.location, this.image, this.name, this.distance, this.price, this.onTap,
        this.discount});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.blue,
      width: 400.0,
      height: 300,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            bottom: 20.0,
            child: Container(
              height: 120.0,
              width: 355.0,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black38),
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(7.0),
                          child: Text(
                            name,
                            style: TextStyle(
                                fontFamily: 'Comfortaa',
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.5, 1.5),
                                    color: Colors.black,
                                  )
                                ],
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2
                            ),),
                          ),
//                            FutureBuilder(
//                              future: address,
//                              builder:(context,  address){
//                                if(!address.hasData)
//                                  return Container(
//                                    child: Text('')
//                                  );
//                                else
//                                  return Text(
//                                    '',
//                                    style: TextStyle(
//                                      color: Colors.white,
//                                      shadows: [
//                                        Shadow(
//                                          offset: Offset(0.7, 1),
//                                          color: Colors.black,
//                                        ),
//                                        Shadow(
//                                          offset: Offset(-0.5, 0.7),
//                                          color: Colors.black,
//                                        ),
//                                      ],
//                                      fontWeight: FontWeight.w600,
//                                      fontStyle: FontStyle.italic,
//                                    ),
//                                  );
//                                },
//                            ),
                          ]),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            distance.toString() + 'km',
                            style: TextStyle(
                              color: Colors.white,
                              shadows: [
                                Shadow(offset: Offset(1, 0)),
                                Shadow(offset: Offset(0, 1.5)),
                              ],
                              fontSize: 17.5,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            //padding: EdgeInsets.only(left: 30,top: 8),
                            constraints: BoxConstraints(
                                maxWidth: 30,
                                maxHeight: 15
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: price,
                              itemBuilder: (context, costIndex) {
                                //return FaIcon(FontAwesomeIcons.dollarSign, color: Colors.lightGreenAccent, size: 16,);
                                return Text('\$', style: TextStyle(
                                    color: Colors.lightGreenAccent,
                                    fontSize: 16),);
                              },
                            ),
                          )
                        ],
                      ),
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
                    color: Colors.black54,
                    offset: Offset(2.0, 2.0),
                    blurRadius: 5.0),
                BoxShadow(
                    color: Colors.black54,
                    offset: Offset(-2.0, 2.0),
                    blurRadius: 4.0),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: _InkWrapper(
                  splashColor: Colors.orange[600].withOpacity(0.65),
                  highlightColor: Colors.black.withOpacity(0.1),
                  child: Container(
                    width: 325,
                    height: 220,
                    child: FutureBuilder(
                        future: image,
                        builder: (context, img) {
                          if (!img.hasData)
                            return Container(
                              width: 400,
                              height: 200,
                              child: Shimmer.fromColors(
                                  child: Container(),
                                  baseColor: Colors.white,
                                  highlightColor: Colors.grey
                              ),
                            );
                          else
                            return Container(
                                color: Colors.transparent,
                                child: img.data
                            );
                        }
                    ),
                  ),
//                  child: Image(
//                    height: 220.0,
//                    width: 325.0,
//                    image: AssetImage(_image),
//                    fit: BoxFit.cover, //look into this
//                  ),
                  onTap: onTap),
            ),
          ),
          Positioned( // The price range icon
              right: 0,
              top: 0,
              child: discount != null ? Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.orange[600],
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: FloatingActionButton(
                    backgroundColor: Colors.orange[600],
                    onPressed: () {
                      if (g.isSnackBarActive == false) {
                        g.isSnackBarActive = true;
                        Scaffold
                            .of(context)
                            .showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.orange[600],
                              content: Text(
                                  "The maximum discount today, check the restaurant for the exact hours"),
                            )
                        )
                            .closed
                            .then((value) => g.isSnackBarActive = false);
                      }
                    },
                    child: Text(
                      '-' + discount.toString() + '%',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
              ) : Container()
          ),
        ],
      ),
    );
  }
}

// child: ClipRRect(
//               borderRadius: BorderRadius.circular(20.0),
//               child: MaterialButton(
//                 padding: EdgeInsets.all(0),
//                 splashColor: Colors.orange[600],
//                 onPressed: () => print('Pressed'),
//                 child: InkWell(
//                   splashColor: Colors.orange[600],
//                   child: Image(
//                     height: 220.0,
//                     width: 325.0,
//                     image: AssetImage(_image),
//                     fit: BoxFit.cover, //look into this
//                   ),
//                 ),
//               ),
//             ),
// child: SizedBox(
//                   height: 220.0,
//                   width: 325.0,
//                   child: Ink(
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                           image: AssetImage(_image), fit: BoxFit.cover),
//                     ),
//                     child: InkWell(
//                       onTap: () {},
//                       splashColor: Colors.orange[600],
//                     ),
//                   )),
