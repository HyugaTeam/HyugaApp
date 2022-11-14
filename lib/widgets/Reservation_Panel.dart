import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReservationPanel extends StatefulWidget {

  final BuildContext? context;

  ReservationPanel({this.context});

  @override
  _ReservationPanelState createState() => _ReservationPanelState();
}

class _ReservationPanelState extends State<ReservationPanel> {

  Map<String,String> weekdays ={"Mon" : "Lun", "Tue" : "Mar","Wed" : "Mie","Thu" : "Joi","Fri" : "Vin","Sat" : "Sam", "Sun" : "Dum"};
  int _selectedNoOfPeople = 1;
  int _selectedDay = 0;
  int _selectedHour = DateTime.now().toLocal().hour;
  DateTime? _selectedDate; // The final parsed Date which will go in the database
  int? _selectedDiscount;
  List<Map<String,dynamic>>? _selectedDeals;
  bool _isFormEnabled = true;
  String _selectedPhoneNumber = authService.currentUser!.phoneNumber != null // Either a previously saved phone number or ""
  ? authService.currentUser!.phoneNumber as String
  : "";
  
  DateTime currentTime = DateTime.now().toLocal();

  bool _isProgressIndicatorVisible = false;
  ScrollController? _noOfPeopleScrollController;
  ScrollController? _dayScrollController;
  ScrollController? _hourScrollController;
  GlobalKey<FormState> _phoneNumberFormKey = GlobalKey<FormState>();

  late Place place;
  Map<String,dynamic>? placeSchedule;
  String? startHour; // The starting hour of the schedule
  late String endHour; // The ending hour of the schedule
  late int hourDiff; // The difference(in hours) between the ending and starting hour respectively
  late int minDiff; // It's value is either 1 or 0, for :30 and :00 respectively 
  late DateTime hour; // The first hour of the current weekday in the place's schedule (used for indexing the avaiable hours)

  String formatDealTooltip(List<Map<String,dynamic>> deals){
    String result = "";
    deals.forEach((element) {
      result += element['title'] + " - " + element['interval'] + '\n';
      result += element['content']+'\n\n';
    });
    return result;
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

  @override
  void initState() {
    super.initState();
    if(_selectedPhoneNumber != "")
      _isFormEnabled = false;
    _noOfPeopleScrollController = ScrollController(initialScrollOffset: MediaQuery.of(widget.context!).size.width*0.16);
    _dayScrollController = ScrollController();
    _hourScrollController = ScrollController(initialScrollOffset: 0);
  }

  /// Initiate the time schedule for this widget
  initiateHours(BuildContext context){
    placeSchedule = Provider.of<Place>(context).schedule;
    
    if(placeSchedule != null){
      print(placeSchedule);
      startHour = placeSchedule![DateFormat('EEEE').format(currentTime.add(Duration(days: _selectedDay))).toLowerCase()].substring(0,5);
      endHour = placeSchedule![DateFormat('EEEE').format(currentTime.add(Duration(days: _selectedDay))).toLowerCase()].toString().substring(6,11);
      hourDiff = 
        endHour != '00:00' 
        ? int.parse(endHour.substring(0,2)) - int.parse(startHour!.substring(0,2))
        : int.parse(endHour.substring(0,2)) + 12 - int.parse(startHour!.substring(0,2))
      ;
      minDiff = endHour.substring(3,5) == '30' ? 1 : 0 ; /// In case the place has a delayed schedule
      hour = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(startHour!.substring(0,2)), int.parse(startHour!.substring(3,5)));
    }
  }

  int? getDiscountForHour(int index){
    String selectedHour =  
    hour.add(Duration(minutes: index*30)).hour.toString()
        + ":" +
          (hour.add(Duration(minutes: index*30)).minute.toString() == '0' 
          ? '00'
          : hour.add(Duration(minutes: index*30)).minute.toString());
    List? hourAndDiscount = place.discounts![DateFormat("EEEE").format(DateTime.now().toLocal().add(Duration(days: _selectedDay))).toLowerCase()];
    if(hourAndDiscount != null)
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
    List? hourAndDeals = place.deals![DateFormat("EEEE").format(DateTime.now().toLocal().add(Duration(days: _selectedDay))).toLowerCase()];
    List<Map<String,dynamic>> deals = <Map<String,dynamic>>[];
    if(hourAndDeals != null)
      for(int i = 0; i< hourAndDeals.length; i++)
        if(selectedHour.compareTo(hourAndDeals[i]['interval'].substring(0,5))>= 0 &&
          selectedHour.compareTo(hourAndDeals[i]['interval'].substring(6,11))< 0)
          deals.add(hourAndDeals[i]);
    return deals;
  }

