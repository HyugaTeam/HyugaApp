import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/config/format.dart';
import 'package:hyuga_app/config/paths.dart';
import 'package:hyuga_app/screens/event/event_provider.dart';
import 'package:hyuga_app/screens/payment/payment_page.dart';
import 'package:hyuga_app/screens/payment/payment_provider.dart';
import 'package:expandable_text/expandable_text.dart';
import 'dart:math' as Math;

import 'package:maps_launcher/maps_launcher.dart';

class EventPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<EventPageProvider>();
    var event = provider.event;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width,
        // height: 80,
        color: Colors.white,
        child: Row(
          children: [
            Container( /// Price container
              height: 80,
              padding: EdgeInsets.symmetric(horizontal: 30),
              // alignment: Alignment.center,
              color: Colors.white,
              width: MediaQuery.of(context).size.width*0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Preț",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
                  ),
                  Text(
                    "RON${removeDecimalZeroFormat(event.originalPrices[event.mainCategory]!.toDouble())}",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough)
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "RON${removeDecimalZeroFormat(event.prices[event.mainCategory]!.toDouble())}", style: Theme.of(context).textTheme.headline6!.copyWith(letterSpacing: 0, color: Theme.of(context).colorScheme.tertiary)
                        ),
                        TextSpan(
                          text: " /persoană", style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.grey[500])
                        )
                      ]
                    )
                  ),
                  // Spacer()
                  // Text(
                  //   removeDecimalZeroFormat(event.price),
                  //   style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).primaryColor)
                  // )
                ]
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 80,
              width: MediaQuery.of(context).size.width*0.4,
              child: TextButton(
                style: Theme.of(context).textButtonTheme.style!.copyWith(
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 20, vertical: 13))
                ),
                onPressed: Authentication.auth.currentUser!.isAnonymous 
                ? (){
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.6,
                            child: Text("Pentru a cumpăra un bilet, trebuie să vă înregistrați.")
                          ),
                          TextButton(
                            style: Theme.of(context).textButtonTheme.style!.copyWith(
                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 0, vertical: 0)),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent)
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Authentication.signOut();
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            },
                            child: Text("Log In", style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              decoration: TextDecoration.underline,
                              fontSize: 15
                            ),),
                          )
                        ],
                      ),
                    )
                  );
                }
                : () {
                  Navigator.push(context, PageRouteBuilder(
                    pageBuilder: (context, animation, secAnimation) => ChangeNotifierProvider(
                      create: (_) => PaymentPageProvider(event, event.prices.keys.toList(), event.mainCategory, event.prices, event.originalPrices),
                      child: PaymentPage(),
                    ),
                    transitionDuration: Duration(milliseconds: 300),
                    transitionsBuilder: (context, animation, secAnimation, child){
                      var _animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                      return SlideTransition(
                        child: child,
                        position: Tween<Offset>(
                          begin: Offset(1, 0),
                          end: Offset(0, 0)
                        ).animate(_animation),
                      );
                    },
                  ));
                },
                child: Text("Cumpără", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontSize: 16,
                  color: Colors.white
                  ),
                ),
              ),
            ),
            // Container( /// Buy container
            //   height: 50,
            //   width: 100,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(30),
            //     color: Theme.of(context).primaryColor,
            //   ),
            //   alignment: Alignment.center,
            //   // width: MediaQuery.of(context).size.width*0.4,
            //   // color: Theme.of(context).primaryColor.withOpacity(0.4),
            //   child: Text("Cumpără", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6!.copyWith(
            //     fontSize: 16,
            //     color: Theme.of(context).canvasColor
            //     ),
            //   )
            // ),
          ],
        ),
      ),
      appBar: AppBar(
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("${event.name}",),
              Opacity(
                opacity: provider.dateOpacity,
                child: Text("${formatDateToWeekdayAndDate(event.dateStart)}", style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.black, fontSize: 13),)
              )
            ],
          ),
        ),
        centerTitle: true,
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
        leadingWidth: 80,
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
      ),
      body: ListView(
        controller: provider.scrollController,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        shrinkWrap: true,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  event.photoUrl
                ),
              ),
              Positioned( /// Date
                top: 20, 
                right: 20, 
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  height: 65,
                  width: 65,
                  child: Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: "${formatDateToShortMonth(event.dateStart)}\n",
                        style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.tertiary),
                      ),
                      TextSpan(
                        text: "${event.dateStart.day}",
                        style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.primary),
                      )
                    ] 
                  ),textAlign: TextAlign.center,),
                  // child: Text(
                  //   "${formatDateToShortMonth(event.dateStart)}\n${event.dateStart.day}",
                  //   style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.primary),
                  //   textAlign: TextAlign.center,
                  // ),
                )
              ),
            ],
          ),
          SizedBox(height: 20,),
          Text(
            event.name,
            style: Theme.of(context).textTheme.headline6!.copyWith()
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text.rich( /// organiser name
              TextSpan(
                children: [ 
                  TextSpan(text: "by ", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)),
                  TextSpan(text: event.organiserName, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal, decoration: TextDecoration.underline)
              )])
            ),
          ),
          SizedBox(height: 15),
          Row( /// Event hour
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                child: FaIcon(FontAwesomeIcons.solidClock, color: Theme.of(context).primaryColor, size: 16,),
                backgroundColor: Theme.of(context).highlightColor, radius: 15,
              ),
              SizedBox(width: 15,),
              Text(
                event.dateEnd != null
                ? "${formatDateToHourAndMinutes(event.dateStart)} - ${formatDateToHourAndMinutes(event.dateEnd)}"
                : "${formatDateToHourAndMinutes(event.dateStart)}",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Colors.black, 
                  // color: Colors.grey,
                  fontSize: 16, 
                  // decoration: TextDecoration.underline,
                  // fontWeight: FontWeight.normal
                ),
              )
            ],
          ),
          SizedBox(height: 15),
          Row( /// Event location
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                child: Icon(Icons.place, color: Theme.of(context).primaryColor),
                backgroundColor: Theme.of(context).highlightColor, radius: 15,
              ),
              SizedBox(width: 15,),
              GestureDetector(
                onTap: (){
                  MapsLauncher.launchCoordinates(provider.event.location.latitude, provider.event.location.longitude);
                },
                child: Text(
                  "${event.locationName}", 
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Colors.black, 
                    // color: Colors.grey,
                    fontSize: 16, 
                    decoration: TextDecoration.underline,
                    // fontWeight: FontWeight.normal
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 15),
          Column( /// Event description
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row( /// 'Description' title
                children: [ 
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Theme.of(context).highlightColor,
                    child: Text( 
                      "i", 
                      style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).primaryColor, fontSize: 18)
                    )
                  ),
                  SizedBox(width: 15,),
                  Text( "Despre", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.black, fontSize: 16),)
                ]
              ),
              AnimatedContainer( /// Actual description
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                duration: Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      //padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      width: MediaQuery.of(context).size.width - 80,
                      child: ExpandableText(
                        event.content,
                        expanded: provider.isDescriptionExpanded,
                        maxLines: 4,
                        expandText: "Mai mult",
                        collapseText: "Mai puțin",
                        style: Theme.of(context).textTheme.overline!.copyWith(fontSize: 14, color: Colors.grey[500]),
                        animation: true,
                        animationDuration: Duration(milliseconds: 600),
                      ),
                    ),
                    // Container(
                    //   width: MediaQuery.of(context).size.width*0.3,
                    //   child: CircleAvatar(
                    //     child: Transform.rotate(angle: 3 * Math.pi/2, child: Icon(Icons.arrow_back_ios, color: Theme.of(context).primaryColor)), backgroundColor: Theme.of(context).highlightColor, radius: 20,),
                    // )
                  ],
                ),
              )
            ],
          ),
          // Row( /// Event Date
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     CircleAvatar(
          //       child: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor, size: 16,),
          //       backgroundColor: Theme.of(context).highlightColor, radius: 15,
          //     ),
          //     SizedBox(width: 15,),
          //     Text(
          //       "${formatDateToWeekdayAndDate(event.dateStart)}", 
          //       style: Theme.of(context).textTheme.subtitle1!.copyWith(
          //         color: Colors.black, 
          //         // color: Colors.grey,
          //         fontSize: 16, 
          //         // decoration: TextDecoration.underline,
          //         // fontWeight: FontWeight.normal
          //       ),
          //     )
          //   ],
          // ),
          SizedBox(height: 15),
          SizedBox(height: 130)
        ],
      ),
    );
  }
}