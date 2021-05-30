import 'package:flutter/material.dart';

class DiscountHeroPage extends StatelessWidget {

  final String heroTag;
  final String interval;
  final int discount;

  DiscountHeroPage({this.heroTag,this.interval,this.discount});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height*0.6
        ),
        child: Dialog(
          child: Container(
            height: MediaQuery.of(context).size.height*0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                //shrinkWrap: true,
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    "Reducere de " + discount.toString() + "% la tot bonul",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23
                    ), 
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "In intervalul",
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    interval,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(
                    // height: MediaQuery.of(context).size.height*0.1,
                    height: 40
                  ),
                  Expanded(child: Container(),),
                  RaisedButton(
                    color: Colors.orange[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text(
                      "Revendica",
                      style: TextStyle(
                        fontSize: 15
                      ),
                    ),
                    onPressed: (){

                    },
                  ),
                  SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}