  @override
  Widget build(BuildContext context) {
    
    place = Provider.of<Place>(context);
    initiateHours(context);

    return Theme(
      data: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Theme.of(context).primaryColor,
          selectionHandleColor: Theme.of(context).primaryColor
        ),
        //highlightColor: Theme.of(context).primaryColor,
        primaryColor: Theme.of(context).primaryColor,
        textTheme: TextTheme(bodyText1: TextStyle(fontWeight: FontWeight.bold)),
        fontFamily: 'Comfortaa'
      ),
      child: Dialog(
        child: Container(
            color: Colors.white,
              width: double.infinity,
              height: MediaQuery.of(context).size.height*0.70,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10,),
                  Text(
                    "Rezervă o masă",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20*(1/MediaQuery.of(context).textScaleFactor)
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(thickness: 10,),
                  SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                  Text(
                    "Câte persoane?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20*(1/MediaQuery.of(context).textScaleFactor)
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
                          _noOfPeopleScrollController!.animateTo(
                            (_selectedNoOfPeople-2)*68.toDouble() - 6,
                            duration: Duration(milliseconds: 500), 
                            curve: Curves.ease
                          );
                        },
                        child: Chip(
                          backgroundColor: index == _selectedNoOfPeople ? Theme.of(context).primaryColor: Colors.grey[200],
                          labelPadding: EdgeInsets.symmetric(horizontal: 20),
                          label: Text((index+1).toString())
                        ),
                      )
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    "În ce zi?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20*(1/MediaQuery.of(context).textScaleFactor)
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

                          _dayScrollController!.animateTo(
                            (_selectedDay-1)*93.toDouble(),
                            duration: Duration(milliseconds: 500), 
                            curve: Curves.ease
                          );
                        },
                        child: Opacity(
                          opacity: index == _selectedDay ? 1 : 1,
                          child: Chip(
                            backgroundColor: index == _selectedDay ? Theme.of(context).primaryColor: Colors.grey[200],
                            labelPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  weekdays[DateFormat('EEEE').format(currentTime.add(Duration(days: index))).substring(0,3)]!,
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
                    "La ce oră?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20*(1/MediaQuery.of(context).textScaleFactor)
                    ),
                  ),
                  SizedBox(height: 13,),
                  /// Checks if the place has discounts available on the given day
                  //! (place.discounts != null  || place.discounts.containsKey(DateFormat("EEEE").format(DateTime.now().toLocal().add(Duration(days: _selectedDay))).toLowerCase())) 
                  //? Container()
                  //:
                  Container( /// Hours list
                    height: 60,
                    width: double.infinity,
                    child: ListView.separated(
                      controller: _hourScrollController,
                      padding: EdgeInsets.symmetric(horizontal: 10,),
                      scrollDirection: Axis.horizontal,
                      itemCount: placeSchedule != null
                        ? (endHour != "00:00" ? hourDiff * 2 + minDiff - 2 : hourDiff * 2 + 24 + minDiff - 2)
                        : 0,
                      separatorBuilder: (context,index)=>SizedBox(width: 10,),
                      itemBuilder: (context,index) {
                        
                        GlobalKey _tooltipKey = GlobalKey();
                        int discount = 0;
                        //int discount = getDiscountForHour(index);
                        List<Map<String,dynamic>> deals = getDealsForHour(index);
                        return  GestureDetector(
                        onTap: (){
                          if(hour.add(Duration(minutes: index*30)).compareTo(DateTime.now()) < 0 && _selectedDay == 0){
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  'Această oră este indisponibilă pentru rezervare',
                                  textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Theme.of(context).primaryColor
                              )
                            );
                          }
                          else {
                            _selectedHour = index;
                            String selectedHour =  
                              (hour.add(Duration(minutes: index*30)).hour < 10 ?
                              '0' + hour.add(Duration(minutes: index*30)).hour.toString()
                              :
                              hour.add(Duration(minutes: index*30)).hour.toString())
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
                            _hourScrollController!.animateTo(
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
                                  backgroundColor:  index == _selectedHour ? Theme.of(context).primaryColor: Colors.grey[200],
                                  labelPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                                  label: Text(
                                    hour.add(Duration(minutes: index*30)).hour.toString()
                                    + ":" +
                                      (hour.add(Duration(minutes: index*30)).minute.toString() == '0' 
                                      ? '00'
                                      : hour.add(Duration(minutes: index*30)).minute.toString()),
                                    style: TextStyle(
                                      fontSize: 15*(1/MediaQuery.of(context).textScaleFactor)
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
                                    preferBelow: false,
                                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.2),
                                    padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                                    key: _tooltipKey,
                                    message: formatDealTooltip(deals),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width*0.11,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
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
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: Text(
                                    "-$discount%",
                                    style: TextStyle(
                                      fontSize: 14*(1/MediaQuery.of(context).textScaleFactor),
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
                  SizedBox(height: 15,),
                  Text(
                    "Număr de telefon?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20*(1/MediaQuery.of(context).textScaleFactor)
                    ),
                  ),
                  SizedBox(height: 15,),
                  Container(
                    height: 60,
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width*0.65,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            key: _phoneNumberFormKey,
                            child: TextFormField(
                              enabled: _isFormEnabled,
                              style: TextStyle(
                                color: _isFormEnabled
                                  ? Colors.black
                                  : Colors.grey[600],
                              ),
                              initialValue: _selectedPhoneNumber != "" ? _selectedPhoneNumber : null,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                filled: true,
                                fillColor: _isFormEnabled
                                  ? Colors.transparent
                                  : Colors.grey[200],
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.4),
                                    width: 1
                                  ),
                                ),
                                // errorBorder: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(30),
                                //   borderSide: BorderSide(
                                //     color: Colors.grey.withOpacity(0.4),
                                //     width: 1
                                //   ),
                                // ),
                                counterText: "",
                              ),
                              onChanged: (input) => setState(() => _selectedPhoneNumber = input),
                              keyboardType: TextInputType.number,
                              cursorColor: Theme.of(context).primaryColor,
                              validator: (input) {
                                if(input == null || !input.startsWith('0') || input.length != 10)
                                  return 'Numărul de telefon este invalid';
                                return null;
                              },
                              maxLength: 15,
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).primaryColor
                            ),
                            //borderRadius: BorderRadius.circular(30)
                          ),
                          child: IconButton(
                            tooltip: "Modifică numărul de telefon",
                            onPressed: () => setState(() => _isFormEnabled = true), 
                            iconSize: 16,
                            color: Theme.of(context).primaryColor,
                            splashColor: Theme.of(context).primaryColor,
                            highlightColor: Theme.of(context).primaryColor,
                            icon: FaIcon(FontAwesomeIcons.pen)
                          ),
                        )
                      ],
                    ),
                  ),
                  // Expanded(
                  //   child: Container()
                  // ),
                  RaisedButton(
                    elevation: 1,
                    disabledColor: Colors.grey[300],
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "Rezervă",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    /// The callback invoked when the 'Rezerva' button is pressed
                    onPressed: _selectedDate == null || !_phoneNumberFormKey.currentState!.validate() ? null : () async{
                      print(_selectedDate);
                      setState(() {
                        _isProgressIndicatorVisible = true;
                      });
                      DocumentReference placeReservationRef = 
                      place.reference!.collection('reservations').doc();
                      DocumentReference userReservationRef = FirebaseFirestore.instance.collection('users')
                      .doc(authService.currentUser!.uid).collection('reservations_history').doc();
                      await placeReservationRef.set({
                        'accepted': null,
                        'date_created' : FieldValue.serverTimestamp(),
                        'date_start': Timestamp.fromDate(_selectedDate!),
                        'guest_id' : authService.currentUser!.uid,
                        'guest_name' : authService.currentUser!.displayName,
                        'contact_phone_number' : _selectedPhoneNumber,
                        'claimed' : null,
                        'number_of_guests' : _selectedNoOfPeople + 1,
                        'discount': _selectedDiscount,
                        'deals': _selectedDeals,
                        'user_reservation_ref' : userReservationRef,
                      });
                      
                      await userReservationRef.set(
                        {
                          'accepted': null,
                          'date_created' : FieldValue.serverTimestamp(),
                          'date_start': Timestamp.fromDate(_selectedDate!),
                          'place_id' : place.id,
                          'place_name' : place.name,
                          'contact_phone_number' : _selectedPhoneNumber,
                          'claimed' : null,
                          'number_of_guests' : _selectedNoOfPeople + 1,
                          'discount': _selectedDiscount,
                          'deals': _selectedDeals,
                          'place_reservation_ref': placeReservationRef
                        }
                      );
                      /// Change user's phone number
                      if(authService.currentUser!.phoneNumber == null && _selectedPhoneNumber != "")
                        FirebaseFirestore.instance.collection('users')
                        .doc(authService.currentUser!.uid)
                        .set(
                          {
                            'contact_phone_number' : _selectedPhoneNumber
                          },
                          SetOptions(
                            merge: true
                          )
                        );
                      setState(() {
                        _isProgressIndicatorVisible = false;
                      });
                      AnalyticsService().analytics.logEvent(
                        name: 'new_reservation',
                        parameters: {
                          'place_name': place.name,
                          'place_id': place.id,
                          'date_created': DateTime.now().toLocal().toString(),
                          'date_start': Timestamp.fromDate(_selectedDate!).toString(),
                          'number_of_guests': _selectedNoOfPeople,
                          'discount': _selectedDiscount,
                          'deals': _selectedDeals != null && _selectedDeals != [] ? true : false
                        }
                      );
                      Navigator.pop(context, {'place_name': place.name, 'hour': DateFormat('HH:mm').format(_selectedDate!.toLocal())});
                    },
                  ),
                  SizedBox(
                    height: _isProgressIndicatorVisible == true ? 12 : 20
                  ),
                  Visibility(
                    visible: _isProgressIndicatorVisible,
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              )
            ),
      ),
    );
  }
}