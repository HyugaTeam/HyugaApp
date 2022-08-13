import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/models/event.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/screens/drawer/events_page/event_page.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:provider/provider.dart';
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
      placeRef: data['place_ref'],
      photoUrl: data['photo_url']
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
        backgroundColor: Theme.of(context).primaryColor,
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
              return FutureProvider<Place?>.value(
                initialData: null,
                value: events[index].placeRef.get().then((doc) => queryingService.docSnapToLocal(doc)),
                builder:(context, child) {
                  /// The 'place' for the current list index
                  var place = Provider.of<Place?>(context);
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
                          child: EventPage(event: event, place: place,)
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
                              //height: 225,
                              width: 600,
                              alignment: Alignment(0,0),
                              child: 
                              place != null
                              ? Transform.scale(
                                scale: 1.5,
                                child: Image.network(
                                  event.photoUrl,
                                  loadingBuilder: (context, child, loadingProgress){
                                    if(loadingProgress == null)
                                      return child;
                                    return CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    );
                                  },
                                  fit: BoxFit.fill,
                                ),
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
                                    /// The 'time' where the events takes place 
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          WidgetSpan(child: FaIcon(FontAwesomeIcons.clock, color: Colors.white, size: 16,)),
                                          WidgetSpan(child: SizedBox(width: 7)),
                                          TextSpan(text: dateToHoursAndMinutes(event.dateStart), style: TextStyle(color: Colors.white))
                                        ]
                                      )
                                    ),
                                    SizedBox(height: 10,),
                                    /// The 'place' where the events takes place 
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
                                    /// The 'title' of the event
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
}