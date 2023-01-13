import 'dart:typed_data';
import 'package:authentication/authentication.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/config/constants.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/screens/drawer/ReservationsHistory_Page.dart.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/Reservation_Panel.dart';
import 'package:url_launcher/url_launcher.dart';
export 'package:provider/provider.dart';

class PlacePageProvider with ChangeNotifier{
  Place place;
  Future<Image?>? firstImage;
  Future <Image?>? secondImage;
  Future <Image?>? thirdImage;
  bool? onlyDiscounts;
  int _selectedWeekday = 0;
  double titleOpacity = 0.0;
  List<bool>? isOfferExpanded;
  WrapperHomePageProvider wrapperHomePageProvider;

  PlacePageProvider(this.place, this.wrapperHomePageProvider, [this.onlyDiscounts]){
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
      ).then((value) => print(place.id!+place.name));
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
    var today = DateTime.now().toLocal();
    _selectedWeekday = today.weekday;
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

  Future openReservationDialog(BuildContext context) async{
    SnackBarBehavior _snackBarBehavior = SnackBarBehavior.floating;
    if(Authentication.auth.currentUser!.isAnonymous){
      if(place.hasReservations == true){
        await FirebaseFirestore.instance.collection('users').doc(authService.currentUser!.uid)
        .collection('reservations_history')
        .where('date_start', isGreaterThan: Timestamp.fromDate(DateTime.now().toLocal())).get().then((value){
          print(value.docs.length);
          bool ok = true;
          /// Checks if there are any upcoming unclaimed reservations
          value.docs.forEach((element) { 
            if(element.data()['accepted'] == null || (element.data()['accepted'] == true && element.data()['claimed'] == null))
              ok = false;
          });
          if(!ok){
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: _snackBarBehavior,
                  content: MaterialButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationsHistoryPage()));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Ai deja o rezervare."),
                    ],
                    ),
                  ),
                )
              );
            }
          else if(place.hasReservations == true)
            if(place.preferPhone == true) {
              dialPhoneNumber(place.phoneNumber);
            }
            else {
              showGeneralDialog(
                context: context,
                transitionDuration: Duration(milliseconds: 600),
                barrierLabel: "",
                barrierDismissible: true,
                transitionBuilder: (context,animation,secAnimation,child){
                  CurvedAnimation _anim = CurvedAnimation(
                    parent: animation,
                    curve: Curves.bounceInOut,
                    reverseCurve: Curves.easeOutExpo
                  );
                  return ScaleTransition(
                    scale: _anim,
                    child: child
                  );
                },
                pageBuilder: (newContext,animation,secAnimation){
                  return Provider(
                    create: (context) => place, 
                    child: ReservationPanel(context:newContext)
                  );
                }).then((reservation) => reservation != null 
                ? ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: _snackBarBehavior,
                    content: Text("Se asteapta confirmare pentru rezervarea facuta la ${(reservation as Map)['place_name']} pentru ora ${reservation['hour']}")
                  )
                )
                : null
              ); 
            }
        });
      }
      else ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: _snackBarBehavior,
          content: Text("Localul nu accepta rezervari")
        ));
      }
      else if(authService.currentUser!.isAnonymous == true)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: _snackBarBehavior,
            content: Text("Trebuie sa te loghezi pentru a face rezervari."),
            action: SnackBarAction(
              textColor: Colors.white,
              label: "Log In", 
              onPressed: () async{
                await authService.signOut();
                Navigator.popUntil(context, (Route route){
                  return route.isFirst ? true : false;
                });
              }
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
  }
  
  Future<void> dialPhoneNumber(int? phoneNumber) async{
    String url = "tel:+$phoneNumber";   
    if (await canLaunch(url)) {
       await launch(url);
    } else {
      throw 'Could not launch $url';
    }   
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