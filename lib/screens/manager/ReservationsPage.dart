import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReservationsPage extends StatefulWidget {
  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {

  List pendingReservationsCopy = [{"hour": "20:00", "noOfGuests": 6},{"hour": "23:00", "noOfGuests": 3}];
  List pendingReservations = [{"hour": "20:00", "noOfGuests": 6},{"hour": "23:00", "noOfGuests": 3}];
  List acceptedReservations=[];
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            height: 30,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: Text("In asteptare"),
          ),
          Container(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pendingReservations.length,
              itemBuilder: (context,index) => Dismissible(
                key: Key(pendingReservations[index].toString()),
                onDismissed: (direction) {
                  // Remove the item from the data source.
                  setState(() {
                    acceptedReservations.add(pendingReservations[index]);
                    pendingReservations.removeAt(index);
                  });
                  // Show a snackbar. This snackbar could also contain "Undo" actions.
                  Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(backgroundColor: Colors.orange[600],content: Text("Rezervare acceptata la ora ${pendingReservationsCopy[index]['hour']}")));
                },
                child: ListTile(
                  trailing: Text("Marcu Florian"),
                  title: Text("Ora: "+"${pendingReservations[index]['hour']}"),
                  subtitle: Text("Persoane: "+"${pendingReservations[index]['noOfGuests']}"),
                  onTap: (){
                    showModalBottomSheet(context: context, builder: (context)=> Theme(
                      data: ThemeData(
                        fontFamily: 'Comfortaa',
                        highlightColor: Colors.grey[400],
                        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.black)
                      ),
                      child: Scaffold(
                        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                        floatingActionButton: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  setState(() {
                                    acceptedReservations.add(pendingReservations[index]);
                                    pendingReservations.removeAt(index);
                                  });
                                  scaffoldKey.currentState.showSnackBar(
                                    SnackBar(backgroundColor: Colors.orange[600],content: Text("Rezervare acceptata la ora ${pendingReservationsCopy[index]['hour']}"))
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
                                onPressed: (){},
                              ),
                            ),
                          ],
                        ),
                      body: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text("Nume: Marcu Florian", style: TextStyle(fontSize: 22),)
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "Pentru ora: 16:30",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "Nr. persoane: 6",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "Facuta la ora: 12:56",
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
                ),
              )
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            height: 30,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: Text("Acceptate astazi"),
          ),
          Container(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: acceptedReservations.length,
              itemBuilder: (context,index) => ListTile(
                trailing: Text("Marcu Florian"),
                title: Text("Ora: "+"${acceptedReservations[index]['hour']}"),
                subtitle: Text("Persoane: "+"${acceptedReservations[index]['noOfGuests']}"),
              )
            ),
          ),
          Container(

          )
        ],
      ) 
    );
  }
}