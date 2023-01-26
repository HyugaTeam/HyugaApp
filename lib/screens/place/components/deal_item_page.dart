
import 'package:flutter/material.dart';

class DealItemPopupPage extends StatelessWidget {

  final item;

  DealItemPopupPage(this.item);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: MediaQuery.of(context).size.width,
      //height: 400,
      child: Container(
        padding: EdgeInsets.only(top: 20),
        // height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text(item['title'], style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 20),),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text(item['content'], style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18, fontWeight: FontWeight.normal),),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  Text("consumație minimă: ${item['threshold']}")
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: FloatingActionButton.extended(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                shape: ContinuousRectangleBorder(),
                elevation: 0,
                onPressed: (){Navigator.pop(context);},
                label: Text("Înapoi", style: Theme.of(context).textTheme.headline4,)
              ),
            ),
          ],
        ),
      )
    );
  }
}