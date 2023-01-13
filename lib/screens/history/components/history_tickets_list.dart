import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/history/history_provider.dart';

import 'empty_tickets_list.dart';

class HistoryTicketsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<HistoryPageProvider>();
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
                else{
                  var ticket = upcomingTickets[index];
                  return GestureDetector(
                    onTap: (){
                      
                    },
                    child: Container(
                      
                    ),
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
                else{
                  var ticket = pastTickets[index];
                  return GestureDetector(
                    onTap: (){
                      
                    },
                    child: Container(
                      
                    ),
                  );
                }
              },
            ),
          ],
        );
      }
    );
  }
}