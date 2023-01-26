import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/history/history_provider.dart';
import 'package:hyuga_app/screens/ticket/ticket_page.dart';
import 'package:hyuga_app/screens/ticket/ticket_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';

import 'empty_tickets_list.dart';

class HistoryTicketsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<HistoryPageProvider>();
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    return Builder(
      builder: (context) {
        var upcomingTickets = provider.upcomingTickets;
        var pastTickets = provider.pastTickets;
        if((upcomingTickets == null || upcomingTickets.length == 0) && (pastTickets == null || pastTickets.length == 0))
          return EmptyTicketsList();
        else return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 20, right: 20),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Evenimente viitoare",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: 15),
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: upcomingTickets == null || upcomingTickets.length == 0 ? 1 : upcomingTickets.length,
              separatorBuilder: (context, index) => SizedBox(height: 30),
              itemBuilder: (context, index){
                if(upcomingTickets == null && provider.isLoading)
                  return Container(
                      padding: EdgeInsets.only(top: 95),
                      height: 5,
                      child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
                    );
                else if(upcomingTickets!.length == 0)
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
                              text: "Nu ai evenimente trecute", 
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
                else{
                  var ticket = upcomingTickets[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: MaterialButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => 
                        ChangeNotifierProvider.value(
                          value: wrapperHomePageProvider,
                          child: ChangeNotifierProvider(
                            create: (context) => TicketPageProvider(ticket, BarcodeWidget(barcode:  Barcode.code128(),data: ticket.id, drawText: false, height: 80, )),
                            child: TicketPage(),
                          ),
                        )
                      )).whenComplete(() => provider.getData()),
                      child: Container(
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
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: AspectRatio(
                                aspectRatio: 1.5,
                                child: Image.network(ticket.photoUrl),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ticket.eventName, style: Theme.of(context).textTheme.labelMedium),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text.rich( /// The Date
                                        TextSpan(
                                          children: [
                                            WidgetSpan(child: Image.asset(localAsset('calendar'), width: 18)),
                                            WidgetSpan(child: SizedBox(width: 10)),
                                            TextSpan(
                                              text: formatDateToDay(ticket.dateStart)
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
                                              text: formatDateToHourAndMinutes(ticket.dateStart)
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
                                          children: [
                                            WidgetSpan(child: Icon(Icons.place, size: 18,)),
                                            WidgetSpan(child: SizedBox(width: 10)),
                                            TextSpan(
                                              text: ticket.eventLocationName,
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
                      )
                    ) 
                  );
                }
              },
            ),
            SizedBox(height: 20,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal : 10),
              child: Text(
                "Evenimente trecute",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: 15),
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: pastTickets == null || pastTickets.length == 0 ? 1 : pastTickets.length,
              separatorBuilder: (context, index) => SizedBox(height: 30),
              itemBuilder: (context, index){
                if(pastTickets == null && provider.isLoading){
                  return Container(
                    padding: EdgeInsets.only(top: 95),
                    height: 5,
                    child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
                  );
                }
                if(pastTickets!.length == 0)
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
                            text: "Nu ai evenimente trecute", 
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
                else{
                  var ticket = pastTickets[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: MaterialButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => 
                        ChangeNotifierProvider.value(
                          value: wrapperHomePageProvider,
                          child: ChangeNotifierProvider(
                            create: (context) => TicketPageProvider(ticket, BarcodeWidget(barcode:  Barcode.code128(),data: ticket.id, drawText: false, height: 80, )),
                            child: TicketPage(),
                          ),
                        )
                      )).whenComplete(() => provider.getData()),
                      child: Container(
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
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: AspectRatio(
                                aspectRatio: 1.5,
                                child: Image.network(ticket.photoUrl),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ticket.eventName, style: Theme.of(context).textTheme.labelMedium),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text.rich( /// The Date
                                        TextSpan(
                                          children: [
                                            WidgetSpan(child: Image.asset(localAsset('calendar'), width: 18)),
                                            WidgetSpan(child: SizedBox(width: 10)),
                                            TextSpan(
                                              text: formatDateToDay(ticket.dateStart)
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
                                              text: formatDateToHourAndMinutes(ticket.dateStart)
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
                                          children: [
                                            WidgetSpan(child: Icon(Icons.place, size: 18,)),
                                            WidgetSpan(child: SizedBox(width: 10)),
                                            TextSpan(
                                              text: ticket.eventLocationName,
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
                      )
                    ) 
                  );
                }
              },
            ),
            SizedBox(height: 100)
          ],
        );
      }
    );
  }
}