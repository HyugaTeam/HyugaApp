import 'package:flutter/material.dart';
import 'package:hyuga_app/globals/constants.dart';
import 'package:hyuga_app/models/deal.dart';
import 'package:hyuga_app/models/event.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/screens/drawer/events_page/event_reservation_panel.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/Reservation_Panel.dart';
import 'package:provider/provider.dart';

class EventPage extends StatelessWidget {

  final Event event;
  final Place place;

  EventPage({required this.event, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(context),
      body: ListView(
        children: [
          GestureDetector( // When the image is tapped, it pushes the ThirdPage containing the place
            onTap: () async {
              await event.placeRef
              .get().then((value) => 
              Navigator.pushNamed(
                context,
                '/third',
                /// The first argument stands for the actual 'Local' information
                /// The second argument stands for the 'Route' from which the third page came from(for Analytics purpose)
                arguments: [queryingService.docSnapToLocal(value),false] 
              )
              );
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
                        event.title, 
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                )
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                children:[
                  WidgetSpan(child: Icon(Icons.location_pin, size:  18,)),
                  WidgetSpan(child: SizedBox(width: 7)),
                  TextSpan(text: place.name)
                ]
              ), 
            ),
          ),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                children:[
                  WidgetSpan(child: Icon(Icons.calendar_today, size:  18,)),
                  WidgetSpan(child: SizedBox(width: 7)),
                  TextSpan(text: event.dateStart.day.toString()+" "+ months[event.dateStart.month]!+ ", "+ event.dateStart.year.toString())
                ]
              ), 
            ),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                children:[
                  WidgetSpan(child: Icon(Icons.lock_clock, size:  18,)),
                  WidgetSpan(child: SizedBox(width: 7)),
                  TextSpan(text: dateToHoursAndMinutes(event.dateStart))
                ]
              ), 
            ),
          ),
          SizedBox(height: 20,),
          deals(place),
        ],
      ),
    );
  }
  Column deals(Place place){
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
            itemCount: deals != null  
                      ? deals.length
                      : 0,
            separatorBuilder: (BuildContext context, int index) => SizedBox(width: 20,),
            itemBuilder: (context,index) { 
              print(deals.length);
              Deal deal = Deal(
                title: deals[index]['title'], 
                content: deals[index]['content'], 
                interval: deals[index]['interval']
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
                          deals[index]['title'],
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
                        (deals[index].containsKey('threshold')
                        ? deals[index]['threshold']
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

  FloatingActionButton _buildFloatingActionButton(BuildContext context) => FloatingActionButton.extended(
    elevation: 10,
    shape: ContinuousRectangleBorder(),
    backgroundColor: Theme.of(context).primaryColor,
    onPressed: () => _openReservationDialog(context),
    label: Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        "Rezervă loc",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17
        ),
      ),
    ),
  );
  
  _openReservationDialog(BuildContext context){
    showGeneralDialog(
      context: context,
      transitionDuration: Duration(milliseconds: 600),
      barrierLabel: "",
      barrierDismissible: true,
      transitionBuilder: (context,animation,secAnimation,child){
        CurvedAnimation _anim = CurvedAnimation(
          parent: animation,
          curve: Curves.bounceInOut,
          reverseCurve: Curves.easeOutExpo
        );
        return ScaleTransition(
          scale: _anim,
          child: child
        );
      },
      pageBuilder: (newContext,animation,secAnimation){
        return EventReservationPanel(context:newContext, place: place);
      }).then((reservation) => reservation != null 
      ? ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Se asteapta confirmare pentru rezervarea facuta la ${(reservation as Map)['place_name']} pentru ora ${reservation['hour']}")
        )
      )
      : null
    ); 
  }

}