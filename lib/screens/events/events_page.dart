import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/events/events_provider.dart';

class EventsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<EventsPageProvider>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text("Evenimente",),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView.builder(
          itemCount: provider.events.length != 0 ? provider.events.length : 1,
          itemBuilder: (context, index){
            print(provider.events.length.toString() + "LUNGIME");
            if(provider.events.length == 0){
              return Container();
            }
            else{
              var event = provider.events[index];
              return Container(
                height: 300,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(event.photoUrl),
                    fit: BoxFit.cover
                  )
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              event.name,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}