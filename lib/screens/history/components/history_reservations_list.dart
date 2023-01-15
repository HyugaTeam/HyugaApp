import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/history/components/empty_reservations_list.dart';
import 'package:hyuga_app/screens/history/history_provider.dart';
import 'package:hyuga_app/screens/reservation/reservation_page.dart';
import 'package:hyuga_app/screens/reservation/reservation_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';

class 
  HistoryReservationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<HistoryPageProvider>();
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    print(wrapperHomePageProvider.toString() + " wrapperHomeRes");

    return RefreshIndicator(
      onRefresh: provider.getData,
      child: Builder(
        builder: (context) {
          var upcomingReservations = provider.upcomingReservations;
          var pastReservations = provider.pastReservations;
          if((upcomingReservations == null || upcomingReservations.length == 0) && (pastReservations == null || pastReservations.length == 0))
            return EmptyReservationsList();
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 20, right: 20),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Rezervări viitoare",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(height: 15),
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: upcomingReservations == null || upcomingReservations.length == 0 ?  1 : upcomingReservations.length,
                separatorBuilder: (context, index) => SizedBox(height: 15),
                itemBuilder: (context, index){
                  if(provider.isLoading){
                    return Container(
                      padding: EdgeInsets.only(top: 95),
                      height: 100,
                      child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
                    );
                  }
                  else if(upcomingReservations!.length == 0){
                    return Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(30),
                      //   color:  Theme.of(context).highlightColor
                      // ),
                      // height: 100,
                      child: Text.rich( 
                        TextSpan(
                          children: [
                            WidgetSpan(child: Image.asset(
                              localAsset("no-results-found"),
                              color: Colors.black54,
                              width: 23,
                            )),
                            WidgetSpan(child: SizedBox(width: 10,)),
                            TextSpan( 
                              text: "Nu ai rezervări viitoare", 
                              style: Theme.of(context).textTheme.headline6!.copyWith(
                                fontSize: 14, 
                                fontWeight: FontWeight.normal,
                                // color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.54)
                                color: Theme.of(context).textTheme.headline6!.color
                              )
                            )
                        ],
                      )),
                    );
                  }
                  else {
                    var reservation = upcomingReservations[index];
                    var image = provider.getReservationImage(reservation.placeId!);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => 
                          ChangeNotifierProvider.value(
                            value: wrapperHomePageProvider,
                            child: ChangeNotifierProvider(
                              create: (context) => ReservationPageProvider(reservation, image, wrapperHomePageProvider),
                              child: ReservationPage(),
                            ),
                          )
                        )).whenComplete(() => provider.getData()),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).highlightColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    spreadRadius: 0.1,
                                    blurRadius: 10,
                                    offset: const Offset(0, 0)
                                  )
                                ],
                              ),
                              //padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              height: 100,
                              child: Row(
                                children: [
                                  FutureProvider<Image?>.value(
                                    value: image,
                                    initialData: null,
                                    builder: (context, child){
                                      var image = Provider.of<Image?>(context);
                                      return SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: image != null 
                                        ? AspectRatio(
                                          aspectRatio: 1.5,
                                          child: image,
                                        )
                                        : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,))
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(reservation.placeName!, style: Theme.of(context).textTheme.labelMedium),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text.rich( /// The Date
                                              TextSpan(
                                                children: [
                                                  WidgetSpan(child: Image.asset(localAsset('calendar'), width: 18)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: formatDateToDay(reservation.dateStart)
                                                  ),
                                                ]
                                              )
                                            ),
                                            SizedBox(width: 20,),
                                            Text.rich( /// The Time 
                                              TextSpan(
                                                children: [
                                                  WidgetSpan(child: Image.asset(localAsset('time'), width: 18)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: formatDateToHourAndMinutes(reservation.dateStart)
                                                  ),
                                                ]
                                              )
                                            ),
                                          ],
                                        ),
                                          Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text.rich( /// The 'Accepted' or 'Refused' symbol
                                              TextSpan(
                                                children: reservation.accepted != null
                                                ? ( reservation.accepted !
                                                ? [
                                                  WidgetSpan(child: Image.asset(localAsset('accepted'), width: 18, color: Colors.green)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: "Acceptată",
                                                    style: TextStyle(
                                                      color: Colors.green
                                                    )
                                                  ),
                                                ]
                                                : [
                                                  WidgetSpan(child: Image.asset(localAsset('refused'), width: 18, color: Colors.red)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: "Refuzată",
                                                    style: TextStyle(
                                                      color: Colors.red
                                                    )
                                                  ),
                                                ])
                                                : [
                                                  WidgetSpan(child: Image.asset(localAsset('waiting'), width: 18)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: "În așteptare",
                                                  ),
                                                ]
                                              )
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ),
                            reservation.canceled == true
                            ? Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.black54,
                              child: Center(
                                child: Text("Anulată", style: Theme.of(context).textTheme.headline4),
                              ),
                            )
                            : Container()
                          ],
                        ),
                      ),
                    );
                  }
                }
              ),
              SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal : 10),
                child: Text(
                  "Rezervări trecute",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(height: 30,),
              ListView.separated( 
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pastReservations == null || pastReservations.length == 0 ? 1 : pastReservations.length,
                separatorBuilder: (context, index) => SizedBox(height: 15),
                itemBuilder: (context, index){
                  if(pastReservations == null)
                    return Container(
                      padding: EdgeInsets.only(top: 95),
                      height: 5,
                      child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
                    );
                  else if(pastReservations.length == 0){
                    return Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(30),
                      //   color:  Theme.of(context).highlightColor
                      // ),
                      // height: 100,
                      child: Text.rich( 
                        TextSpan(
                          children: [
                            WidgetSpan(child: Image.asset(
                              localAsset("no-results-found"),
                              color: Colors.black54,
                              width: 25,
                            )),
                            WidgetSpan(child: SizedBox(width: 10,)),
                            TextSpan( 
                              text: "Nu ai rezervări trecute", 
                              style: Theme.of(context).textTheme.headline6!.copyWith(
                                fontSize: 18, 
                                fontWeight: FontWeight.normal,
                                // color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.54)
                                color: Theme.of(context).textTheme.headline6!.color
                              )
                            )
                        ],
                      )),
                    );
                  }
                  else {
                    var reservation = provider.pastReservations![index];
                    var image = provider.getReservationImage(reservation.placeId!);
                    print(reservation);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => 
                          MultiProvider(
                            providers: [
                              ChangeNotifierProvider(create: (context) => ReservationPageProvider(reservation, image, wrapperHomePageProvider),),
                              ChangeNotifierProvider.value(value: wrapperHomePageProvider)
                            ],
                            child: ReservationPage(),
                          ),
                        )),
                        child: Stack(
                          children: [
                            Container(
                              color: Theme.of(context).highlightColor,
                              //padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              height: 100,
                              child: Row(
                                children: [
                                  FutureProvider<Image?>.value(
                                    value: provider.getReservationImage(reservation.placeId!),
                                    initialData: null,
                                    builder: (context, child){
                                      var image = Provider.of<Image?>(context);
                                      return SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: image != null 
                                        ? AspectRatio(
                                          aspectRatio: 1.5,
                                          child: image,
                                        )
                                        : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,))
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(reservation.placeName!, style: Theme.of(context).textTheme.labelMedium),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text.rich( /// The Date
                                              TextSpan(
                                                children: [
                                                  WidgetSpan(child: Image.asset(localAsset('calendar'), width: 18)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: formatDateToDay(reservation.dateStart)
                                                  ),
                                                ]
                                              )
                                            ),
                                            SizedBox(width: 20,),
                                            Text.rich( /// The Time 
                                              TextSpan(
                                                children: [
                                                  WidgetSpan(child: Image.asset(localAsset('time'), width: 18)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: formatDateToHourAndMinutes(reservation.dateStart)
                                                  ),
                                                ]
                                              )
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text.rich( /// The 'Accepted' or 'Refused' symbol
                                              TextSpan(
                                                children: reservation.accepted != null
                                                ? ( reservation.accepted == true
                                                  ? [
                                                  WidgetSpan(child: Image.asset(localAsset('accepted'), width: 18, color: Colors.green)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: "Acceptată",
                                                    style: TextStyle(
                                                      color: Colors.green
                                                    )
                                                  ),
                                                ]
                                                : [
                                                  WidgetSpan(child: Image.asset(localAsset('refused'), width: 18, color: Colors.red)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: "Refuzată",
                                                    style: TextStyle(
                                                      color: Colors.red
                                                    )
                                                  ),
                                                ])
                                                : [
                                                  WidgetSpan(child: Image.asset(localAsset('waiting'), width: 18)),
                                                  WidgetSpan(child: SizedBox(width: 10)),
                                                  TextSpan(
                                                    text: "În așteptare",
                                                  ),
                                                ]
                                              )
                                            ),
                                            SizedBox(width: 20,),
                                            // !(reservation.canceled == true)
                                            // ? Column( children: [
                                            //   SizedBox(width: 10,),
                                            //   Text.rich( /// The "claimed" property
                                            //     TextSpan(
                                            //       children: [
                                            //         WidgetSpan(child: Image.asset(localAsset('claimed'), width: 18, color: reservation.claimed != null && reservation.claimed == true ? Colors.green : Colors.red,)),
                                            //         WidgetSpan(child: SizedBox(width: 10)),
                                            //         TextSpan(
                                            //           text: (reservation.claimed != null && reservation.claimed == true) && reservation.accepted == true
                                            //           ? "Revendicată"
                                            //           : "Nerevendicată",
                                            //           style: (reservation.claimed != null && reservation.claimed == true) && reservation.accepted == true
                                            //           ? TextStyle(color: Colors.green)
                                            //           : TextStyle(color: Colors.red)
                                            //         ),
                                            //       ]
                                            //     )
                                            //   ),
                                            // ])
                                            // : Container()
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ),
                            reservation.canceled == true
                            ? Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.black54,
                              child: Center(
                                child: Text("Anulată", style: Theme.of(context).textTheme.headline4),
                              ),
                            )
                            : Container()
                          ],
                        ),
                      ),
                    );
                  }
                }
              ),
              SizedBox(height: 20,)
            ],
          );
        }
      ),
    );
  }
}