import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/widgets/LocalsList.dart';
import 'package:hyuga_app/widgets/drawer.dart';




class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  
  final ScrollController _scrollController = ScrollController();

  /*Image getImage(int index){

      Uint8List imageFile;
      int maxSize = 6*1024*1024;
      String fileName = g.placesList[index].id;
      String pathName = 'photos/europe/bucharest/$fileName';

      var storageRef = FirebaseStorage.instance.ref().child(pathName);
     
      storageRef.child('$fileName'+'_profile.jpg').getData(maxSize).then((data){
        imageFile = data;
        }
      );
      Future.delayed(Duration(seconds: 2));
      var image = Image.memory(imageFile,fit: BoxFit.fill,);
      return image;
  }*/

  

  void addToFavorites(int index){
     
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 30
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          }
        ),
      ),
      drawer: ProfileDrawer(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Locals()
    );
  }
}