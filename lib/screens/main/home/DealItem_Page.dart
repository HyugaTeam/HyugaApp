import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/models/deal.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:intl/intl.dart';


class DealItemPage extends StatefulWidget {

  final Local place;
  final Deal deal;
  final int dealDayOfTheWeek; // The day on which the deal is active

  DealItemPage({this.place, this.deal, this.dealDayOfTheWeek});

  @override
  _DealItemPageState createState() => _DealItemPageState();
}

class _DealItemPageState extends State<DealItemPage> {

  final Map<String,String> weekdays = {"Monday" : "Luni", "Tuesday" : "Marti","Wednesday" : "Miercuri","Thursday" : "Joi","Friday" : "Vineri","Saturday" : "Sambata", "Sunday" : "Duminica"};
  final FirebaseFirestore _db = FirebaseFirestore.instance; 
  final DateTime today = DateTime.now().toLocal();
  Color buttonColor; // The floating action's button color
  String buttonText; // The floating action button's text (differs whether the date is today or not)
  VoidCallback callback; // The floating action button's callback (sets the button to DISABLE if needed)

  @override
  void initState(){
    super.initState();
    /// Initiate text of the Floating Action Button
    if (widget.dealDayOfTheWeek == today.weekday){
      buttonColor = getDealColor();
      buttonText = "REVENDICĂ";
      callback = () => showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height*0.3,
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Text(
                    "Odata ce revendici reducerea, aceasta mai este valabila doar dupa 24 de ore.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  Spacer(),
                  MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Theme.of(context).accentColor,
                    child: Text("Ok!", style: TextStyle(color: Colors.white, fontSize: 16)),
                    onPressed: () async{
                      addNewScan();
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          ),
        )
      );
    }
    else{
      buttonColor = Colors.grey[300];
      buttonText = "INDISPONIBIL";
      callback = null;
    } 
    /// Initiate 'onPressed' method of the Floating Action Button
  }

  Color getDealColor(){
    if(widget.deal.title.contains("alb"))
      return Color(0xFFCFBA70);
      //return Theme.of(context).highlightColor;
    else if(widget.deal.title.contains("roșu") || widget.deal.title.contains("rosu"))
      return Color(0xFF600F2B);
      //return Theme.of(context).primaryColor;
    else return Color(0xFFb78a97);
    //return Theme.of(context).accentColor;
  }

  String dealsToString(List<Map<String, dynamic>> deals){
    String result = "";
    if(deals != null){
      for(int i = 0; i < deals.length; i++){
        result += i.toString() + ": ";
        result += deals[i]['title'] + " ";
        result += deals[i]['content'] + " ";
        result += deals[i]['interval'] + " ";
        result += ", ";
      }
      return result;
    }
    return "";
  }

  int getDiscount(){
    Map<String, dynamic> discounts = widget.place.discounts;
    List todayDiscounts;
    String currentWeekday = DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase();
    /// Checks if the place has discounts in the current weekday
    if(discounts != null)
      if(discounts.containsKey(currentWeekday) != true)
        return 0;
      else {
        todayDiscounts = discounts[currentWeekday];
        for(int i = 0 ; i< todayDiscounts.length; i++){
          String startHour = todayDiscounts[i].toString().substring(0,5);
          String endHour = todayDiscounts[i].toString().substring(6,11);
          String currentTime = DateTime.now().toLocal().hour.toString() + ':' + DateTime.now().toLocal().minute.toString();
          print(startHour+endHour);
          if(startHour.compareTo(currentTime) <=0 
          && endHour.compareTo(currentTime) >=0)
            return int.parse(todayDiscounts[i].toString().substring(12,14));
        }
      }
    return 0;
  }

  List<Map<String,dynamic>> getDeals(){
    Map<String, dynamic> deals = widget.place.deals;
    List todayDeals;
    String currentWeekday = DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase();
    /// Checks if the place has deals in the current weekday
    if(deals != null)
      if(deals.containsKey(currentWeekday) != true)
        return [];
      else {
        todayDeals = deals[currentWeekday];
        List<Map<String,dynamic>> result = <Map<String,dynamic>>[];
        for(int i = 0 ; i< todayDeals.length; i++){
          String startHour = todayDeals[i]['interval'].toString().substring(0,5); 
          String endHour = todayDeals[i]['interval'].toString().substring(6,11);
          String currentTime = DateTime.now().toLocal().hour.toString() + ':' + DateTime.now().toLocal().minute.toString();
          print(startHour+endHour);
          if(startHour.compareTo(currentTime) <=0 
          && endHour.compareTo(currentTime) >=0)
            result.add(todayDeals[i]);
        }
        return result;
      }
    return [];
  }

  void addNewScan() async{
    // bool ok = false; // This decides whether the scan process has been approved by the user or not  
    // DocumentSnapshot userDoc = await _db.collection('users').doc(authService.currentUser.uid).get();
    // DocumentReference userRef = _db.collection('users').doc(userDoc.id).collection('scan_history').doc();
    // DocumentReference placeRef = _db.collection('users').doc(authService.currentUser.uid)
    // .collection('managed_locals').doc(widget.place.id).collection('scanned_codes').doc();
    // await userRef.set(
    //   {
    //       'place_id' : widget.place.id,
    //       'place_name' : widget.place.name,
    //       'date_start': FieldValue.serverTimestamp(),
    //       'discount': getDiscount(),
    //       'deals': getDeals(),
    //       'is_active': true,
    //       'number_of_guests': 1, // TODO
    //       'score' : userDoc.data()['score'],
    //       'approved_by_user' : null,
    //       'reservation' : false,
    //       'reservation_ref' : null,
    //       'place_scan_ref' : placeRef
    //   },
    //   SetOptions(
    //     merge: true
    //   )
    // );
    // await placeRef.set(
    //   {
    //       'guest_id' : userDoc.id,
    //       'guest_name' : userDoc.data()['displayName'] != null ? userDoc.data()['displayName'] : userDoc.data()['display_name'],
    //       'date_start': FieldValue.serverTimestamp(), 
    //       'discount': getDiscount(),
    //       'deals': getDeals(),
    //       'is_active': true,
    //       'number_of_guests': 1,
    //       'retained_percentage': 0, // TODO
    //       'score' : userDoc.data()['score'],
    //       'table_number' : 1, // TODO
    //       'approved_by_user' : null,
    //       'reservation' : false,
    //       'reservation_ref' : null,
    //       'user_scan_ref' : userRef
    //   },
    //   SetOptions(
    //     merge: true
    //   )
    // );

    // try{
    //   AnalyticsService().analytics.logEvent(
    //     name: 'new_scan',
    //     parameters: {
    //       'place_name': widget.place.name,
    //       'place_id': widget.place.id,
    //       'date_start': FieldValue.serverTimestamp.toString(),
    //       'number_of_guests': 1, // TODO
    //       'reservation': false,
    //       'discount': getDiscount(),
    //       'deals': dealsToString(getDeals())
    //     }
    //   );
    // }
    // catch(err){}
    // //return ok;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        
        backgroundColor: buttonColor,
        isExtended: true,
        onPressed: callback,
        label: Container(
          //width: 100,
          child: Text(
            buttonText, 
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50,),
            Transform.scale(
              scale: 0.5,
              child: Image.asset(
                "assets/images/wine_icon1.png",
                /// TODO
                /// de pus culoarea specifica vinului din oferta
                color: getDealColor(),
              ),
            ),
            Text(
              widget.deal.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24
              ),
            ),
            SizedBox(height: 40,),

            Text(
              widget.deal.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18
              ),
            ),
            SizedBox(height: 80,),
            Text(
              widget.deal.interval,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18
              ),
            )
          ],
        )
      )
    );
  }
}