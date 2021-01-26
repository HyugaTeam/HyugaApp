import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReservationPanel extends StatefulWidget {

  final BuildContext context;

  ReservationPanel({this.context});

  @override
  _ReservationPanelState createState() => _ReservationPanelState();
}

class _ReservationPanelState extends State<ReservationPanel> {

  Map<String,String> weekdays ={"Mon" : "Lun", "Tue" : "Mar","Wed" : "Mie","Thu" : "Joi","Fri" : "Vin","Sat" : "Sam", "Sun" : "Dum"};
  int _selectedNoOfPeople = 1;
  int _selectedDay = 0;
  int _selectedHour = DateTime.now().toLocal().hour;
  DateTime _selectedDate; // The final parsed Date which will go in the database
  int _selectedDiscount;
  List<Map<String,dynamic>> _selectedDeals;
  
  DateTime currentTime = DateTime.now().toLocal();

  bool _isProgressIndicatorVisible = false;
  ScrollController _noOfPeopleScrollController;
  ScrollController _dayScrollController;
  ScrollController _hourScrollController;

  Local place;
  Map<String,dynamic> placeSchedule;
  String startHour; // The starting hour of the schedule
  String endHour; // The ending hour of the schedule
  int hourDiff; // The difference(in hours) between the ending and starting hour respectively
  int minDiff; // It's value is either 1 or 0, for :30 and :00 respectively 
  DateTime hour; // The first hour of the current weekday in the place's schedule (used for indexing the avaiable hours)

  String formatDealTooltip(List<Map<String,dynamic>> deals){
    String result = "";
    deals.forEach((element) {
      result += element['title'] + " - " + element['interval'] + '\n';
      result += element['content']+'\n\n';
    });
    return result;
  }

  @override
  void initState() {
    super.initState();
    _noOfPeopleScrollController = ScrollController(initialScrollOffset: MediaQuery.of(widget.context).size.width*0.16);
    _dayScrollController = ScrollController();
    _hourScrollController = ScrollController(initialScrollOffset: 0);
  }

