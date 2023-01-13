import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';


abstract class DetailTile extends StatelessWidget {}

enum Ambience {intimate, social}
class AmbienceDetailTile extends DetailTile{

  final String ambience;

  AmbienceDetailTile(this.ambience);
  
  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Image.asset(localAsset(ambience), width: 23,),
          SizedBox(width: 10,),
          Column(
            children: [
              Text("Atmosferă", style:Theme.of(context).textTheme.overline,),
              Text(_text(ambience), style:Theme.of(context).textTheme.labelMedium,),
            ],
          )/// Icon
        ],
      ),
    );
  }
  
  String _text(String ambience){
    switch(ambience){
      case "calm":
        return "Intim";
      case "social-friendly":
        return "Socială";
      default: return "";
    }
  }
}

class CostDetailTile extends DetailTile{
  
  final int cost;
  
  CostDetailTile(this.cost);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          // Text("\$", style: Theme.of(context).textTheme.headline6,),
          // // Image.asset(asset(ambience), width: 23,),
          // SizedBox(width: 10,),
          Column(
            children: [
              Text("Cost", style:Theme.of(context).textTheme.overline,),
              Row(children: List.generate(cost, (index) => 
                Container(
                  child: Text('\$', style: Theme.of(context).textTheme.labelMedium,),
                )
              ))
            ],
          )/// Icon
        ],
      ),
    );
  }
}

class TypeDetailTile extends DetailTile{
  
  final String type;
  
  TypeDetailTile(this.type);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: MediaQuery.of(context).size.width*0.27,
        child: Row(
          children: [
            // Text("\$", style: Theme.of(context).textTheme.headline6,),
            Image.network(cloudAsset(type), width: 22,),
            SizedBox(width: 10,),
            Column(
              children: [
                //Text("Cost", style:Theme.of(context).textTheme.overline,),
                Text(kTypes[type] != null ? kTypes[type]! : type, style: Theme.of(context).textTheme.labelMedium!.copyWith(),),
              ],
            )/// Icon
          ],
        ),
      ),
    );
  }
}