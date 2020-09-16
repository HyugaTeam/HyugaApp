import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReservationsPage extends StatefulWidget {
  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {

  Map<String,String> weekdaysTranslate = {"Monday" : "Luni", "Tuesday" : "Marti","Wednesday" : "Miercuri","Thursday" : "Joi","Friday" : "Vineri","Saturday" : "Sambata", "Sunday" : "Duminica"};

  List pendingReservationsCopy;
  List pendingReservations;
  List acceptedReservations=[];
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ManagedLocal _managedLocal;

  Stream pendingReservationsStream() {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    return   _db.collection('users').doc(authService.currentUser.uid).collection('managed_locals')
    .doc(_managedLocal.id).collection('reservations')
    .where('accepted',isNull: true)
    .orderBy('date_created')
    .snapshots();
  }

  Stream acceptedReservationsStream() {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    return _db.collection('users').doc(authService.currentUser.uid).collection('managed_locals')
    .doc(_managedLocal.id).collection('reservations')
    .where('accepted',isEqualTo: true)
    .where('date_start',isGreaterThan: Timestamp.now())
    .snapshots();
  }

  /// Shows a bottom sheet when a list tile is pressed
  void _showBottomSheet(BuildContext context, DocumentSnapshot reservation){
    showModalBottomSheet(context: context, builder: (context)=> Theme(
      data: ThemeData(
        fontFamily: 'Comfortaa',
        highlightColor: Colors.grey[400],
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.black)
      ),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              color: Colors.transparent,
              width: 130,
              height: 40,
              child: FloatingActionButton(
                foregroundColor: Colors.green,
                highlightElevation: 0,
                elevation: 0,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.green,
                    width: 1
                  ),
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Accepta"),
                    FaIcon(FontAwesomeIcons.check,size: 16)
                  ],
                ),
                onPressed: (){
                  Navigator.pop(context);
                  DocumentReference ref = reservation.reference;
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(reservation.data()['date_start'].millisecondsSinceEpoch);
                  ref.set(
                    {
                      "accepted": true
                    },
                    SetOptions(merge: true)
                  );
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.orange[600],
                      content: Text("Rezervare acceptata pentru ${DateFormat("MMM dd - H:mm").format(date)}")
                    )
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              color: Colors.transparent,
              width: 130,
              height: 40,
              child: FloatingActionButton(
                foregroundColor: Colors.red,
                highlightElevation: 0,
                elevation: 0,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.red,
                    width: 1
                  ),
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Refuza"),
                    FaIcon(FontAwesomeIcons.times,size: 16)
                  ],
                ),
                onPressed: ()async {
                  Navigator.pop(context);
                  DocumentReference ref = reservation.reference;
                  //DateTime date = DateTime.fromMillisecondsSinceEpoch(pendingReservations[index].data()['date_start'].millisecondsSinceEpoch);
                  await ref.set(
                    {
                      "accepted": false
                    },
                    SetOptions(merge: true)
                  );
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.orange[600],
                      content: Text("Rezervare refuzata.")
                    )
                  );
                },
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Nume: "+ reservation.data()['guest_name'], style: TextStyle(fontSize: 22),)
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Pentru ora: "+ DateFormat("Hm").format(DateTime.fromMillisecondsSinceEpoch(
                  reservation.data()['date_start'].millisecondsSinceEpoch
                  )).toString()
                  ,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Nr. persoane: " + "${reservation.data()['number_of_guests']}",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Facuta la data: ${DateFormat("dd-MM-yyyy  H:m").format(DateTime.fromMillisecondsSinceEpoch(
                  reservation.data()['date_created'].millisecondsSinceEpoch
                  ))}",
                  style: TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    )
  );
  }

  /// Used while reservations are being fetched
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    _managedLocal = Provider.of<AsyncSnapshot<dynamic>>(context).data;

    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            height: 30,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: Row(
              children: [
                Text("In asteptare"),
                isLoading == true
                ? CircularProgressIndicator()
                : Container()
              ],
            ),
          ),
          Container( // The pending reservations list
            child: StreamBuilder(
              stream: pendingReservationsStream(),
              builder: (context,ss) {
                if(!ss.hasData)
                  return Center(
                    child: CircularProgressIndicator()
                  );
                else{
                  pendingReservations = ss.data.docs;
                  isLoading = false;
                  if(pendingReservations.length == 0)
                    return Container(
                      width: double.infinity,
                      height: 40,
                      child: Center(child: Text("Nu exista rezervari in asteptare"))
                    );
                  else return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: pendingReservations.length,
                    itemBuilder: (context,index) => Dismissible(
                      //key: Key(pendingReservations[index].toString()),
                      key: UniqueKey(),
                      background: Container( /// The background behind the ListTile containing the 'Accept' text
                        padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.7),
                        width: double.infinity,
                        color: Colors.orange[600],
                        child: Center(
                          widthFactor: 10,
                          child: Text(
                            "Accepta",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ),
                      ),
                      onDismissed: (direction) async {
                        DocumentReference ref = pendingReservations[index].reference;
                        DateTime date = DateTime.fromMillisecondsSinceEpoch(pendingReservations[index].data()['date_start'].millisecondsSinceEpoch);
                        await ref.set(
                          {
                            "accepted": true
                          },
                          SetOptions(merge: true)
                        );
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange[600],
                            content: Text("Rezervare acceptata pentru ${DateFormat("MMM dd - HH:mm").format(date)}")
                          )
                        );
                      },
                      child: ListTile(
                        // trailing: Text(  // The guest's name
                        //   pendingReservations[index].data()['guest_name'].length < 20
                        //     ? pendingReservations[index].data()['guest_name']
                        //     : pendingReservations[index].data()['guest_name'].substring(0,20)
                        //   ),
                        trailing: Text(
                          "${DateFormat("dd-MMM").format(DateTime.fromMillisecondsSinceEpoch(pendingReservations[index].data()['date_start'].millisecondsSinceEpoch))}"
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Comfortaa'
                            ),
                            children: [
                              TextSpan(
                                text: DateTime.now().weekday == DateTime.fromMillisecondsSinceEpoch(pendingReservations[index].data()['date_start'].millisecondsSinceEpoch).weekday
                                ? "Astazi "
                                : weekdaysTranslate["${DateFormat("EEEE").format(DateTime.fromMillisecondsSinceEpoch(
                                pendingReservations[index].data()['date_start'].millisecondsSinceEpoch
                                ))}"] + " "
                              ),
                              WidgetSpan(
                                child: ClipOval(
                                  child: Container(
                                    alignment: Alignment.center,
                                    //padding: EdgeInsets.only(bottom: 20),
                                    color: Colors.black,
                                    height: 7,
                                    width: 7
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: " ${DateFormat("Hm").format(DateTime.fromMillisecondsSinceEpoch(
                                pendingReservations[index].data()['date_start'].millisecondsSinceEpoch
                                ))}",
                              ),
                            ]
                          )
                        ),
                        subtitle: Text("Persoane: "+"${pendingReservations[index].data()['number_of_guests']}"),
                        onTap: (){
                          _showBottomSheet(context,pendingReservations[index]);
                      }
                    ),
                  )
                );}
              }
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            height: 30,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: Text("Acceptate"),
          ),
          Container(
            child: StreamBuilder(
              stream: acceptedReservationsStream(),
              builder: (context, ss) {
                if(!ss.hasData)
                  return Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      LinearProgressIndicator()
                    ],
                  );
                else{
                  acceptedReservations = ss.data.docs;
                  if(acceptedReservations.length == 0)
                    return Container(
                      width: double.infinity,
                      height: 40,
                      child: Center(child: Text("Nu exista rezervari acceptate"))
                    );
                  //print(DateFormat("Hm").format(DateTime.now()));
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: acceptedReservations.length,
                    itemBuilder: (context,index) => ListTile(
                      trailing: OutlineButton(
                        highlightedBorderColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                        ),
                        borderSide: BorderSide(
                          color: Colors.orange[600]
                        ),
                        child: Text(
                          "Activeaza",
                        ),
                        onPressed: (){
                          GlobalKey<FormState> _formKey = GlobalKey();
                          int tableNumber;
                          bool isLoading = false;
                          showDialog(context: context, builder: (context) => Dialog(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                              height: MediaQuery.of(context).size.height*0.5,
                              width: MediaQuery.of(context).size.height*0.8,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Introduceti numarul mesei:",
                                      style: TextStyle(
                                        fontSize: 20
                                      ),
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: TextFormField(
                                        onChanged: (input) => tableNumber = int.tryParse(input),
                                        //onChanged: (input) => setState(()=>tableNumber = int.tryParse(input)),
                                        onFieldSubmitted: (input) => _formKey.currentState.validate(),
                                        cursorColor: Colors.blueGrey,
                                        keyboardType: TextInputType.number,
                                        validator: (String input) => int.tryParse(input) == null 
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
                                            if(_formKey.currentState.validate()){
                                              DocumentReference ref = acceptedReservations[index].reference;
                                              ref.set({
                                                "table_number": tableNumber,
                                                "is_active": true
                                              });
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                        RaisedButton(
                                          color: Colors.white,
                                          child: Text("Renunta"),
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    ),
                                    // SizedBox(
                                    //   height: MediaQuery.of(context).size.height*0.1
                                    // ),
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
                          ));
                          // Navigator.pop(context);
                          // DocumentReference ref = pendingReservations[index].reference;
                          // DateTime date = DateTime.fromMillisecondsSinceEpoch(pendingReservations[index].data()['date_start'].millisecondsSinceEpoch);
                          // ref.set(
                          //   {
                          //     "accepted": true
                          //   },
                          //   SetOptions(merge: true)
                          // );
                          // scaffoldKey.currentState.showSnackBar(
                          //   SnackBar(
                          //     backgroundColor: Colors.orange[600],
                          //     content: Text("Rezervare acceptata pentru ${DateFormat("MMM dd - H:mm").format(date)}")
                          //   )
                          // );
                        }
                      ),
                      title: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Comfortaa'
                          ),
                          children: [
                            TextSpan(
                              text: weekdaysTranslate["${DateFormat("EEEE").format(DateTime.fromMillisecondsSinceEpoch(
                              acceptedReservations[index].data()['date_start'].millisecondsSinceEpoch
                              ))}"] + " - "
                            ),
                            TextSpan(
                              text: "${DateFormat("Hm").format(DateTime.fromMillisecondsSinceEpoch(
                              acceptedReservations[index].data()['date_start'].millisecondsSinceEpoch
                              ))}",
                            ),
                          ]
                        )
                      ),
                      subtitle: Text("Persoane: "+"${acceptedReservations[index].data()['number_of_guests']}"),
                      onTap:() => _showBottomSheet(context, acceptedReservations[index]),
                    )
                  );
                }
              }
            ),
          ),
          Container(

          )
        ],
      ) 
    );  
  }
}