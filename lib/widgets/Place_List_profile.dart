import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
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
              highlightColor: highlightColor,
              splashColor: splashColor,
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
class PlaceListProfile extends StatefulWidget {

  final GeoPoint location;
  final Future<Image> image;
  final String name;
  final Future<String> address;
  final String distance;
  final int price;
  final VoidCallback onTap;
  double discount = 0;
  Image finalImage;
  final Local place;

  final BuildContext scaffoldContext;

  PlaceListProfile(
      {this.address,
      this.location,
      this.image,
      this.name,
      this.distance,
      this.price,
      this.onTap,
      this.discount,
      this.scaffoldContext,
      this.place
      }){
        image.then((image) => finalImage = image);
      }

  @override
  _PlaceListProfileState createState() => _PlaceListProfileState();
}

class _PlaceListProfileState extends State<PlaceListProfile> with AutomaticKeepAliveClientMixin{
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: 400.0,
      height: 310,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            bottom: 4,
            child: Container(
              height: 120.0,
              width: 355.0,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black38),
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width*0.025, 
                  top: 10, 
                  bottom: widget.name.length < 20? 5 : 0
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 270,
                            padding: EdgeInsets.only(
                                top: 7.0, 
                                bottom: MediaQuery.of(context).size.height*0.01, 
                                left: 7.0),
                            child: Text( // The Place's name
                              widget.name,
                              maxLines: 2,
                              style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.5, 1.5),
                                      color: Colors.black,
                                    )
                                  ],
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2),
                            ),
                          ),
                        ]),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.distance.toString() + 'km',
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
                            constraints:
                                BoxConstraints(maxWidth: 40, maxHeight: 20),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: widget.price,
                              itemBuilder: (context, costIndex) {
                                return Text(
                                  '\$',
                                  style: TextStyle(
                                      color: Colors.lightGreenAccent,
                                      fontSize: 16),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ]
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                // The spacer between the Places
                width: 400,
                height: 35,
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
                        width: min(325,MediaQuery.of(context).size.width*0.85),
                        height: 220,
                        child: Hero( /// The image Hero Widget
                          tag: widget.name,
                          child: FutureBuilder(
                              future: widget.image,
                              builder: (context, img) {
                                if(widget.finalImage == null)
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
                                    child: widget.finalImage
                                  );
                              }),
                        ),
                      ),
                      onTap: widget.onTap
                    ),
                ),
              ),
            ],
          ),
          Positioned(
              // The maximum discount bubble
              right: MediaQuery.of(context).size.width*0.5-min(200,MediaQuery.of(context).size.width*0.5),
              top: 0,
              child: widget.discount != null
                  ? Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: 1.25,
                        child: FloatingActionButton(
                          heroTag: widget.name+'_button',
                          backgroundColor: Colors.orange[600],
                          onPressed: () {
                            if (g.isSnackBarActive == false) {
                              Scaffold.of(widget.scaffoldContext)
                                  .showSnackBar(SnackBar(
                                    duration: Duration(seconds: 5),
                                    backgroundColor: Colors.orange[600],
                                    content: Text(
                                      "Reducerea maxima de astazi, intra pe restaurant pentru mai multe detalii"
                                    ),
                                  ))
                                  .closed
                                  .then((value) => g.isSnackBarActive = false);
                            }
                          },
                          child: Text(
                            '-' + widget.discount.toInt().toString() + '%',
                            style: TextStyle(
                              color: Colors.white,
                              shadows: [Shadow(offset: Offset(1.0, 1.0))],
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ))
                  : Container()),
        ],
      ),
    );
  }
}
