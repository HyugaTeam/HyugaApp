import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/event/event_page.dart';
import 'package:hyuga_app/screens/event/event_provider.dart';
import 'package:hyuga_app/screens/ticket/ticket_provider.dart';
import 'package:maps_launcher/maps_launcher.dart';

class TicketPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<TicketPageProvider>();
    var ticket = provider.ticket;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 100,
        leadingWidth: 80,
        centerTitle: true,
        title: GestureDetector(
          onTap: provider.isLoading || provider.event == null 
          ? null
          : () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
              create: (_) => EventPageProvider(provider.event!),
              child: EventPage(),
            ))
          ),
          child: Text("${ticket.eventName}", style: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(decoration: TextDecoration.underline),)
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).highlightColor,
            radius: 40,
            child: IconButton(
              // alignment: Alignment.centerRight,
              color: Theme.of(context).colorScheme.secondary,
              //padding: EdgeInsets.symmetric(horizontal: 20),
              onPressed: () => Navigator.pop(context),        
              icon: Image.asset(localAsset("left-arrow"), width: 18, color: Theme.of(context).primaryColor,)
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
              child: Image.asset(localAsset("more"), width: 22, color: Theme.of(context).primaryColor,),
              radius: 30,
            ),
          )
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                // SizedBox(height: 100),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 30, left: 30, right: 30),
                  padding: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        spreadRadius: 8,
                        blurRadius: 6,
                        offset: const Offset(0, 0)
                      )
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: MediaQuery.of(context).size.height*0.8,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(/// Event image
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30)
                            ),
                            padding: EdgeInsets.all(20),
                            // height: 200,
                            //width: 300,
                            child: ClipRRect(child: Image.network(ticket.photoUrl), borderRadius: BorderRadius.circular(30))
                          ),
                          SizedBox(height: 30,),
                          Container( /// Ticket information
                            height: MediaQuery.of(context).size.width/4 < 120 ? 120 : MediaQuery.of(context).size.width/4,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width*0.5,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                child: Image.asset(localAsset("calendar"), color: Theme.of(context).primaryColor, width: 20,),
                                                backgroundColor: Theme.of(context).highlightColor, radius: 16,
                                              ),
                                              SizedBox(width: 10,),
                                              GestureDetector(
                                                onTap: provider.isLoading || provider.event == null 
                                                ? null
                                                : (){
                                                  MapsLauncher.launchCoordinates(provider.event!.location.latitude, provider.event!.location.latitude);
                                                },
                                                child: Text(
                                                  ticket.eventLocationName,
                                                  style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)  
                                                ),
                                              )
                                            ]
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width*0.5,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                child: FaIcon(Icons.people, color: Theme.of(context).primaryColor, size: 25,),
                                                backgroundColor: Theme.of(context).highlightColor, radius: 16,
                                              ),
                                              SizedBox(width: 10,),
                                              Text(
                                                ticket.numberOfPeople.toString(),
                                                style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold)  
                                              )
                                            ]
                                          ),
                                        ),
                                      )
                                    ]
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width*25,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                child: FaIcon(Icons.place, color: Theme.of(context).primaryColor, size: 25,),
                                                backgroundColor: Theme.of(context).highlightColor, radius: 16,
                                              ),
                                              SizedBox(width: 10,),
                                              Text(
                                                formatDateToWeekdayAndDate(ticket.dateStart),
                                                style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold)  
                                              )
                                            ]
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width*25,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                child: FaIcon(FontAwesomeIcons.solidClock, color: Theme.of(context).primaryColor, size: 20,),
                                                backgroundColor: Theme.of(context).highlightColor, radius: 16,
                                              ),
                                              SizedBox(width: 10,),
                                              Text(
                                                formatDateToHourAndMinutes(ticket.dateStart).toString(),
                                                style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold)  
                                              )
                                            ]
                                          ),
                                        ),
                                      )
                                    ]
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          FittedBox(child: provider.barcode)
                        ],
                      ),
                      Positioned( /// First Left space
                        left: 0,
                        top: 335,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30))
                          ),
                          width: 20,
                        ),
                      ),
                      Positioned( /// First Right space
                        right: 0,
                        top: 335,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))
                          ),
                          width: 20,
                        ),
                      ),
                      Positioned( /// First Row of lines
                        top: 335,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row( 
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(MediaQuery.of(context).size.width ~/ 17, (index) => Text(
                              "-", 
                              style: Theme.of(context).textTheme.headline6!.copyWith(
                                color:  Colors.grey.shade300,
                                fontWeight: FontWeight.w100,
                                fontSize: 25
                              ),
                            ))
                          ),
                        ),
                      ),
                      Positioned( /// Second Left space
                        left: 0,
                        top: 335 + (MediaQuery.of(context).size.width/4 < 180 ? 180 : MediaQuery.of(context).size.width/4),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30))
                          ),
                          width: 20,
                        ),
                      ),
                      Positioned( /// Second Right space
                        right: 0,
                        top: 335 + (MediaQuery.of(context).size.width/4 < 180 ? 180 : MediaQuery.of(context).size.width/4),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))
                          ),
                          width: 20,
                        ),
                      ),
                      Positioned( /// Second Row of lines
                        top: 335 + (MediaQuery.of(context).size.width/4 < 180 ? 180 : MediaQuery.of(context).size.width/4),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row( 
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(MediaQuery.of(context).size.width ~/ 17, (index) => Text(
                              "-", 
                              style: Theme.of(context).textTheme.headline6!.copyWith(
                                color:  Colors.grey.shade300,
                                fontWeight: FontWeight.w100,
                                fontSize: 25
                              ),
                            ))
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ],
            ),
            provider.isLoading
            ? Positioned(
              child: Container(
                height: 5,
                width: MediaQuery.of(context).size.width,
                child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
              ), 
              bottom: MediaQuery.of(context).padding.bottom,
            )
            : Container(),
          ],
        ),
      ),
    );
  }
}