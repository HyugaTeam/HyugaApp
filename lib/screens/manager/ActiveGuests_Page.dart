import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class ActiveGuestsPage extends StatefulWidget {
  @override
  _ActiveGuestsPageState createState() => _ActiveGuestsPageState();
}

class _ActiveGuestsPageState extends State<ActiveGuestsPage> {

  ManagedLocal _managedLocal;

  List<QueryDocumentSnapshot> activeGuestsList = [];

  Stream activeGuestsStream(){
    FirebaseFirestore _db = FirebaseFirestore.instance;
    return   _db.collection('users').doc(authService.currentUser.uid).collection('managed_locals')
    .doc(_managedLocal.id).collection('reservations')
    .where('is_active',isEqualTo: true)
    .snapshots();
  }

  @override
  Widget build(BuildContext context) {

    _managedLocal = Provider.of<AsyncSnapshot<dynamic>>(context).data;
    
    return Scaffold(
      body: StreamBuilder(
        stream: activeGuestsStream(),
        builder: (context, ss) {
          if(!ss.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          else if(ss.data.docs.length == 0)
            return Container(
              height: 40,
              child: Center(child: Text("Nu exista mese active")),
            );
          else{
            activeGuestsList = ss.data.docs;
            return Container(
              child: ListView.separated(
                itemCount: activeGuestsList.length,
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
                      "Incheie bon",
                    ),
                    onPressed: (){
                      GlobalKey<FormState> _formKey = GlobalKey();
                      int receiptTotal;
                      bool isLoading = false;
                      showDialog(context: context, builder: (context) => Dialog(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          height: MediaQuery.of(context).size.height*0.5,
                          width: MediaQuery.of(context).size.height*0.8,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Reducerea care trebuie aplicata:",
                                  style: TextStyle(
                                    fontSize: 20
                                  ),
                                ),
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
                                    onChanged: (input) => receiptTotal = int.tryParse(input),
                                    //onChanged: (input) => setState(()=>tableNumber = int.tryParse(input)),
                                    onFieldSubmitted: (input) => _formKey.currentState.validate(),
                                    cursorColor: Colors.blueGrey,
                                    keyboardType: TextInputType.number,
                                    validator: (String input) => double.tryParse(input) == null 
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
                                        // if(_formKey.currentState.validate()){
                                        //   DocumentReference ref = activeGuestsList[index].reference;
                                        //   ref.set({
                                        //     "receipt_total": receiptTotal,
                                        //     "is_active": false
                                        //   });
                                        //   Navigator.pop(context);
                                        // }
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
                  title: Text("Masa numarul ${activeGuestsList[index].data()['table_number']}"),
                ),
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