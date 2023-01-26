import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/history/history_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';

import 'components/history_reservations_list.dart';
import 'components/history_tickets_list.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<HistoryPageProvider>();
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    print(wrapperHomePageProvider.toString() + " wrapperHome");
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text("Istoric",),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: AnimatedContainer(
          //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          // alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 0.1,
                blurRadius: 10,
                offset: const Offset(0, 0)
              )
            ],
          ),
          duration: Duration(milliseconds: 300),
          width: 230,
          height: 30,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => provider.viewType == ViewType.tickets ? provider.changeViewType() : null,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: provider.viewType == ViewType.reservations ? Theme.of(context).colorScheme.tertiary : Colors.white,
                    borderRadius: BorderRadius.circular(30)
                  ),
                  width: 115,
                  height: 30,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Image.asset(localAsset("restaurant"), width: 15*(1/MediaQuery.textScaleFactorOf(context)), color: provider.viewType == ViewType.tickets ? Colors.grey: Theme.of(context).canvasColor)
                        ),
                        WidgetSpan(
                          child: SizedBox(width: 10)
                        ),
                        TextSpan(
                          text: "Rezervări",
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 15, color: provider.viewType == ViewType.tickets ? Colors.grey: Theme.of(context).canvasColor),
                        )
                      ]
                    )
                  )
                ),
              ),
              GestureDetector(
                onTap: () => provider.viewType == ViewType.reservations ? provider.changeViewType() : null,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: provider.viewType == ViewType.tickets ? Theme.of(context).colorScheme.tertiary : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  width: 115,
                  height: 30,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Image.asset(localAsset("ticket"), width: 15*(1/MediaQuery.textScaleFactorOf(context)), color: provider.viewType == ViewType.reservations ? Colors.grey: Theme.of(context).canvasColor,)
                        ),
                        WidgetSpan(
                          child: SizedBox(width: 10)
                        ),
                        TextSpan(
                          text: "Bilete",
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 15, color: provider.viewType == ViewType.reservations ? Colors.grey: Theme.of(context).canvasColor),
                        )
                      ]
                    )
                  )
                  // child: Text(
                  //   "Hartă",
                  //   style: Theme.of(context).textTheme.subtitle1,
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.tertiary,
        onRefresh: provider.getData,
        child: SizedBox.expand(
          child: Stack(
            children: [
              IndexedStack(
                index: provider.viewType.index,
                children: [
                  HistoryReservationsList(),
                  HistoryTicketsList()
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}