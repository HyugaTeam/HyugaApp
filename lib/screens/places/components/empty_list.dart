import 'package:hyuga_app/config/paths.dart';
import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  const EmptyList({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            localAsset("no-data"),
            //color: Colors.black54,
            width: 70,
          ),
          SizedBox(height: 20,),
          Text("Nu există rezultate :(", style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 20, color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.54)))
        ],
      ),
    );
  }
}