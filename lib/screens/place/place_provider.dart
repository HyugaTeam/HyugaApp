import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hyuga_app/config/constants.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/services/analytics_service.dart';

class PlacePageProvider with ChangeNotifier{
  Place place;
  Future<Image?>? firstImage;
  Future <Image?>? secondImage;
  Future <Image?>? thirdImage;
  bool? onlyDiscounts;
  int _selectedWeekday = 0;
  double titleOpacity = 0.0;
  List<bool>? isOfferExpanded;

  PlacePageProvider(this.place, [this.onlyDiscounts]){
    getData();

    ///Added for test
    if(this.onlyDiscounts == null){
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": place.id,
          "place_name": place.name,
          //"place_path": "${g.whereListTranslation[g.selectedWhere]}_${g.whatListTranslation[g.selectedWhere][g.selectedWhat]}_${g.howManyListTranslation[g.selectedHowMany]}_${g.ambianceListTranslation[g.selectedAmbiance]}_${g.areaListTranslation[g.selectedArea]}"
        }
      ).then((value) => print(place.id!+place.name!));
    }
    else{
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": place.id,
          "place_name": place.name,
          "place_path": "only_discounts"
        }
      );
    }
  }

  Future<void> getData() async{
    if(place.deals != null)
      if(place.deals![kWeekdaysFull.keys.toList()[_selectedWeekday-1].toLowerCase()] != null)
        isOfferExpanded = place
          .deals![kWeekdaysFull.keys.toList()[_selectedWeekday-1].toLowerCase()]
          .map<bool>((key) => false).toList();
    // print(isOfferExpanded);
    firstImage = _getFirstImage();
    secondImage = _getSecondImage();
    thirdImage = _getThirdImage();
  }

  Future<Image?> _getFirstImage() async{
    Uint8List? imageFile;
    int maxSize = 6*1024*1024;
    String? fileName = place.id;
    String pathName = 'photos/europe/bucharest/$fileName';
    var storageRef = FirebaseStorage.instance.ref().child(pathName);
    try{
      await storageRef.child('$fileName'+'_1.jpg')
        .getData(maxSize).then((data){
          imageFile = data;
          }
        );
      return Image.memory(
        imageFile!,
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
    }
    catch(error){
      print(error);
    }
    return null; // if nothing else happens
  }
  Future<Image?> _getSecondImage() async{
    Uint8List? imageFile;
      int maxSize = 6*1024*1024;
      String? fileName = place.id;
      String pathName = 'photos/europe/bucharest/$fileName';
      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      try{
        await storageRef.child('$fileName'+'_2.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
        return Image.memory(
          imageFile!,
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
      }
      catch(error){
        print(error);
      }
      return null; // if nothing else happens
  }

  Future<Image?> _getThirdImage() async{
    Uint8List? imageFile;
      int maxSize = 6*1024*1024;
      String? fileName = place.id;
      String pathName = 'photos/europe/bucharest/$fileName';
      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      try{
        await storageRef.child('$fileName'+'_m.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
        return Image.memory(
          imageFile!,
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
      }
      catch(error){
        print(error);
      }
      return null; // if nothing else happens
  }

}