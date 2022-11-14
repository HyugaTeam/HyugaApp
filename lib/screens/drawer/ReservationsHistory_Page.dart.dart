import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:intl/intl.dart';

class ReservationsHistoryPage extends StatelessWidget {

  final Map<String,String> weekdaysTranslate = {"Monday" : "Luni", "Tuesday" : "Marti","Wednesday" : "Miercuri","Thursday" : "Joi","Friday" : "Vineri","Saturday" : "Sambata", "Sunday" : "Duminica"};
  final int currentWeekday = DateTime.now().toLocal().weekday;
  int itemCount = 0;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Color getDealColor(Deal deal){
    if(deal.title!.toLowerCase().contains("alb"))
      return Color(0xFFCFBA70);
      //return Theme.of(context).highlightColor;
    else if(deal.title!.toLowerCase().contains("roșu") || deal.title!.toLowerCase().contains("rosu"))
      return Color(0xFF600F2B);
      //return Theme.of(context).primaryColor;
    else return Color(0xFFb78a97);
    //return Theme.of(context).accentColor;
  }

  Column getDeals(reservation){
    //print(place['deals'][0]);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          alignment: Alignment(-1,0),
          child: Text(
            "Oferte",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          )
        ),
        Container( /// The list of deals & discounts
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          width: double.infinity,
          height: 145,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: reservation['deals'] != null ?  
                      (reservation['deals'] != null? 
                        reservation['deals'].length : 0): 
                      0,
            separatorBuilder: (BuildContext context, int index) => SizedBox(width: 20,),
            itemBuilder: (context,index) { 
              Deal deal = Deal(
                title: reservation['deals'][index]['title'], 
                content: reservation['deals'][index]['content'], 
                interval: reservation['deals'][index]['interval']
              );
              return Container(
                margin: EdgeInsets.all(7),
                //padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 0,
                      offset: Offset(0, 0), // changes position of shadow
                    ),
                  ]
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      child: Container(
                        padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                        height: 50,
                        width: double.infinity,
                        color: getDealColor(deal),
                        //color: Theme.of(context).accentColor,
                        child: Text(
                          reservation['deals'][index]['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14*(1/MediaQuery.of(context).textScaleFactor)
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "consumație minimă:\n" 
                        +
                        (reservation['deals'][index].containsKey('threshold')
                        ? reservation['deals'][index]['threshold']
                        : "*click*"),
                        //widget.local!.deals![weekdays.keys.toList()[currentWeekday]!.toLowerCase()][index]['interval'],
                        style: TextStyle(
                          fontSize: 14*(1/MediaQuery.of(context).textScaleFactor)
                        )
                      )
                    )
                  ],
                ),
                height: 125,
                width: 120,
              );
              // return OpenContainer(  
              //   closedColor: Colors.transparent,
              //   closedElevation: 0,
              //   openElevation: 0,
              //   closedShape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.zero
              //   ),
              //   openBuilder: (context, f) => 
              //     DealItemPage(
              //     place:  queryingService.docSnapToLocal(reservation),
              //     deal: deal,
              //     dealDayOfTheWeek: currentWeekday,
              //   ),
              //   closedBuilder: (context, f) => GestureDetector(
              //     child: Container(
              //       margin: EdgeInsets.all(7),
              //       //padding: EdgeInsets.all(8),
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(20),
              //         color: Colors.white,
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.grey.withOpacity(0.5),
              //             spreadRadius: 0,
              //             blurRadius: 0,
              //             offset: Offset(0, 0), // changes position of shadow
              //           ),
              //         ]
              //       ),
              //       child: Column(
              //         children: [
              //           ClipRRect(
              //             borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              //             child: Container(
              //               padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              //               height: 50,
              //               width: double.infinity,
              //               color: getDealColor(deal),
              //               //color: Theme.of(context).accentColor,
              //               child: Text(
              //                 reservation['deals'][index]['title'],
              //                 style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 14*(1/MediaQuery.of(context).textScaleFactor)
              //                 ),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             padding: EdgeInsets.all(10),
              //             child: Text(
              //               "consumație minimă:\n" 
              //               +
              //               (reservation['deals'][index].containsKey('threshold')
              //               ? reservation['deals'][index]['threshold']
              //               : "*click*"),
              //               //widget.local!.deals![weekdays.keys.toList()[currentWeekday]!.toLowerCase()][index]['interval'],
              //               style: TextStyle(
              //                 fontSize: 14*(1/MediaQuery.of(context).textScaleFactor)
              //               )
              //             )
              //           )
              //         ],
              //       ),
              //       height: 125,
              //       width: 120,
              //     ),
              //     onTap: f,
              //   ),
              // );
            }
          ),
        ),
      ],
    );
  }


  Future<Map<String,dynamic>?> getUpcomingReservations() async{
     QuerySnapshot scanHistory = await _db.collection('users')
    .doc(authService.currentUser!.uid).collection('reservations_history')
    .where('date_start',isGreaterThan: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .where('claimed', isNull: true)     
    .get();
    itemCount = scanHistory.docs.length;
    bool allAreDenied = true;
    DocumentSnapshot? reservation;
    scanHistory.docs.forEach((element) {
      if((element.data() as Map)['accepted'] != false){
        reservation = element;
        allAreDenied = false;
      }
    });
    print(reservation);
    if(allAreDenied) return null;

    return reservation!.data() as FutureOr<Map<String, dynamic>?>;
  }

  Future<List> getPastReservations() async {
    QuerySnapshot scanHistory = await _db.collection('users')
    .doc(authService.currentUser!.uid).collection('reservations_history')
    .where('date_start', isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal())) 
    .get();
    itemCount = scanHistory.docs.length;
    var pastReservationsList = scanHistory.docs.map((doc)=>doc.data()).toList();
    pastReservationsList.sort((dynamic place1, dynamic place2) => place2!['date_start'].compareTo(place1!['date_start']));
    return pastReservationsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Rezervări",
          style: TextStyle(
            fontSize: 20*(1/MediaQuery.of(context).textScaleFactor),
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: getUpcomingReservations(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>?> reservation){
              Map<String, dynamic>? reservationData = reservation.data;
              print(reservationData);
              if(!reservation.hasData )
                return Container();
              else {
                DateTime dateStart = DateTime.fromMillisecondsSinceEpoch(reservationData!['date_start'].millisecondsSinceEpoch);
                return ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Text(
                        "Rezervari viitoare",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Container( /// Get future reservations
                      color: Colors.blueGrey.withOpacity(0.5),
                      height: 200,
                      width: 200,
                      child: Stack(
                        children: [
                          Align( /// The place's image
                            alignment: Alignment.centerLeft,
                            child: FutureBuilder<Image>(
                              future: queryingService.getImage(reservationData['place_id']),
                              builder: (context, image){
                                if(!image.hasData)
                                  return Container(
                                    width: 300,
                                    height: 200,
                                  );
                                else return image.data!;
                              },
                            ),
                          ),
                          Positioned(
                            child: Container(
                              height: 200,
                              width: 300,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent,Colors.black54]
                                )
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Column(
                              children: [
                                Text(
                                  weekdaysTranslate[DateFormat("EEEE").format(dateStart)]! 
                                  + ',\n' + 
                                  DateFormat("dd MMM").format(dateStart),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  "Ora: "
                                  + DateFormat("HH:mm").format(dateStart),
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                )
                              ],
                            )
                          ),
                          Positioned(
                            left: 10,
                            bottom: 15,
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.75,
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      reservation.data!['place_name'],
                                      style: TextStyle(
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0,1)
                                          ),
                                          Shadow(
                                            offset: Offset(-1,0)
                                          )
                                        ],
                                        fontSize: reservation.data!['place_name'].length < 27 ? 20 :19,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    indent: 10,
                                  ),
                                  ClipOval(
                                    child: Container(
                                      color: Colors.white,
                                      height: 7,
                                      width: 7
                                    ),
                                  ),
                                  Divider(
                                    indent: 10,
                                  ),
                                  Container(
                                    child: Text(
                                      reservation.data!['accepted'] == null
                                      ? "in asteptare"
                                      : (reservation.data!['accepted'] == true ? "confirmata" : "") ,
                                      style: TextStyle(
                                        color: reservation.data!['accepted'] == null
                                        ? Colors.yellow
                                        : (reservation.data!['accepted'] == true ? Colors.green : Colors.transparent ) ,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ),
                  ],
                );
              }
            },
          ),
          Container(  /// Get past reservations
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width*0.05,
              vertical: MediaQuery.of(context).size.height*0.01
            ),
            color: Colors.grey[300],
            child: Text("Istoric rezervări"),
          ),
          FutureBuilder<List>(
              future: getPastReservations(),
              builder:(context, reservationsHistory){ 
                if(!reservationsHistory.hasData)
                  return Center(child: LoadingAnimation());
                else if(reservationsHistory.data!.length == 0)
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        Text("Nu ai rezervari trecute."),
                      ],
                    ),);
                else
                  return  Container( /// The past reservations list
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height*0.03, vertical: MediaQuery.of(context).size.width*0.05),
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: reservationsHistory.data!.length,
                      separatorBuilder: (context,index) => SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (context, index){
                        return GestureDetector(
                          onTap: (){
                            Future<Image>? placeImage;
                            try{
                              placeImage = queryingService.getImage(reservationsHistory.data![index]['place_id']);
                            }
                            catch(e){}
                            // Shows a pop-up containing the details about the bill
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context, builder: (context) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)
                                  )
                                ),
                                //height: MediaQuery.of(context).size.height*0.75,
                                child: Scaffold(
                                  body: ListView(
                                    children: [
                                      GestureDetector( // When the image is tapped, it pushes the ThirdPage containing the place
                                        onTap: () async {
                                          await _db
                                          .collection('locals_bucharest').doc(reservationsHistory.data![index]['place_id'])
                                          .get().then((value) => 
                                          Navigator.pushNamed(
                                            context,
                                            '/third',
                                            /// The first argument stands for the actual 'Local' information
                                            /// The second argument stands for the 'Route' from which the third page came from(for Analytics purpose)
                                            arguments: [queryingService.docSnapToLocal(value),false] 
                                          ));
                                        },
                                        child: Stack(
                                          children: [
                                            Container( // The place's profile image
                                              color: Colors.grey[100],
                                              width: double.infinity,
                                              height: 300,
                                              constraints: BoxConstraints(
                                                maxHeight: 300
                                              ),
                                              child: FutureBuilder<Image>(
                                                future: placeImage,
                                                builder: (context,image){
                                                  if(!image.hasData)
                                                    return CircularProgressIndicator();
                                                  else
                                                    return image.data!;
                                                }
                                              ),
                                            ),
                                            Container(
                                              height: 300,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [Colors.transparent,Colors.black87]
                                                )
                                              ),
                                            ),
                                            Positioned(
                                              left: 25,
                                              bottom: 25,
                                              width: 300,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Rezervare la:",
                                                    style: TextStyle(
                                                      color: Colors.orange[600]
                                                    )
                                                  ),
                                                  Text(
                                                    reservationsHistory.data![index]['place_name'], 
                                                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              )
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20,),
                                      reservationsHistory.data![index]['claimed'] == true
                                      ? Container(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                            children:[
                                              TextSpan(text: "Valoare finala bon: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                              TextSpan(text: reservationsHistory.data![index]['total'].toString()+"RON")
                                            ]
                                          ), 
                                        ),
                                      )
                                      : Container(),
                                      SizedBox(height: 20,),
                                      // Container(
                                      //   padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                      //   child: RichText(
                                      //     text: TextSpan(
                                      //       style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                      //       children:[
                                      //         TextSpan(text: "Discount: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                      //         TextSpan(text: reservationsHistory.data![index]['discount'].toString() + "%")
                                              
                                      //       ]
                                      //     ), 
                                      //   ),
                                      // ),
                                      getDeals(reservationsHistory.data![index]),
                                      SizedBox(height: 20,),
                                      Container(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                            children:[
                                              TextSpan(text: "Număr persoane: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                              TextSpan(
                                                text: reservationsHistory.data![index]['number_of_guests'] != null 
                                                ? reservationsHistory.data![index]['number_of_guests'].toString()
                                                : 1 as String?
                                              )
                                            ]
                                          ), 
                                        ),
                                      ),
                                      SizedBox(height: 20,),
                                      Container(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                            children:[
                                              TextSpan(text: "Data: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                              TextSpan(
                                                text: 
                                                DateTime.fromMillisecondsSinceEpoch(reservationsHistory.data![index]['date_start'].millisecondsSinceEpoch).toString()
                                              )
                                            ]
                                          ), 
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                              child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45, 
                                    offset: Offset(1.5,1),
                                    blurRadius: 2,
                                    spreadRadius: 0.2
                                  )
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Container( // The background image of the List Tile
                                      height: 225,
                                      width: 400,
                                      child: FutureBuilder<Image>(
                                        future: queryingService.getImage(reservationsHistory.data![index]['place_id']),
                                        builder: (context, image) {
                                          if(!image.hasData)
                                            return Container(); 
                                          else return image.data!;
                                        }
                                      ),
                                    ),
                                  Container( // The Gradient over the image
                                      height: 225,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent,Colors.black87]
                                        )
                                      ),
                                    ),
                                  Positioned(
                                    height: 300,
                                    bottom: 15,
                                    left: 15,
                                    child: Container(

                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        verticalDirection: VerticalDirection.up,
                                        children: [ 
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.9,
                                            child: Row(
                                              
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth: MediaQuery.of(context).size.width*0.6,
                                                    ),
                                                    child: Text(
                                                      //"Trattoria Buongiorno Covaci",
                                                      reservationsHistory.data![index]['place_name'],
                                                      style: TextStyle(
                                                        wordSpacing: 0.1,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 24,
                                                        color: Colors.white
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ),
                                                Divider(
                                                  indent: 10,
                                                ),
                                                ClipOval(
                                                  child: Container(
                                                    color: Colors.white,
                                                    height: 7,
                                                    width: 7
                                                  ),
                                                ),
                                                Divider(
                                                  indent: 10,
                                                ),
                                                reservationsHistory.data![index]['total'] != null
                                                ? Flexible(
                                                  child: Text(
                                                    reservationsHistory.data![index]['total'] == reservationsHistory.data![index]['total'].toDouble()
                                                      ? reservationsHistory.data![index]['total'].toDouble().toString()+" RON"
                                                      : reservationsHistory.data![index]['total'] +" RON",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                )
                                                : Container()
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(top: 5, bottom: 8),
                                            child: Text(
                                              /// A formula which converts the Timestamp to Date format
                                              'Data: ' + DateTime.fromMillisecondsSinceEpoch(reservationsHistory.data![index]['date_start'].millisecondsSinceEpoch, isUtc: true).toLocal().toString()
                                              .substring(0,16),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange[600]
                                              ),
                                            ),
                                          ),
                                          /// Reservation's status
                                          // Container(
                                          //   padding: const EdgeInsets.only(top: 5),
                                          //   child: Text(
                                          //     reservationsHistory.data![index]['accepted'] == true
                                          //     ? (
                                          //       reservationsHistory.data![index]['claimed'] == true
                                          //       ? "Revendicata"
                                          //       : "Nerevendicata"
                                          //     )
                                          //     : "Refuzata"
                                          //     ,
                                          //     style: TextStyle(
                                          //       fontSize: 17,
                                          //       color: reservationsHistory.data![index]['accepted'] == true
                                          //     ? (
                                          //       reservationsHistory.data![index]['claimed'] == true
                                          //       ? Colors.green
                                          //       : Colors.red
                                          //     )
                                          //     : Colors.yellow
                                          //     )
                                          //   )
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    )
                  );
              },
            ),
        ],
      ),
    ) ;
  }
}