import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';

class MenuItemPopupPage extends StatelessWidget {

  final item;

  MenuItemPopupPage(this.item);

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
                  Image.asset(localAsset("ingredients"), width: 20,),
                  SizedBox(width: 15),
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: item['ingredients'].length,
                      separatorBuilder: (context, index) {
                        if(index < item['ingredients'].length-1)
                          return Text(", ");
                        else return Text("");
                      },
                      itemBuilder: (context, index){
                        return Text(item['ingredients'][index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  Image.asset(localAsset("deactivate"), width: 20,),
                  SizedBox(width: 15),
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: item['alergens'].length,
                      separatorBuilder: (context, index) {
                        if(index < item['alergens'].length-1)
                          return Text(", ");
                        else return Text("");
                      },
                      itemBuilder: (context, index){
                        return Text(item['alergens'][index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  //Text("\$", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                  SizedBox(width: 15),
                  Text("${item['price']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: FloatingActionButton.extended(
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