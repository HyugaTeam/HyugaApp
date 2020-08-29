import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

// The page containing the user's QR code
class UserQRCode extends StatelessWidget {

  BuildContext globalContext;
  static Firestore _db = Firestore.instance;
  Stream<QuerySnapshot> scanInProgress = _db.collection('users').document(authService.currentUser.uid).collection('scan_history').snapshots().skip(1);
  
  UserQRCode(this.globalContext){
    scanInProgress.listen((QuerySnapshot event) {
        showDialog(context: globalContext, builder: (globalContext) => 
          AlertDialog(
            title: Text(
              "Local: " + event.documentChanges.last.document.data['place_name'].toString()
              .substring(0, min(
                20,
                event.documentChanges.last.document.data['place_name'].length
              ))
            ),
            content: Text("Valoarea bonului este: " + event.documentChanges.last.document.data['total'].toString()),
            actions: <Widget>[
              RaisedButton(
                child: FaIcon(FontAwesomeIcons.checkSquare, color: Colors.green, size: 20),
                //child: Text("OK"),
                onPressed: (){
                  event.documentChanges.single.document.reference.setData(
                    {'approved_by_user': true},
                    merge: true
                  ).then((value) => showDialog(
                    context: globalContext, 
                    builder: (context){
                      return FutureBuilder(
                        future: Future<bool>.delayed(Duration(milliseconds: 1500)).then((value) { 
                          Navigator.removeRouteBelow(context, ModalRoute.of(context)); 
                          Navigator.pop(globalContext);
                        }),
                        builder:(context,finished){ 
                          if(!finished.hasData)
                            return AlertDialog(
                              title: Text(
                                "Cod scanat cu succes!"
                              ),
                              content: FaIcon(FontAwesomeIcons.checkCircle, color: Colors.green,),
                            );
                            return Container();
                        });
                    }).then((value){ 
                      Navigator.removeRouteBelow(globalContext, ModalRoute.of(globalContext));
                    } ));}
                
              ),
              RaisedButton(
                child: FaIcon(FontAwesomeIcons.times, color: Colors.red, size: 20),
                //child: Text("Valoarea este gresita"),
                onPressed: (){
                  event.documentChanges.single.document.reference.setData(
                    {'approved_by_user': false},
                    merge: true
                  ).then((value) => 
                    showDialog(context: globalContext, builder: (context){
                      return FutureBuilder(
                        future: Future<bool>.delayed(Duration(milliseconds: 1500)).then((value) { Navigator.pop(globalContext); }),
                        builder:(context,finished){ 
                          if(!finished.hasData)
                            return AlertDialog(
                              title: Text(
                                "Scanare respinsa!"
                              ),
                              content: FaIcon(FontAwesomeIcons.checkCircle, color: Colors.green,),
                            );
                            return Container();
                        });
                    }).then((value) => Navigator.pop(globalContext)));
                }
              ),
            ],
          )
          );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.blueGrey),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        alignment: Alignment(0, 0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Text(
                "Acesta este codul tau unic. \nScaneaza-l pentru a primi discounturi!",
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: QrImage(
                padding: EdgeInsets.all(0),
                data: authService.currentUser.uid,
                //version: 1,
                size: 320,
                gapless: false,
                errorStateBuilder: (cxt, err) {
                  return Container(
                    child: Center(
                      child: Text(
                        "Uh oh! Something went wrong...",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Text(
                "Cat timp codul este scanat, nu parasi aceasta pagina",
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
