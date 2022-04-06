import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class WebLandingPage extends StatelessWidget {

  Future<List<Image>?> fetchScreenshots() async{

    Uint8List? imageFile;
    int maxSize = 6*1024*1024;
    int pictureIndex = 1;
    String pathName = 'website/screenshots';
    var ref = FirebaseStorage.instance.ref().child(pathName);
    List<Uint8List?> listOfImages = [];
    try{
        
        do{
          await ref.child('pictureIndex.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
          listOfImages.add(imageFile);
          pictureIndex++;
        }while(pictureIndex<4);

        listOfImages.add(imageFile);
        return listOfImages.map((bytes) => 
          Image.memory(
            bytes!,
            frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              return AnimatedOpacity(
                child: child,
                opacity: frame == null ? 0 : 1,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          )).toList();
      }
      catch(error){
        return null;
      }
}

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
            fontFamily: 'Montserrat',
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 140,
          title: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width*0.3,
              vertical: 10
            ),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/images/wine-street-logo.png',
                  width: 80,
                ),
                SizedBox(width: 30,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Wine Street",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                      ),
                    ),
                    SizedBox(
                      height: 15
                    ),
                    Text(
                      "Wine & Dine la superlativ",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 800,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container( /// Text side
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 400,
                            child: Text(
                              "Sip, Savor, Save. Repeat.",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 45,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ),
                          SizedBox(
                            height: 40,
                          ),
                        ]
                      ),
                    ),
                    Container( // Screenshots side
                      child: Text(
                        "ss"
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}