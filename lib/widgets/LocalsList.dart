import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:shimmer/shimmer.dart';

import 'Place_List_profile.dart';

/// A class which renders the list of queried locals
class Locals extends StatefulWidget {

  // Used by the DiscountLocals_Page in order to obtain only the Places with Discounts 
  final bool onlyWithDiscounts;
  Locals({this.onlyWithDiscounts});
  @override
  _LocalsState createState() => _LocalsState();
}

class _LocalsState extends State<Locals> {

  DateTime today = DateTime.now().toLocal();
  static const List<Map<String, Object>> _discounts = [
    {
      'maxim' : 15,
      'pe_nivel' : [10, 10, 12.5, 14, 14.5, 15]
    },
    {
      'maxim' : 20,
      'pe_nivel' : [12.5, 12.5, 15, 16.5, 18, 20]
    },
    {
      'maxim' : 25,
      'pe_nivel' : [15, 15, 17.5, 20, 22.5, 25]
    },
    {
      'maxim' : 30,
      'pe_nivel': [15, 15, 20, 22.5, 25, 30]
    },
    { 'maxim' : 35,
      'pe_nivel' : [17.5, 17.5, 25, 30, 32.5, 35]
    },
    {
      'maxim' : 40,
      'pe_nivel' : [25, 25, 30, 32.5, 35, 40]
    },
    {
      'maxim' : 45,
      'pe_nivel' : [30, 30, 35, 37.5, 40, 45]
    },
    {
      'maxim' : 50,
      'pe_nivel' : [40, 40, 45, 50, 50, 50]
    },
  ];

  int getDiscountForUser(int maxDiscount){
    double discount;
    _discounts.firstWhere((element) => element['maxim']);
  }

  double getMaxDiscountForUser(Local local){

    if(local.discounts != null)
      if(local.discounts[DateFormat('EEEE').format(today).toLowerCase()] != null){
      double maxDiscountToday = 0 ;
      for(int i = 0 ;i < local.discounts[DateFormat('EEEE').format(today).toLowerCase()].length;i ++){
        if(double.parse(local.discounts[DateFormat('EEEE').format(today).toLowerCase()][i].substring(12,14)) > maxDiscountToday)
          maxDiscountToday = double.parse(local.discounts[DateFormat('EEEE').format(today).toLowerCase()][i].substring(12,14));
      }
      List<num> userDiscounts = g.discounts.firstWhere((element) => element['maxim'] == maxDiscountToday)['per_level'];
      return userDiscounts.reduce(max).toDouble();
    }
  }

