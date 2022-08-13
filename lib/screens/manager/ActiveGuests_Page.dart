import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:provider/provider.dart';

class ActiveGuestsPage extends StatefulWidget {
  @override
  _ActiveGuestsPageState createState() => _ActiveGuestsPageState();
}

class _ActiveGuestsPageState extends State<ActiveGuestsPage> {

  ManagedLocal? _managedLocal;

  List<QueryDocumentSnapshot>? activeGuestsList = [];

  Stream<QuerySnapshot<Map<String, dynamic>>> activeGuestsStream(){
    FirebaseFirestore _db = FirebaseFirestore.instance;
    return   _db.collection('users').doc(authService.currentUser!.uid).collection('managed_locals')
    .doc(_managedLocal!.id).collection('scanned_codes')
    .where('is_active',isEqualTo: true)
    .snapshots();
  }

  @override
  Widget build(BuildContext context) {

    _managedLocal = Provider.of<AsyncSnapshot<ManagedLocal>>(context).data;
    
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: activeGuestsStream(),
        builder: (context, ss) {
          if(!ss.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          else if(ss.data!.docs.length == 0)
            return Container(
              height: 40,
              child: Center(child: Text("Nu exista mese active")),
            );
          else{
            activeGuestsList = ss.data!.docs;
            return Container(
              child: ListView.separated(
                itemCount: activeGuestsList!.length,
                itemBuilder: (context,index) { 
                  Stream<String> time = Stream.periodic(
                    Duration(milliseconds: 1000),
                    (i){
                      Timestamp dateStart = (activeGuestsList![index].data() as Map)['date_claimed'] == null 
                      ? (activeGuestsList![index].data() as Map)['date_start'] 
                      : (activeGuestsList![index].data() as Map)['date_claimed'];
                      Duration duration = DateTime.now().toLocal().difference(DateTime.fromMillisecondsSinceEpoch(dateStart.millisecondsSinceEpoch));
                      String hours = duration.inHours< 10 ? '0'+duration.inHours.toString() : duration.inHours.toString();
                      String minutes = duration.inMinutes%60 < 10 ? '0'+(duration.inMinutes%60).toString(): (duration.inMinutes%60).toString();
                      String seconds = duration.inSeconds%60 < 10 ? '0'+(duration.inSeconds%60).toString() : (duration.inSeconds%60).toString();
                      return 
                        hours +':'+
                        minutes.toString()+':'+
                        seconds.toString(); 
                    }
                  );
                
                  return ListTile(
                    trailing: OutlineButton(
                      highlightedBorderColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                      ),
                      borderSide: BorderSide(
                        color: Colors.orange[600]!
                      ),
                      child: Text(
                        "Incheie bon",
                      ),
                      onPressed: (){
                        GlobalKey<FormState> _formKey = GlobalKey();
                        double? receiptTotal;
                        bool isLoading = false;
                        showDialog(context: context, builder: (context) => Dialog(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            height: MediaQuery.of(context).size.height*0.6,
                            width: MediaQuery.of(context).size.height*0.8,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(
                                  //   "Reducerea care trebuie aplicata: " +
                                  //     (activeGuestsList[index].data()['discount'] != null && activeGuestsList[index].data()['discount'] != 0
                                  //     ? "${activeGuestsList[index].data()['discount']}%"
                                  //     : "0%"),
                                  //   style: TextStyle(
                                  //     fontSize: 20
                                  //   ),
                                  // ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.05),
                                  Text(
                                    "Introduceti valoarea bonului:",
                                    style: TextStyle(
                                      fontSize: 20
                                    ),
                                  ),
                                  Text(
                                    "(cu reducerea deja aplicata)",
                                    style: TextStyle(
                                      fontSize: 17
                                    ),
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      onChanged: (input) => receiptTotal = double.tryParse(input),
                                      onFieldSubmitted: (input) => _formKey.currentState!.validate(),
                                      cursorColor: Colors.blueGrey,
                                      keyboardType: TextInputType.number,
                                      validator: (String? input) => double.tryParse(input!) == null || input == null
                                        ? "Numarul introdus nu este corect!"
                                        : null,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height*0.05,
                                  ),
                                  ButtonBar(
                                    children: [
                                      RaisedButton(
                                        color: Colors.blueGrey,
                                        child: Text("Continua"),
                                        onPressed: (){
                                          if(_formKey.currentState!.validate()){
                                            DocumentReference placeRef = activeGuestsList![index].reference;
                                            placeRef.set(
                                              {
                                              "total": receiptTotal,
                                              "is_active": false,
                                              "date_end" : FieldValue.serverTimestamp(),
                                              "location" : GeoPoint(queryingService.userLocation!.latitude!, queryingService.userLocation!.longitude!)
                                              },
                                              SetOptions(merge: true)
                                            );
                                            DocumentReference userRef = (activeGuestsList![index].data() as Map)['user_scan_ref'];
                                            userRef.set(
                                              {
                                              "total": receiptTotal,
                                              "is_active": false,
                                              "date_end" : FieldValue.serverTimestamp(),
                                              "location" : GeoPoint(queryingService.userLocation!.latitude!, queryingService.userLocation!.longitude!)
                                              },
                                              SetOptions(merge: true)
                                            );
                                            Navigator.pop(context,true);
                                          }
                                        },
                                      ),
                                      RaisedButton(
                                        color: Colors.white,
                                        child: Text("Renunta"),
                                        onPressed: (){
                                          Navigator.pop(context,false);
                                        },
                                      )
                                    ],
                                  ),
                                  Expanded(
                                    child:Container()
                                  ),
                                  isLoading == true
                                  ? CircularProgressIndicator()
                                  : SizedBox(height: 6,)
                                ],
                              )
                            ),
                          ),
                        )).then((value) {
                            if (value != null && value != false) {
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Masa a fost finalizata!"),
                                )
                              );
                            }
                          }
                        );
                      }
                    ),
                    title: Text("Masa numarul ${(activeGuestsList![index].data() as Map)['table_number']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (activeGuestsList![index].data() as Map)['guest_name'] != null
                          ? (activeGuestsList![index].data() as Map)['guest_name']
                          : "Necunoscut"
                        ),
                        StreamBuilder<String>(
                          stream: time,
                          builder: (context, currentTime) =>
                          Text(
                            currentTime.hasData 
                            ? currentTime.data!
                            : "00:00:00",
                            style: TextStyle(
                              color: Colors.orange[600],
                              fontSize: 18*(1/MediaQuery.of(context).textScaleFactor),
                              fontWeight: FontWeight.bold
                            ),
                          )
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (context,index) => Divider(
                  thickness: 2,
                ),
              )
            );
          }
        }
      ),
    );
  }
}