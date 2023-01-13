
import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:intl/intl.dart';
export 'package:provider/provider.dart';

class NewReservationPopupProvider with ChangeNotifier{
  
  Place place;
  DateTime? selectedDate;
  int selectedPeopleNo = 1;
  int selectedDay = 0;
  int selectedHour = DateTime.now().toLocal().hour;
  String selectedName = "";
  String selectedPhoneNo = "";
  String selectedDetails = "";
  bool isLoading = false;

  String? startHour; // The starting hour of the schedule
  String? endHour; // The ending hour of the schedule
  int? hourDiff; // The difference(in hours) between the ending and starting hour respectively
  int? minDiff; // It's value is either 1 or 0, for :30 and :00 respectively 
  DateTime? firstHourAsDate; // The first hour of the current weekday in the place's schedule (used for indexing the avaiable hours)
  DateTime currentTime = DateTime.now().toLocal();

  NewReservationPopupProvider(this.place){
    _initData();
  }

  _initData(){
    var schedule = place.schedule;
    if(schedule != null){
      print(schedule);
      startHour = schedule[DateFormat('EEEE').format(currentTime.add(Duration(days: selectedDay))).toLowerCase()].substring(0,5);
      endHour = schedule[DateFormat('EEEE').format(currentTime.add(Duration(days: selectedDay))).toLowerCase()].toString().substring(6,11);
      hourDiff = 
        endHour != '00:00' 
        ? int.parse(endHour!.substring(0,2)) - int.parse(startHour!.substring(0,2))
        : int.parse(endHour!.substring(0,2)) + 12 - int.parse(startHour!.substring(0,2))
      ;
      minDiff = endHour!.substring(3,5) == '30' ? 1 : 0 ; /// In case the place has a delayed schedule
      firstHourAsDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(startHour!.substring(0,2)), int.parse(startHour!.substring(3,5)));
    }
  }

  void selectDay(int day){
    selectedDay = day;
    notifyListeners();
  }
  
  void selectHour(int index){
    selectedHour = index;

    notifyListeners();
  }

  void selectPeopleNo(int peopleNo){
    selectedPeopleNo = peopleNo;

    notifyListeners();
  }

  void selectName(String name){
    selectedName = name;
    
    notifyListeners();
  }

  void selectPhoneNo(String phoneNo){
    selectedPhoneNo = phoneNo;

    notifyListeners();
  }

  void selectDetails(String details){
    selectedDetails = details;

    notifyListeners();
  }

  void selectDate(){
    String finalSelectedHour =  
      (firstHourAsDate!.add(Duration(minutes: selectedHour*30)).hour < 10 ?
      '0' + firstHourAsDate!.add(Duration(minutes: selectedHour*30)).hour.toString()
      :
      firstHourAsDate!.add(Duration(minutes: selectedHour*30)).hour.toString())
        + ":" +
          (firstHourAsDate!.add(Duration(minutes: selectedHour*30)).minute.toString() == '0' 
          ? '00'
          : firstHourAsDate!.add(Duration(minutes: selectedHour*30)).minute.toString());
    
    String finalSelectedDay = DateFormat('y-MM-dd').format(DateTime.now().add(Duration(days: selectedDay)));
    selectedDate = DateTime.parse(finalSelectedDay +' '+ finalSelectedHour + ':00').toLocal();

    notifyListeners();
  }

  int? getDiscountForHour(int index, DateTime hour){
    String selectedHour =  
    hour.add(Duration(minutes: index*30)).hour.toString()
        + ":" +
          (hour.add(Duration(minutes: index*30)).minute.toString() == '0' 
          ? '00'
          : hour.add(Duration(minutes: index*30)).minute.toString());
    List? hourAndDiscount = place.discounts![DateFormat("EEEE").format(DateTime.now().toLocal().add(Duration(days: selectedDay))).toLowerCase()];
    print(hourAndDiscount);
    if(hourAndDiscount != null)
      for(int i = 0; i< hourAndDiscount.length; i++)
        if(selectedHour.compareTo(hourAndDiscount[i].substring(0,5))>= 0 &&
        selectedHour.compareTo(hourAndDiscount[i].substring(6,11))< 0)
          return int.tryParse(hourAndDiscount[i].substring(12,14));
    return 0;
  }

  Future<Reservation?> makeReservation() async{
    _loading();

    try{

      var user = Authentication.auth.currentUser;

      var userReservationRef = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('reservations').doc();
      var placeReservationRef = place.reference!.collection('reservations').doc(userReservationRef.id);
      var reservationData = {
        'accepted': null,
        'date_created' : FieldValue.serverTimestamp(),
        'date_start': Timestamp.fromDate(selectedDate!),
        'guest_id' : user.uid,
        'guest_name' : selectedName != "" ? selectedName : (user.displayName != null ? user.displayName : ""),
        'place_id' : place.id,
        'place_name' : place.name,
        'contact_phone_number' : selectedPhoneNo,
        'contact_name' : selectedName,
        'details' : selectedDetails,
        'claimed' : null,
        'number_of_guests' : selectedPeopleNo + 1,
        'discount': getDiscountForHour(selectedHour, firstHourAsDate!),
        'deals': null,
        'user_reservation_ref': userReservationRef,
        'place_reservation_ref': placeReservationRef
      };
      await userReservationRef.set(reservationData);
      await placeReservationRef.set(reservationData);
      
      /// Update the user's phone number
      if(user.phoneNumber == null && selectedPhoneNo != "")
        await FirebaseFirestore.instance.collection('users').doc(user.uid)
        .set(
          {
            'contact_phone_number' : selectedPhoneNo
          },
          SetOptions(merge: true)
        );
      
      /// Update the user's display name
      if(user.displayName == null && selectedName != ""){
        await FirebaseFirestore.instance.collection('users').doc(user.uid)
        .set(
          {
            'display_name' : selectedName
          },
          SetOptions(merge: true)
        );
        await user.updateDisplayName(selectedName);
      }

      _loading();
      
      reservationData.update("date_created", (_) => DateTime.now().toLocal());
      return docWithIdAndDataAsArgsToReservation(
        userReservationRef.id, 
        reservationData,
        placeReservationRef,
        userReservationRef,
      );
    }
    catch(e){
      return null;
    }
  }

  String formatDealTooltip(List<Map<String, dynamic>> deals){
    String result = "";
    deals.forEach((deal) {
      result += deal['title'].toUpperCase()+ ":";
      result += "\n";
      result += "- "+ deal['content'].toUpperCase();
      result += "\n";
      result += "- "+ deal['interval'].toUpperCase();
      result += "\n";
      result += "- consumație minimă: " + deal['threshold'].toUpperCase();
      result += "\n";

      result += "\n\n";
    });
    return result;
  }

  void _loading(){
    isLoading = !isLoading;
    
    notifyListeners();
  }

}