import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/event.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
          "Rezervări",
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
            return Center(child: SpinningLogo());
          else return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index){
              return Container( /// Get future reservations
                      color: Colors.blueGrey.withOpacity(0.5),
                      height: 200,
                      width: 200,
                      child: Stack(
                        children: [
                          // Align( /// The place's image
                          //   alignment: Alignment.centerLeft,
                          //   child: FutureBuilder<Image>(
                          //     future: queryingService.getImage(reservationData['place_id']),
                          //     builder: (context, image){
                          //       if(!image.hasData)
                          //         return Container(
                          //           width: 300,
                          //           height: 200,
                          //         );
                          //       else return image.data!;
                          //     },
                          //   ),
                          // ),
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
                                  weekdaysTranslate[DateFormat("EEEE").format(events[index].dateStart)]! 
                                  + ',\n' + 
                                  DateFormat("dd MMM").format(events[index].dateStart),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  "Ora: "
                                  + DateFormat("HH:mm").format(events[index].dateStart),
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
                                      events[index].title,
                                      style: TextStyle(
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0,1)
                                          ),
                                          Shadow(
                                            offset: Offset(-1,0)
                                          )
                                        ],
                                        fontSize: events[index].title.length < 27 ? 20 :19,
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
                                      "confirmate"
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      )
              );
            },
          );
        },
      ),
    );
  }
}