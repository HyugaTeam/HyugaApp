import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/config/format.dart';
import 'package:hyuga_app/config/paths.dart';
import 'package:hyuga_app/screens/event/event_page.dart';
import 'package:hyuga_app/screens/event/event_provider.dart';
import 'package:hyuga_app/screens/events/events_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';

import 'components/empty_list.dart';
import 'components/filters_popup.dart';

class EventsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<EventsPageProvider>();
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text("Evenimente",),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: IconButton(
              icon: Stack(
                children: [
                  Center(child: Image.asset(localAsset('filter'), width: 30,)),
                  provider.activeFilters['sorts']!.fold(false, (prev, curr) => prev || curr)
                  ? Positioned(
                    right: 0,
                    top: 12,
                    child: Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: new BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                  : Container()
                ]
                ,
              ),
              onPressed: (){
                showGeneralDialog(
                  context: context,
                  transitionDuration: Duration(milliseconds: 300),
                  transitionBuilder: (context, animation, secondAnimation, child){
                    var _animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                    return SlideTransition(
                      child: child,
                      position: Tween<Offset>(
                        begin: Offset(0,-1),
                        end: Offset(0,0)
                      ).animate(_animation),
                    );
                  },
                  pageBuilder: ((context, animation, secondaryAnimation) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: provider,),
                      // ChangeNotifierProvider.value(value: wrapperHomePageProvider)
                    ],
                    child: FiltersPopUpPage()
                  )
                ));
              },
            )
          )
        ],
      ),
      body: SizedBox.expand(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.tertiary,
          onRefresh: provider.getData,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 20),
                  itemCount: provider.events.length != 0 ? provider.events.length : 1,
                  itemBuilder: (context, index){
                    print(provider.events.length.toString() + "LUNGIME");
                    if(provider.events.length == 0){
                      return EmptyList();
                    }
                    else{
                      var event = provider.events[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider(create: (_) => EventPageProvider(event),),
                              ChangeNotifierProvider.value(value: wrapperHomePageProvider)
                            ],
                            child: EventPage(),
                          ),
                        )),
                        child: Container(
                          height: 320,
                          // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey,
                            image: DecorationImage(
                              image: NetworkImage(event.photoUrl),
                              fit: BoxFit.cover
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                spreadRadius: 10,
                                blurRadius: 10,
                                offset: const Offset(0, 0)
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              Align( /// Text box
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              event.name,
                                              style: Theme.of(context).textTheme.headline6,
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  " RON${removeDecimalZeroFormat(event.originalPrices[event.mainCategory]!.toDouble())} ",
                                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough)
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.tertiary,
                                                    borderRadius: BorderRadius.circular(20)
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "RON${event.prices[event.mainCategory].toString()}",
                                                    style: Theme.of(context).textTheme.headline6!.copyWith(
                                                      color: Theme.of(context).canvasColor,
                                                      fontSize: 18
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        // child: Text.rich(TextSpan( // event name
                                        //   children: [
                                        //     TextSpan(text: event.name, style: Theme.of(context).textTheme.headline6,),
                                        //     WidgetSpan(child: SizedBox(width: 20,)),
                                        //     // TextSpan( 
                                        //     //   text: "by " + event.organiserName,
                                        //     //   style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
                                        //     // )
                                        //   ]
                                        // ),),
                                      ),
                                      // SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: Text( /// organiser name
                                          "by " + event.organiserName,
                                          style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.place, color: Colors.grey[500], size: 20),
                                              SizedBox(width: 5,),
                                              Text(event.locationName, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal))
                                            ],

                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time_filled_rounded, color: Colors.grey[500], size: 18),
                                              SizedBox(width: 5,),
                                              Text(
                                                event.dateEnd != null
                                                ? "${formatDateToHourAndMinutes(event.dateStart)} - ${formatDateToHourAndMinutes(event.dateEnd)}"
                                                : "${formatDateToHourAndMinutes(event.dateStart)}", 
                                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      // Column(
                                          //   mainAxisAlignment: MainAxisAlignment.end,
                                          //   crossAxisAlignment: CrossAxisAlignment.end,
                                          //   children: [
                                          //     Row(
                                          //       children: [
                                          //         Text(
                                          //           event.dateEnd != null
                                          //           ? "${formatDateToHourAndMinutes(event.dateStart)} - ${formatDateToHourAndMinutes(event.dateEnd)}"
                                          //           : "${formatDateToHourAndMinutes(event.dateStart)}", 
                                          //           style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
                                          //         ),
                                          //         SizedBox(width: 5,),
                                          //         Icon(FontAwesomeIcons.solidClock, color: Colors.grey[500], size: 16),
                                          //       ],
                                          //     ),
                                          //   ],
                                          // )
                                      // Text.rich(TextSpan( /// event location
                                      //   children: [
                                      //     WidgetSpan(child: Icon(Icons.place, color: Colors.grey[500])),
                                      //     WidgetSpan(child: SizedBox(width: 5,)),
                                      //     TextSpan(text: event.locationName, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)),
                                      //   ]
                                      // )),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned( /// Date
                                top: 20, 
                                left: 20, 
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
                                )
                              ),
                              Positioned( /// Favourite
                                top: 20, 
                                right: 20, 
                                child: GestureDetector(
                                  onTap: (){
                                    provider.updateFavouriteStatus(index, event);
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      // color: Colors.white,
                                      // borderRadius: BorderRadius.circular(15)
                                    ),
                                    // height: 65,
                                    // width: 65,
                                    child: CircleAvatar(
                                      radius: 23,
                                      // backgroundColor: Colors.transparent,
                                      backgroundColor: Colors.white,
                                      child: event.favourite == true
                                      ? Image.asset(localAsset("favourite-solid"), width: 25, color: Colors.red)
                                      // : Image.asset(localAsset("favourite-solid"), width: 25, color: Colors.white)
                                      : Image.asset(localAsset("favourite"), width: 25, color: Colors.black),
                                    )
                                  ),
                                )
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              provider.isLoading
              ? Container(
                height: MediaQuery.of(context).size.height,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 5,
                  width: MediaQuery.of(context).size.width,
                  child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary), backgroundColor: Colors.transparent,)
                ),
              )
              : Container(),
            ],
          ),
        ),
      ),
    );
  }
}