  Future refresh(){
    // setState(() {
    //   widget.createState();
    // });
    //(context as Element).reassemble();
    return Future((context as Element).reassemble);
    
  }
 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: queryingService.fetch(widget.onlyWithDiscounts),
      builder:(context,locals){
        if(!locals.hasData)
          return Center(child: CircularProgressIndicator(),);
        else if(locals.data.length == 0)
          return Center(
            child: Text("Sorry, there are no result.\nTry looking for something else.")
          );
          else return RefreshIndicator(
            displacement: 50,
            onRefresh: refresh,
            child: Container(
            //color: Colors.grey[300],
            color: Colors.white,
            padding: EdgeInsets.only(
              //top: 30,
              left: 5,
              right: 5
            ),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), 
              itemCount: locals.data.length,
              // separatorBuilder: (context, separatorIndex){
              //   return SizedBox(height: 15,);
              // },
              itemBuilder: (BuildContext context, int index) {
                Local local = locals.data[index];
                //Address tempAddress = Address();
                PlaceListProfile place = PlaceListProfile(
                  name: local.name, address: local.address, image: local.image, price: local.cost, discount: getMaxDiscountForUser(local),
                  distance: queryingService.getLocalLocation(LengthUnit.Meter,local.location) > 1000 
                  ? queryingService.getLocalLocation(LengthUnit.Kilometer,local.location).toInt().toString() 
                  + '.' + ((queryingService.getLocalLocation(LengthUnit.Meter,local.location)/100%10).toInt()).toString()
                  :'0.' + ((queryingService.getLocalLocation(LengthUnit.Meter,local.location)/100%10).toInt()).toString()
                  ,onTap: (){
                  Navigator.pushNamed(
                      context,
                      '/third',
                      arguments: locals.data[index]
                  );
                },
                );
                 return place;
//                return Column(
//                  children: <Widget>[
//                    Container(
//                      decoration: BoxDecoration(
//                        //color: Theme.of(context).backgroundColor,
//                        //color: Colors.grey[300]
//                      ),
//                      child:  Stack(
//                        children: <Widget>[
//                          Container(
//                            padding: EdgeInsets.symmetric(horizontal: 20),
//                          //onPressed: (){},
//                          child: Column(
//                            children: <Widget>[
//                              Container(
//                                width: 400,
//                                height: 20,
//                              ),
//                              Container( // The Main Image
//                                //color: Colors.blue,
//                                width: 400,
//                                height: 210,
//                                child: FutureBuilder(
//                                  future: (locals.data[index]).image,
//                                  builder: (context,img){
//                                    if(!img.hasData)
//                                      return Container(
//                                        width: 400,
//                                        height: 200,
//                                        child: Shimmer.fromColors(
//                                          child: Container(),
//                                          baseColor: Colors.white,
//                                          highlightColor: Colors.grey
//                                        ),
//                                      );
//                                    else
//                                      return Container(
//                                        color: Colors.transparent,
//                                        child: img.data
//                                      );
//                                  }
//                                ),
//                              ),
//                              Container( // Text's container
//                                decoration: BoxDecoration(
//                                  color: Colors.blueGrey,
//                                ),
//                                padding: EdgeInsets.only(
//                                  top: 8,
//                                  bottom: 8,
//                                  left: 20
//                                ),
//                                child: Row(
//                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                  children: <Widget>[
//                                    Text( // 'Name' text
//                                        locals.data[index].name != null ? locals.data[index].name: 'null',
//                                        style: TextStyle(
//                                          shadows: [ Shadow(
//                                            blurRadius: 2,
//                                            color: Colors.black,
//                                            offset: Offset(0.7,0.7)
//                                            ),
//                                          ],
//                                          fontSize: 20,
//                                          letterSpacing: 0.4,
//                                          fontWeight: FontWeight.values[4],
//                                          color: Colors.white,
//                                          fontFamily: 'Roboto'
//                                        ),
//                                      ),
//                                  Text(
//                                    '${queryingService.getLocalLocation(locals.data[index].location)}' + 'km',
//                                    style: TextStyle(
//                                      fontSize: 18,
//                                      color: Colors.white
//                                    ),
//                                  )
//                                  ],
//                                ),
//                                alignment: Alignment(-1, -1),
//                              ),
//                            ],
//                            )
//                        ),
//                        Positioned(
//                          bottom: 0,
//                          right: 23,
//                          left: 23,
//                          child: Opacity(  // The InkWell responsible for the splash effect
//                            opacity: 0.2,
//                            child: Material(
//                              type: MaterialType.button,
//                              color: Colors.transparent,
//                              child: InkWell(
//                                onTap: (){
//                                  Navigator.pushNamed(
//                                    context,
//                                    '/third',
//                                    arguments: locals.data[index]
//                                  );
//                                  print('////////////');
//                                },
//                                splashColor: Colors.orange[600],
//                                child: Container(
//                                  alignment: Alignment.bottomCenter,
//                                  width: 349,
//                                  height: 250
//                                )
//                              )
//                            ),
//                          ),
//                        ),
//                        Positioned( // The price range icon
//                          right: 0,
//                          top: 0,
//                          child: getMaxDiscountForUser(locals.data[index]) != null? Container(
//                            alignment: Alignment.center,
//                            decoration: BoxDecoration(
//                              color: Colors.orange[600],
//                              borderRadius: BorderRadius.circular(30)
//                            ),
//                            child: FloatingActionButton(
//                              backgroundColor: Colors.orange[600],
//                              onPressed: (){
//                                if(g.isSnackBarActive == false){
//                                  g.isSnackBarActive = true;
//                                  Scaffold.of(context).showSnackBar(
//                                    SnackBar(
//                                      backgroundColor: Colors.orange[600],
//                                      content: Text("The maximum discount today, check the restaurant for the exact hours"),
//                                    )
//                                  ).closed.then((value) => g.isSnackBarActive = false);
//                                }
//                              },
//                              child: Text(
//                                '-' + getMaxDiscountForUser(locals.data[index]).toString() + '%',
//                                style: TextStyle(color: Colors.white),
//                              ),
//                            )
//                          ) : Container()
//                        ),
//                        // Positioned(  // 'Add to favorites button'
//                        //   right:0,
//                        //   top: 0,
//                        //   child: FloatingActionButton(
//                        //     hoverElevation: 0,
//                        //     heroTag: null, // Added to prevent "There are multiple heroes that share the same tag within a subtree."
//                        //     elevation: 1,
//                        //     backgroundColor: Colors.orange[600],
//                        //     child: FaIcon(FontAwesomeIcons.plus),
//                        //     onPressed: (){
//                        //       if(g.isSnackBarActive == false){
//                        //         g.isSnackBarActive = true;
//                        //         Scaffold.of(context).showSnackBar(SnackBar(
//                        //           backgroundColor: Colors.orange[600],
//                        //           content: Text("Added to favorites."),
//                        //         )).closed.then((reason){
//                        //           g.isSnackBarActive = false;
//                        //         });
//                        //       }
//                        //     },
//                        //   ),
//                        // ),
//                        Positioned( // The discounts list
//                          bottom: 40,
//                          left: 20, /// TODO: Temporary position ajustement, CHANGE this in the future
//                          child: Container(
//                            //color: Colors.red,
//                            constraints: BoxConstraints(
//                              maxWidth: 350,
//                              maxHeight: 70,
//                            ),
//                            child: ListView.builder(
//                              shrinkWrap: true,
//                              itemExtent: 128, /// Added to add some space between the tiles
//                              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
//                              scrollDirection: Axis.horizontal,
//                              itemCount: locals.data[index].discounts != null ?
//                                          (locals.data[index].discounts[DateFormat('EEEE').format(today).toLowerCase()] != null?
//                                            locals.data[index].discounts[DateFormat('EEEE').format(today).toLowerCase()].length : 0):
//                                          0,
//                              /// ^^^ This comparison checks if in the 'discounts' Map field imported from Firebase exist any discounts related to
//                              /// the current weekday. If not, the field will be empty
//                              itemBuilder: (BuildContext context, int discountIndex){
//                                return Column(
//                                  children: <Widget>[
//                                    GestureDetector(
//                                      onTap: (){
//                                        if(g.isSnackBarActive == false){
//                                          g.isSnackBarActive = true;
//                                          Scaffold.of(context).showSnackBar(
//                                            SnackBar(
//                                              content: Text(
//                                                "Scan your code in your preferred time interval and receive the discount.",
//                                                textAlign: TextAlign.center,
//                                              ),
//                                              backgroundColor: Colors.orange[600],
//                                            )).closed.then((SnackBarClosedReason reason){
//                                            g.isSnackBarActive = false;
//                                          });
//                                        }
//                                      },
//                                      child: Container(
//                                        alignment: Alignment.center,
//                                        height: 30,
//                                        width: 120,
//                                        decoration: BoxDecoration(
//                                          boxShadow: [
//                                            BoxShadow(
//                                              color: Colors.black45,
//                                              offset: Offset(1.5,1),
//                                              blurRadius: 2,
//                                              spreadRadius: 0.2
//                                            )
//                                          ],
//                                          color: Colors.orange[600],
//                                          borderRadius: BorderRadius.circular(25)
//                                        ),
//                                        child: Text(
//                                          locals.data[index].discounts[DateFormat('EEEE').format(today).toLowerCase()]
//                                          [discountIndex].substring(0,5)
//                                          + ' - ' +
//                                          locals.data[index].discounts[DateFormat('EEEE').format(today).toLowerCase()]
//                                          [discountIndex].substring(6,11),
//                                          style: TextStyle(
//                                            fontSize: 16,
//                                            fontFamily: 'Roboto'
//                                          ),
//                                        )  // A concatenation of the string representing the time interval
//                                      ),
//                                    ),
//                                    Padding(
//                                      padding: EdgeInsets.all(5),
//                                      child: Text(
//                                        locals.data[index].discounts[DateFormat('EEEE').format(today).toLowerCase()][discountIndex].substring(12,14) + '%',
//                                        style: TextStyle(
//                                          color: Colors.white,
//                                          fontSize: 15,
//                                          fontFamily: 'Roboto'
//                                        )
//                                        )
//                                    )
//                                  ],
//                                );
//                              }
//                            ),
//                          ),
//
//                        )
//                        ],
//                      )
//                    ),
//                    SizedBox(
//                      height:20
//                    )
//                  ],
//                );
              }
            )
          ),
        );
      }
    );
  }
}