  /// Initiate the time schedule for this widget
  initiateHours(BuildContext context){
    placeSchedule = Provider.of<Local>(context).schedule;
    
    if(placeSchedule != null){
      print(placeSchedule);
      startHour = placeSchedule[DateFormat('EEEE').format(currentTime.add(Duration(days: _selectedDay))).toLowerCase()].substring(0,5);
      endHour = placeSchedule[DateFormat('EEEE').format(currentTime.add(Duration(days: _selectedDay))).toLowerCase()].toString().substring(6,11);
      hourDiff = int.parse(endHour.substring(0,2)) - int.parse(startHour.substring(0,2));
      minDiff = endHour.substring(3,5) == '30' ? 1 : 0 ; /// In case the place has a delayed schedule
      hour = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(startHour.substring(0,2)), int.parse(startHour.substring(3,5)));
    }
  }

  int getDiscountForHour(int index){
    String selectedHour =  
    hour.add(Duration(minutes: index*30)).hour.toString()
        + ":" +
          (hour.add(Duration(minutes: index*30)).minute.toString() == '0' 
          ? '00'
          : hour.add(Duration(minutes: index*30)).minute.toString());
    List hourAndDiscount = place.discounts[DateFormat("EEEE").format(DateTime.now().toLocal().add(Duration(days: _selectedDay))).toLowerCase()];
    for(int i = 0; i< hourAndDiscount.length; i++)
      if(selectedHour.compareTo(hourAndDiscount[i].substring(0,5))>= 0 &&
      selectedHour.compareTo(hourAndDiscount[i].substring(6,11))< 0)
        return int.tryParse(hourAndDiscount[i].substring(12,14));
    return 0;
  }

  List<Map<String,dynamic>> getDealsForHour(int index){
    String selectedHour =  
    hour.add(Duration(minutes: index*30)).hour.toString()
        + ":" +
          (hour.add(Duration(minutes: index*30)).minute.toString() == '0' 
          ? '00'
          : hour.add(Duration(minutes: index*30)).minute.toString());
    List hourAndDiscount = place.deals[DateFormat("EEEE").format(DateTime.now().toLocal().add(Duration(days: _selectedDay))).toLowerCase()];
    List<Map<String,dynamic>> deals = <Map<String,dynamic>>[];
    if(hourAndDiscount != null)
      for(int i = 0; i< hourAndDiscount.length; i++)
        if(selectedHour.compareTo(hourAndDiscount[i]['interval'].substring(0,5))>= 0 &&
          selectedHour.compareTo(hourAndDiscount[i]['interval'].substring(6,11))< 0)
          deals.add(hourAndDiscount[i]);
    return deals;
  }

  @override
  Widget build(BuildContext context) {
    
    place = Provider.of<Local>(context);
    initiateHours(context);

    return Theme(
      data: ThemeData(
        highlightColor: Colors.orange[600],
        accentColor: Colors.blueGrey,
        textTheme: TextTheme(bodyText1: TextStyle(fontWeight: FontWeight.bold)),
        fontFamily: 'Comfortaa'
      ),
      child: Dialog(
        child: Container(
            color: Colors.white,
              width: double.infinity,
              height: MediaQuery.of(context).size.height*0.65,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10,),
                  Text(
                    "Rezerva o masa",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(thickness: 10,),
                  SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                  Text(
                    "Cate persoane?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  SizedBox(height: 13,),
                  Container( /// How many people List
                    height: 50,
                    width: double.infinity,
                    child: ListView.separated(
                      controller: _noOfPeopleScrollController,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: 12,
                      separatorBuilder: (context,index)=>SizedBox(width: 10,),
                      itemBuilder: (context,index) => GestureDetector(
                        onTap: (){
                          setState(() {
                            _selectedNoOfPeople = index;
                          });
                          _noOfPeopleScrollController.animateTo(
                            (_selectedNoOfPeople-2)*68.toDouble() - 6,
                            duration: Duration(milliseconds: 500), 
                            curve: Curves.ease
                          );
                        },
                        child: Chip(
                          backgroundColor: index == _selectedNoOfPeople ? Colors.orange[600]: Colors.grey[200],
                          labelPadding: EdgeInsets.symmetric(horizontal: 20),
                          label: Text((index+1).toString())
                        ),
                      )
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    "In ce zi?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  SizedBox(height: 13,),
                  Container( /// Days list
                    height: 50,
                    width: double.infinity,
                    child: ListView.separated(
                      controller: _dayScrollController,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      separatorBuilder: (context,index)=>SizedBox(width: 10,),
                      itemBuilder: (context,index) => GestureDetector(
                        onTap: (){
                          setState(() {
                            _selectedDay = index;
                          });

                          _dayScrollController.animateTo(
                            (_selectedDay-1)*93.toDouble(),
                            duration: Duration(milliseconds: 500), 
                            curve: Curves.ease
                          );
                        },
                        child: Opacity(
                          opacity: index == _selectedDay ? 1 : 1,
                          child: Chip(
                            backgroundColor: index == _selectedDay ? Colors.orange[600]: Colors.grey[200],
                            labelPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  weekdays[DateFormat('EEEE').format(currentTime.add(Duration(days: index))).substring(0,3)],
                                ),
                                Text(
                                  currentTime.add(Duration(days: index)).day.toString() 
                                  + ' ' +
                                  DateFormat('MMMM').format(currentTime.add(Duration(days: index))).substring(0,3),
                                )
                              ],
                            )
                          ),
                        ),
                      )
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    "La ce ora?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  SizedBox(height: 13,),
                  Container( /// Hours list
                    height: 60,
                    width: double.infinity,
                    child: ListView.separated(
                      controller: _hourScrollController,
                      padding: EdgeInsets.symmetric(horizontal: 10,),
                      scrollDirection: Axis.horizontal,
                      itemCount: placeSchedule != null
                        ? hourDiff * 2 + minDiff 
                        : 0,
                      separatorBuilder: (context,index)=>SizedBox(width: 10,),
                      itemBuilder: (context,index) {
                        GlobalKey _tooltipKey = GlobalKey();
                        int discount = getDiscountForHour(index);
                        List<Map<String,dynamic>> deals = getDealsForHour(index);
                        return  GestureDetector(
                        onTap: (){
                          if(hour.add(Duration(minutes: index*30)).compareTo(DateTime.now()) < 0 && _selectedDay == 0){
                            if(g.isSnackBarActive == false){
                              g.isSnackBarActive = true;
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  'Aceasta ora este indisponibila pentru rezervare',
                                  textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Colors.orange[600],
                              )).closed.then((SnackBarClosedReason reason){
                                g.isSnackBarActive = false;
                              });
                            }
                          }
                          
                          else {
                            _selectedHour = index;
                            String selectedHour =  
                            hour.add(Duration(minutes: index*30)).hour.toString()
                                + ":" +
                                  (hour.add(Duration(minutes: index*30)).minute.toString() == '0' 
                                  ? '00'
                                  : hour.add(Duration(minutes: index*30)).minute.toString());
                            String selectedDay = 
                            DateFormat('y-MM-dd').format(DateTime.now().add(Duration(days: _selectedDay)));
                            setState(() {
                              _selectedDate = DateTime.parse(selectedDay +' '+ selectedHour + ':00').toUtc();
                              _selectedDiscount = discount;
                              _selectedDeals = deals;
                              print(_selectedDate);
                            });
                            _hourScrollController.animateTo(
                              (_selectedHour-1.6)*93.toDouble(),
                              duration: Duration(milliseconds: 500), 
                              curve: Curves.ease
                            );
                          }
                        },
                        child: Opacity(
                          opacity: hour.add(Duration(minutes: index*30)).compareTo(DateTime.now()) < 0 && _selectedDay == 0
                                  ? 0.4 : 1,
                          child: Stack(
                            overflow: Overflow.visible,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Chip(
                                  backgroundColor:  index == _selectedHour ? Colors.orange[600]: Colors.grey[200],
                                  labelPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                                  label: Text(
                                    hour.add(Duration(minutes: index*30)).hour.toString()
                                    + ":" +
                                      (hour.add(Duration(minutes: index*30)).minute.toString() == '0' 
                                      ? '00'
                                      : hour.add(Duration(minutes: index*30)).minute.toString()),
                                    style: TextStyle(
                                      fontSize: 15
                                    ),
                                  )
                                ),
                              ),
                              // The 'Deal' Chip
                              deals.length != 0
                              ? Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: (){
                                    final dynamic tooltip = _tooltipKey.currentState;
                                    tooltip.ensureTooltipVisible();
                                  },
                                  child: Tooltip(
                                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.2),
                                    padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                                    key: _tooltipKey,
                                    message: formatDealTooltip(deals),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width*0.11,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey,
                                        borderRadius: BorderRadius.circular(30)
                                      ),
                                      child: Icon(
                                        Icons.local_offer,
                                        color: Colors.white,
                                        size: 19,
                                      )
                                    ),
                                  ),
                                ),
                              )
                              : Container(),
                              // The 'Discount' Chip
                              discount != 0
                              ? Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width*0.11,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: Text(
                                    "-$discount%",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white
                                    ),
                                  ),
                                ),
                              )
                              : Container()
                            ],
                          ),
                        ),
                      );
                      }
                    ),
                  ),
                  Expanded(
                    child: Container()
                  ),
                  RaisedButton(
                    elevation: 1,
                    disabledColor: Colors.grey[300],
                    color: Colors.orange[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Text("Rezerva"),
                    /// The callback invoked when the 'Rezerva' button is pressed
                    onPressed: _selectedDate == null? null : () async{
                      print(_selectedDate);
                      setState(() {
                        _isProgressIndicatorVisible = true;
                      });
                      DocumentReference placeReservationRef = 
                      place.reference.collection('reservations').doc();
                      DocumentReference userReservationRef = FirebaseFirestore.instance.collection('users')
                      .doc(authService.currentUser.uid).collection('reservations_history').doc();
                      await placeReservationRef.set({
                        'accepted': null,
                        'date_created' : FieldValue.serverTimestamp(),
                        'date_start': Timestamp.fromDate(_selectedDate),
                        'guest_id' : authService.currentUser.uid,
                        'guest_name' : authService.currentUser.displayName,
                        'claimed' : null,
                        'number_of_guests' : _selectedNoOfPeople + 1,
                        'discount': _selectedDiscount,
                        'deals': _selectedDeals,
                        'user_reservation_ref' : userReservationRef
                      });
                      
                      await userReservationRef.set(
                        {
                          'accepted': null,
                          'date_created' : FieldValue.serverTimestamp(),
                          'date_start': Timestamp.fromDate(_selectedDate),
                          'place_id' : place.id,
                          'place_name' : place.name,
                          'claimed' : null,
                          'number_of_guests' : _selectedNoOfPeople + 1,
                          'discount': _selectedDiscount,
                          'deals': _selectedDeals,
                          'place_reservation_ref': placeReservationRef
                        }
                      );
                      setState(() {
                        _isProgressIndicatorVisible = false;
                      });
                      AnalyticsService().analytics.logEvent(
                        name: 'new_reservation',
                        parameters: {
                          'place_name': place.name,
                          'place_id': place.id,
                          'date_created': FieldValue.serverTimestamp(),
                          'date_start': Timestamp.fromDate(_selectedDate),
                          'number_of_guests': _selectedNoOfPeople,
                          'discount': _selectedDiscount,
                          'deals': _selectedDeals
                        }
                      );
                      Navigator.pop(context, {'place_name': place.name, 'hour': DateFormat('HH:mm').format(_selectedDate.toLocal())});
                    },
                  ),
                  SizedBox(
                    height: _isProgressIndicatorVisible == true ? 12 : 20
                  ),
                  Visibility(
                    visible: _isProgressIndicatorVisible,
                    child: LinearProgressIndicator(minHeight: 8,
                    ),
                  )
                ],
              )
            ),
      ),
    );
  }
}