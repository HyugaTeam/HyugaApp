import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/models/deal.dart';


class DealItemPage extends StatelessWidget {

  final Local place;
  final Deal deal;

  DealItemPage({this.place, this.deal});

  Color getDealColor(BuildContext context){
    if(deal.title.contains("alb"))
      return Theme.of(context).highlightColor;
    else if(deal.title.contains("roșu") || deal.title.contains("rosu"))
      return Theme.of(context).primaryColor;
    else return Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: getDealColor(context),
        isExtended: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height*0.3,
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Text(
                      "Odata ce revendici reducerea, aceasta mai este valabila doar dupa 24 de ore.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20
                      ),
                    ),
                    Spacer(),
                    MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Theme.of(context).accentColor,
                      child: Text("Ok!", style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: (){},
                    )
                  ],
                ),
              ),
            ),
          )
        ),
        label: Container(
          width: 100,
          child: Text("REVENDICĂ", style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50,),
            Transform.scale(
              scale: 0.5,
              child: Image.asset(
                "assets/images/wine_icon1.png",
                /// TODO
                /// de pus culoarea specifica vinului din oferta
                color: getDealColor(context),
              ),
            ),
            Text(
              deal.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24
              ),
            ),
            SizedBox(height: 40,),

            Text(
              deal.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18
              ),
            ),
            SizedBox(height: 80,),
            Text(
              deal.interval,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18
              ),
            )
          ],
        )
      )
    );
  }
}