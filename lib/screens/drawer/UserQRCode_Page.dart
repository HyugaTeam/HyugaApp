import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

// The page containing the user's QR code
class UserQRCode extends StatelessWidget {

  BuildContext globalContext;
  Stream<QuerySnapshot> scanInProgress = FirebaseFirestore.instance.collection('users')
  .doc(authService.currentUser.uid).collection('scan_history')
  .where('approved_by_user', isNull: true)
  .snapshots()
  .skip(1);
  //UniqueKey dialogKey = UniqueKey();

  UserQRCode(this.globalContext){
    scanInProgress.listen((QuerySnapshot event) {
        showDialog(context: globalContext, builder: (globalContext) => 
          AlertDialog(
            //key: dialogKey,
            title: Text(
              "Local: " + event.docChanges.last.doc.data()['place_name'].toString()
              .substring(0, min(
                20,
                event.docChanges.last.doc.data()['place_name'].length
              ))
            ),
            content: Container(

              child: Column(
                children: <Widget>[
                  Text("Valoarea bonului este: " + event.docChanges.last.doc.data()['total'].toString()),
                  Text("Ora: "
                    + DateTime.fromMillisecondsSinceEpoch
                    (event.docChanges.last.doc.data()['date']
                    .millisecondsSinceEpoch).hour.toString()
                    +":"
                    + DateTime.fromMillisecondsSinceEpoch
                    (event.docChanges.last.doc.data()['date']
                    .millisecondsSinceEpoch).minute.toString()
                  )
                  
                ],
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                child: FaIcon(FontAwesomeIcons.checkSquare, color: Colors.green, size: 20),
                //child: Text("OK"),
                onPressed: (){
                  event.docChanges.single.doc.reference.set(
                    {'approved_by_user': true},
                    SetOptions(merge: true)
                  ).then((value) => showDialog(
                    context: globalContext, 
                    builder: (context){
                      return FutureBuilder(
                        future: Future<bool>.delayed(Duration(milliseconds: 1500)).then((value) { 
                          Navigator.pop(globalContext);
                          Navigator.pop(this.globalContext);
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
                      Navigator.pop(this.globalContext);
                    } ));}
                
              ),
              RaisedButton(
                child: FaIcon(FontAwesomeIcons.times, color: Colors.red, size: 20),
                //child: Text("Valoarea este gresita"),
                onPressed: (){
                  event.docChanges.single.doc.reference.set(
                    {'approved_by_user': false},
                    SetOptions(merge: true)
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
                        "Oops! Ceva a mers gresit...",
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
