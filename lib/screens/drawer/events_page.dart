import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/deal.dart';
import 'package:hyuga_app/models/event.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hyuga_app/globals/constants.dart';

class EventsPage extends StatefulWidget {

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  final Map<String,String> weekdaysTranslate = {"Monday" : "Luni", "Tuesday" : "Marti","Wednesday" : "Miercuri","Thursday" : "Joi","Friday" : "Vineri","Saturday" : "Sambata", "Sunday" : "Duminica"};
  int itemCount = 0;

  Event _docToEvent(Map<String, dynamic> data){
    return Event(
      title: data['title'],
      content: data['content'],
      dateCreated: data['date_created'].toDate(),
      dateStart: data['date_start'].toDate(),
      placeRef: data['place_ref']
    );
  }

  /// Fetches the upcoming events from the database
  Future<List<Event>> _getUpcomingEvents() async{
    QuerySnapshot query = await FirebaseFirestore.instance.collection('events')
    .where('date_start',isGreaterThan: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .get();
    // setState(() {
    //   itemCount = query.docs.length;
    // });
    return query.docs.map((doc) => _docToEvent(doc.data() as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          "Evenimente",
          style: TextStyle(
            fontSize: 20*(1/MediaQuery.of(context).textScaleFactor),
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: FutureProvider<List<Event>?>.value(
        value: _getUpcomingEvents(),
        initialData: null,
        builder: (context, child){
          var events = Provider.of<List<Event>?>(context);
          if(events == null)
          /// If 'events' are not fetched yet
            return Center(child: SpinningLogo());
          /// If 'events' are fetched
          else return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            itemCount: events.length,
            itemBuilder: (context, index){
              var event = events[index];
              return FutureProvider<Local?>.value(
                initialData: null,
                value: events[index].placeRef.get().then((doc) => queryingService.docSnapToLocal(doc)),
                builder:(context, child) {
                  /// The 'place' for the current list index
                  var place = Provider.of<Local?>(context);
                  if(place == null)
                    return CircularProgressIndicator();
                  else return GestureDetector(
                    onTap: (){
                      Future<Image>? placeImage;
                      // try{
                      //   placeImage = queryingService.getImage(events[index]['place_id']);
                      // }
                      // catch(e){}
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
                                    await events[index].placeRef
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
                                              "Eveniment la:",
                                              style: TextStyle(
                                                color: Colors.orange[600]
                                              )
                                            ),
                                            Text(
                                              events[index].title, 
                                              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20,),
                                deals(place),
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
                                          DateTime.fromMillisecondsSinceEpoch(events[index].dateStart.millisecondsSinceEpoch).toString()
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
                    /// Rounds the Container's corners
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                        /// The main Container of the List Tile
                        child: Container(
                        width: 300,
                        height: 350,
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
                              child: 
                              place != null
                              ? FutureBuilder<Image>(
                                future: queryingService.getImage(place.id),
                                builder: (context, image) {
                                  if(!image.hasData)
                                    return Container(); 
                                  else return image.data!;
                                }
                              )
                              : Container(),
                            ),
                            Container( // The Gradient over the image
                              height: 350,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent,Colors.black87]
                                )
                              ),
                            ),
                            Positioned( // The 'event's info
                              bottom: 30,
                              left: 15,
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  verticalDirection: VerticalDirection.up,
                                  children: [ 
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          WidgetSpan(child: Icon(Icons.location_pin, color: Colors.white, size: 18,)),
                                          WidgetSpan(child: SizedBox(width: 7)),
                                          TextSpan(text: place.name!, style: TextStyle(color: Colors.white))
                                        ]
                                      )
                                    ),
                                    SizedBox(height: 10,),
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
                                                events[index].title,
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
                                        ],
                                      ),
                                    ),
                                    // Container(
                                    //   padding: const EdgeInsets.only(top: 5, bottom: 8),
                                    //   child: Text(
                                    //     /// A formula which converts the Timestamp to Date format
                                    //     'Data: ' + DateTime.fromMillisecondsSinceEpoch(events[index].dateStart.millisecondsSinceEpoch, isUtc: true).toLocal().toString()
                                    //     .substring(0,16),
                                    //     style: TextStyle(
                                    //       fontSize: 12,
                                    //       color: Colors.orange[600]
                                    //     ),
                                    //   ),
                                    // ),
                                    
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 20,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  alignment: Alignment(0,0),
                                  color: Colors.white,
                                  width: 60,
                                  height: 70,
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(fontFamily: "Comfortaa", color: Colors.black, fontSize: 20),
                                      children:[
                                        TextSpan( 
                                          text: event.dateStart.day.toString() + "\n",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                                        ),
                                        TextSpan( 
                                          text: months[event.dateStart.month]!.substring(0,3),
                                          style: TextStyle(fontSize: 18)
                                        )
                                      ]
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                )
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              );
            },
          );
        },
      ),
    );
  }
  
  Column deals(Local place){
    /// Current weekday index
    int currentWeekday = DateTime.now().toLocal().weekday;
    /// Deals of the current weekday
    var deals = place.deals![weekdaysTranslate.keys.toList()[currentWeekday].toLowerCase()];
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
            itemCount: place.deals != null ?  
                      (place.deals != null? 
                        place.deals!.length : 0): 
                      0,
            separatorBuilder: (BuildContext context, int index) => SizedBox(width: 20,),
            itemBuilder: (context,index) { 
              Deal deal = Deal(
                title: deals[index]['title'], 
                content: deals['content'], 
                interval: deals['interval']
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
                        color: dealColor(deal),
                        //color: Theme.of(context).accentColor,
                        child: Text(
                          place.deals![index]['title'],
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
                        (deals.containsKey('threshold')
                        ? deals['threshold']
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
              //                 reservation.deals[index]['title'],
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
              //               (reservation.deals[index].containsKey('threshold')
              //               ? reservation.deals[index]['threshold']
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

  Color dealColor(Deal deal){
    if(deal.title!.toLowerCase().contains("alb"))
      return Color(0xFFCFBA70);
      //return Theme.of(context).highlightColor;
    else if(deal.title!.toLowerCase().contains("roșu") || deal.title!.toLowerCase().contains("rosu"))
      return Color(0xFF600F2B);
      //return Theme.of(context).primaryColor;
    else return Color(0xFFb78a97);
    //return Theme.of(context).accentColor;
  }
}