import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/widgets/drawer.dart';

class FavoriteLocalsPage extends StatefulWidget {

  List<Local> favoritePlaces ;

  FavoriteLocalsPage(){
    
  }


  @override
  _FavoriteLocalsPageState createState() => _FavoriteLocalsPageState();
}

class _FavoriteLocalsPageState extends State<FavoriteLocalsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProfileDrawer(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: ListView.builder(
          itemCount: 0,
          itemBuilder: (context, index){
            
          }
        )
      ),
    );
  }
}