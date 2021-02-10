import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ReservationsHistoryPage extends StatelessWidget {

  final Map<String,String> weekdaysTranslate = {"Monday" : "Luni", "Tuesday" : "Marti","Wednesday" : "Miercuri","Thursday" : "Joi","Friday" : "Vineri","Saturday" : "Sambata", "Sunday" : "Duminica"};
  int itemCount = 0;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<Map<String,dynamic>> getUpcomingReservations() async{
     QuerySnapshot scanHistory = await _db.collection('users')
    .doc(authService.currentUser.uid).collection('reservations_history')
    .where('date_start',isGreaterThan: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal()))
    .where('claimed', isNull: true)     
    .get();
    itemCount = scanHistory.docs.length;
    bool allAreDenied = true;
    DocumentSnapshot reservation;
    scanHistory.docs.forEach((element) {
      if(element.data()['accepted'] != false){
        reservation = element;
        allAreDenied = false;
      }
    });
    print(reservation);
    if(allAreDenied) return null;

    return reservation.data();
  }

  Future<List> getPastReservations() async {
    QuerySnapshot scanHistory = await _db.collection('users')
    .doc(authService.currentUser.uid).collection('reservations_history')
    .where('date_start', isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now().add(Duration(minutes: -30)).toLocal())) 
    .get();
    itemCount = scanHistory.docs.length;
    return scanHistory.docs.map((doc)=>doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          FutureBuilder(
            future: getUpcomingReservations(),
            builder: (context,reservation){
              if(!reservation.hasData)
                return Container();
              else {
                DateTime dateStart = DateTime.fromMillisecondsSinceEpoch(reservation.data['date_start'].millisecondsSinceEpoch);
                return ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Text(
                        "Rezervari viitoare",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Container( /// Get future reservations
                      color: Colors.blueGrey.withOpacity(0.5),
                      height: 200,
                      width: 200,
                      child: Stack(
                        children: [
                          Align( /// The place's image
                            alignment: Alignment.centerLeft,
                            child: FutureBuilder(
                              future: queryingService.getImage(reservation.data['place_id']),
                              builder: (context,image){
                                if(!image.hasData)
                                  return Container(
                                    width: 300,
                                    height: 200,
                                    child: Shimmer.fromColors(
                                      child: Container(),
                                      baseColor: Colors.white,
                                      highlightColor: Colors.grey
                                    ),
                                  );
                                else return image.data;
                              },
                            ),
                          ),
                          Positioned(
                            child: Container(
                              height: 200,
                              width: 300,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent,Colors.black54]
                                )
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Column(
                              children: [
                                Text(
                                  weekdaysTranslate[DateFormat("EEEE").format(dateStart)] 
                                  + ',\n' + 
                                  DateFormat("dd MMM").format(dateStart),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  "Ora: "
                                  + DateFormat("HH:mm").format(dateStart),
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                )
                              ],
                            )
                          ),
                          Positioned(
                            left: 10,
                            bottom: 15,
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.75,
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      reservation.data['place_name'],
                                      style: TextStyle(
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0,1)
                                          ),
                                          Shadow(
                                            offset: Offset(-1,0)
                                          )
                                        ],
                                        fontSize: reservation.data['place_name'].length < 27 ? 20 :19,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    indent: 10,
                                  ),
                                  ClipOval(
                                    child: Container(
                                      color: Colors.white,
                                      height: 7,
                                      width: 7
                                    ),
                                  ),
                                  Divider(
                                    indent: 10,
                                  ),
                                  Container(
                                    child: Text(
                                      reservation.data['accepted'] == null
                                      ? "in asteptare"
                                      : (reservation.data['accepted'] == true ? "confirmata" : "") ,
                                      style: TextStyle(
                                        color: reservation.data['accepted'] == null
                                        ? Colors.yellow
                                        : (reservation.data['accepted'] == true ? Colors.green : Colors.transparent ) ,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ),
                  ],
                );
              }
            },
          ),
          Container(  /// Get past reservations
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width*0.05,
              vertical: MediaQuery.of(context).size.height*0.01
            ),
            color: Colors.grey[300],
            child: Text("Istoric rezervari"),
          ),
          FutureBuilder(
              future: getPastReservations(),
              builder:(context, reservationsHistory){ 
                if(!reservationsHistory.hasData)
                  return Center(child: LoadingAnimation());
                else if(reservationsHistory.data.length == 0)
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        Text("Nu ai rezervari trecute."),
                      ],
                    ),);
                else
                  return  Container( /// The past reservations list
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height*0.03, vertical: MediaQuery.of(context).size.width*0.05),
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: reservationsHistory.data.length,
                      separatorBuilder: (context,index) => SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (context, index){
                        return GestureDetector(
                          onTap: (){
                            Future<Image> placeImage;
                            try{
                              placeImage = queryingService.getImage(reservationsHistory.data[index]['place_id']);
                            }
                            catch(e){}
                            // Shows a pop-up containing the details about the bill
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context, builder: (context) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)
                                  )
                                ),
                                height: MediaQuery.of(context).size.height*0.75,
                                child: Scaffold(
                                  body: Column(
                                    children: [
                                      GestureDetector( // When the image is tapped, it pushes the ThirdPage containing the place
                                        onTap: () async {
                                          await _db
                                          .collection('locals_bucharest').doc(reservationsHistory.data[index]['place_id'])
                                          .get().then((value) => 
                                          Navigator.pushNamed(
                                            context,
                                            '/third',
                                            /// The first argument stands for the actual 'Local' information
                                            /// The second argument stands for the 'Route' from which the third page came from(for Analytics purpose)
                                            arguments: [queryingService.docSnapToLocal(value),false] 
                                          ));
                                        },
                                        child: Stack(
                                          children: [
                                            Container( // The place's profile image
                                              color: Colors.grey[100],
                                              width: double.infinity,
                                              height: 300,
                                              constraints: BoxConstraints(
                                                maxHeight: 300
                                              ),
                                              child: FutureBuilder(
                                                future: placeImage,
                                                builder: (context,img){
                                                  if(!img.hasData)
                                                    return CircularProgressIndicator();
                                                  else
                                                    return img.data;
                                                }
                                              ),
                                            ),
                                            Container(
                                              height: 300,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [Colors.transparent,Colors.black87]
                                                )
                                              ),
                                            ),
                                            Positioned(
                                              left: 25,
                                              bottom: 25,
                                              width: 300,
                                              child: Text(
                                                reservationsHistory.data[index]['place_name'], 
                                                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                                              )
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20,),
                                      reservationsHistory.data[index]['claimed'] == true
                                      ? Container(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                            children:[
                                              TextSpan(text: "Valoare finala bon: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                              TextSpan(text: reservationsHistory.data[index]['total'].toString()+"RON")
                                            ]
                                          ), 
                                        ),
                                      )
                                      : Container(),
                                      SizedBox(height: 20,),
                                      Container(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                            children:[
                                              TextSpan(text: "Discount: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                              TextSpan(text: reservationsHistory.data[index]['discount'].toString() + "%")
                                              
                                            ]
                                          ), 
                                        ),
                                      ),
                                      SizedBox(height: 20,),
                                      Container(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                            children:[
                                              TextSpan(text: "Numar persoane: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                              TextSpan(
                                                text: reservationsHistory.data[index]['number_of_guests'] != null 
                                                ? reservationsHistory.data[index]['number_of_guests'].toString()
                                                : 1
                                              )
                                            ]
                                          ), 
                                        ),
                                      ),
                                      SizedBox(height: 20,),
                                      Container(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                            children:[
                                              TextSpan(text: "Data: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                              TextSpan(
                                                text: 
                                                DateTime.fromMillisecondsSinceEpoch(reservationsHistory.data[index]['date_start'].millisecondsSinceEpoch).toString()
                                              )
                                            ]
                                          ), 
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                              child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45, 
                                    offset: Offset(1.5,1),
                                    blurRadius: 2,
                                    spreadRadius: 0.2
                                  )
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Container( // The background image of the List Tile
                                      height: 225,
                                      width: 400,
                                      child: FutureBuilder(
                                        future: queryingService.getImage(reservationsHistory.data[index]['place_id']),
                                        builder: (context, image) {
                                          if(!image.hasData)
                                            return Container(); 
                                          else return image.data;
                                        }
                                      ),
                                    ),
                                  Container( // The Gradient over the image
                                      height: 225,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent,Colors.black87]
                                        )
                                      ),
                                    ),
                                  Positioned(
                                    height: 300,
                                    bottom: 15,
                                    left: 15,
                                    child: Container(

                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        verticalDirection: VerticalDirection.up,
                                        children: [ 
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.9,
                                            child: Row(
                                              
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth: MediaQuery.of(context).size.width*0.6,
                                                    ),
                                                    child: Text(
                                                      //"Trattoria Buongiorno Covaci",
                                                      reservationsHistory.data[index]['place_name'],
                                                      style: TextStyle(
                                                        wordSpacing: 0.1,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 24,
                                                        color: Colors.white
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ),
                                                Divider(
                                                  indent: 10,
                                                ),
                                                ClipOval(
                                                  child: Container(
                                                    color: Colors.white,
                                                    height: 7,
                                                    width: 7
                                                  ),
                                                ),
                                                Divider(
                                                  indent: 10,
                                                ),
                                                reservationsHistory.data[index]['total'] != null
                                                ? Flexible(
                                                  child: Text(
                                                    reservationsHistory.data[index]['total'] == reservationsHistory.data[index]['total'].toInt()
                                                      ? reservationsHistory.data[index]['total'].toInt().toString()+" RON"
                                                      : reservationsHistory.data[index]['total'] +" RON",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                )
                                                : Container()
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(top: 5, bottom: 8),
                                            child: Text(
                                              /// A formula which converts the Timestamp to Date format
                                              'Data: ' + DateTime.fromMillisecondsSinceEpoch(reservationsHistory.data[index]['date_start'].millisecondsSinceEpoch, isUtc: true).toLocal().toString()
                                              .substring(0,16),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange[600]
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: Text(
                                              reservationsHistory.data[index]['accepted'] == true
                                              ? (
                                                reservationsHistory.data[index]['claimed'] == true
                                                ? "Revendicata"
                                                : "Nerevendicata"
                                              )
                                              : "Refuzata"
                                              ,
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: reservationsHistory.data[index]['accepted'] == true
                                              ? (
                                                reservationsHistory.data[index]['claimed'] == true
                                                ? Colors.green
                                                : Colors.red
                                              )
                                              : Colors.yellow
                                              )
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    )
                  );
              },
            ),
        ],
      ),
    ) ;
  }
}