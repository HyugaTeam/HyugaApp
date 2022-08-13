import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/web_version/navbar.dart';

///TODO:
///Implement LayoutBuilder() on top of Scaffold for more responsiveness
///
class WebLandingPage extends StatelessWidget  {

  Image? _bigLogo;
  Image? _catchPhrase;

  Future<Image?> _fetchBigLogo() async{
    
    Uint8List? imageFile;
    int maxSize = 1*1024*1024;
    String pathName = 'website/app_logo';
    var ref = FirebaseStorage.instance.ref().child(pathName);
    try{
      await ref.child('big_wine_bottle.jpg').getData(maxSize)
      .then((data){
        imageFile = data;
      });
      _bigLogo = Image.memory(
        imageFile!,
        scale: 0.3,
        width: 220,
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
      );
      return _bigLogo;
    }
    catch(error){
      return null;
    }
  }
  Future<Image?> _fetchCatchPhrase() async{
    
    Uint8List? imageFile;
    int maxSize = 1*1024*1024;
    String pathName = 'website/app_logo';
    var ref = FirebaseStorage.instance.ref().child(pathName);
    try{
      await ref.child('catch_phrase.png').getData(maxSize)
      .then((data){
        imageFile = data;
      });
      _catchPhrase = Image.memory(
        imageFile!,
        //scale: 0.3,
        width: 500,
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
      );
      return _catchPhrase;
    }
    catch(error){
      return null;
    }
  }

  Future<List<Image>?> _fetchScreenshots() async{

    Uint8List? imageFile;
    int maxSize = 6*1024*1024;
    int pictureIndex = 1;
    String pathName = 'website/app_screenshots';
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
            fontFamily: 'Comfortaa',
        ),
      ),
      child: Scaffold( /// Page Scaffold
        appBar: Navbar(), /// Page Navigator Bar
        body: ListView(
          padding: EdgeInsets.only(top: 100),
          shrinkWrap: true,
          children: [
            Container(  /// First Part(Big App Name and Big App Icon)
              height: 800,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container( // Icon side
                      child: FutureBuilder<Image?>(
                        initialData: Image.memory(Uint8List(0)),
                        future: _fetchCatchPhrase(),
                        builder: (context, _catchPhrase){
                          if(!_catchPhrase.hasData)
                            return Container(
                              width: 500,
                            );
                          else return Container(
                            child: _catchPhrase.data,
                          );
                        },
                      ),
                      // child: FutureProvider.value(
                      //   value: _fetchBigLogo(),
                      //   initialData: null,
                      //   child: Container(
                      //     child: _bigLogo,
                      //   )
                      // )
                    ),
                    SizedBox(width: 100,),
                    Container( // Icon side
                      child: FutureBuilder<Image?>(
                        initialData: Image.memory(Uint8List(0)),
                        future: _fetchBigLogo(),
                        builder: (context, _bigLogo){
                          if(!_bigLogo.hasData)
                            return Container(
                              width: 220,
                            );
                          else return Container(
                            child: _bigLogo.data,
                          );
                        },
                      ),
                      // child: FutureProvider.value(
                      //   value: _fetchBigLogo(),
                      //   initialData: null,
                      //   child: Container(
                      //     child: _bigLogo,
                      //   )
                      // )
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