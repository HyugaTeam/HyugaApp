import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/screens/new_reservation_popup_page/new_reservation_popup_provider.dart';
import 'package:hyuga_app/screens/reservation/reservation_page.dart';
import 'package:hyuga_app/screens/reservation/reservation_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';
import 'package:intl/intl.dart';

/// A bottom sheet that pops up where the USER selects the reservation's details
/// Firstly, the user than inputs the preffered DAY, HOUR & PEOPLE_NO
/// Secondly, the user than inputs the CONTACT PHONE NO & EXTRA DETAILS
class NewReservationPopupPage extends StatefulWidget {
  final BuildContext context;

  NewReservationPopupPage(this.context);

  @override
  State<NewReservationPopupPage> createState() => _NewReservationPopupPageState();
}

class _NewReservationPopupPageState extends State<NewReservationPopupPage> {

  ScrollController? _peopleNoScrollController;
  ScrollController? _dayScrollController;
  ScrollController? _hourScrollController;
  PageController _pageController = PageController(keepPage: false);

  GlobalKey<FormState> _phoneNoFormKey = GlobalKey<FormState>();
  bool _isFormEnabled = true;


  final currentTime = DateTime.now().toLocal();
  Map<String,dynamic>? schedule;
  


  @override
  void initState() {
    super.initState();
    _peopleNoScrollController = ScrollController(initialScrollOffset: MediaQuery.of(widget.context).size.width*0.16);
    _dayScrollController = ScrollController();
    _hourScrollController = ScrollController(initialScrollOffset: 0);
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<NewReservationPopupProvider>();
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    var place = provider.place;
    var selectedDate = provider.selectedDate;
    var selectedDay = provider.selectedDay;
    var selectedHour = provider.selectedHour;
    var selectedPeopleNo = provider.selectedPeopleNo;
    var selectedName = wrapperHomePageProvider.currentUser!.displayName != null ? wrapperHomePageProvider.currentUser!.displayName : provider.selectedName;
    var selectedPhoneNo = provider.selectedPhoneNo;
    var selectedDetails = provider.selectedDetails;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 400,
      child: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Container( /// First page of the PageView where the user inputs the DAY, HOUR & PEOPLE NUMBER
            padding: EdgeInsets.only(top: 20),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "În ce zi?",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                SizedBox(height: 15,),
                Container( /// Days list
                  height: 60,
                  width: double.infinity,
                  child: ListView.separated(
                    controller: _dayScrollController,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    separatorBuilder: (context,index)=>SizedBox(width: 10,),
                    itemBuilder: (context,index) => ChoiceChip(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: BorderSide(width: 1, color: Theme.of(context).primaryColor),
                      backgroundColor:Colors.grey[200],
                      selectedColor: Theme.of(context).primaryColor,
                      labelPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                      selected: index == selectedDay,
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            kWeekdays[DateFormat('EEEE').format(currentTime.add(Duration(days: index))).substring(0,3)]!,
                          ),
                          Text(
                            currentTime.add(Duration(days: index)).day.toString() 
                            + ' ' +
                            DateFormat('MMMM').format(currentTime.add(Duration(days: index))).substring(0,3),
                          )
                        ],
                      ),
                      onSelected: (selected){
                        provider.selectDay(index);
                        _dayScrollController!.animateTo(
                          (index-1)*93.toDouble(),
                          duration: Duration(milliseconds: 500), 
                          curve: Curves.ease
                        );
                      },
                    )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "La ce oră?",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                SizedBox(height: 15,),
                Container( /// Hours list
                  height: 60,
                  width: double.infinity,
                  child: ListView.separated(
                    controller: _hourScrollController,
                    padding: EdgeInsets.symmetric(horizontal: 10,),
                    scrollDirection: Axis.horizontal,
                    itemCount: place.schedule != null
                      ? (provider.endHour != "00:00" ? provider.hourDiff! * 2 + provider.minDiff! - 2 : provider.hourDiff! * 2 + 24 + provider.minDiff! - 2)
                      : 0,
                    separatorBuilder: (context,index)=>SizedBox(width: 10,),
                    itemBuilder: (context,index) {
                      GlobalKey _tooltipKey = GlobalKey();
                      var now = DateTime.now().toLocal();
                      int? discount = provider.getDiscountForHour(index, DateTime(now.year, now.month, now.day, int.parse(provider.startHour!.substring(0,2)), int.parse(provider.startHour!.substring(3,5))));
                      List<Map<String,dynamic>> deals = _getDealsForHour(provider.firstHourAsDate, selectedDay, place, index);
                      return  Opacity(
                        opacity: provider.firstHourAsDate!.add(Duration(minutes: index*30)).compareTo(DateTime.now()) < 0 && selectedDay == 0
                                    ? 0.4 : 1,
                        child: Stack(
                          // overflow: Overflow.visible,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: ChoiceChip(
                                labelPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                side: BorderSide(width: 1, color: Theme.of(context).primaryColor),
                                backgroundColor: Theme.of(context).canvasColor,
                                selectedColor: Theme.of(context).primaryColor,
                                selected: index == selectedHour,
                                label: Text(
                                  provider.firstHourAsDate!.add(Duration(minutes: index*30)).hour.toString()
                                  + ":" +
                                    (provider.firstHourAsDate!.add(Duration(minutes: index*30)).minute.toString() == '0' 
                                    ? '00' 
                                    : provider.firstHourAsDate!.add(Duration(minutes: index*30)).minute.toString()),
                                  style: Theme.of(context).textTheme.overline
                                ),
                                onSelected: (selected){
                                    provider.selectHour(index);
                                    _hourScrollController!.animateTo(
                                      (index-1.6)*93.toDouble(),
                                      duration: Duration(milliseconds: 500), 
                                      curve: Curves.ease
                                    );
                                  //}
                                },
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
                                  message: provider.formatDealTooltip(deals),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width*0.11,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color:  Theme.of(context).colorScheme.tertiary,
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
                            // discount != 0
                            // ? Positioned(
                            //   bottom: 0,
                            //   right: 0,
                            //   child: Container(
                            //     alignment: Alignment.center,
                            //     width: MediaQuery.of(context).size.width*0.11,
                            //     height: 20,
                            //     decoration: BoxDecoration(
                            //       color: Theme.of(context).primaryColor,
                            //       borderRadius: BorderRadius.circular(30)
                            //     ),
                            //     child: Text(
                            //       "-$discount%",
                            //       style: Theme.of(context).textTheme.caption,
                            //     ),
                            //   ),
                            // )
                            // : Container()
                          ],
                        ),
                      );
                    }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Câte persoane?",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container( /// How many people List
                  height: 60,
                  width: double.infinity,
                  child: ListView.separated(
                    controller: _peopleNoScrollController,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: 12,
                    separatorBuilder: (context,index) => SizedBox(width: 10,),
                    itemBuilder: (context,index) => ChoiceChip(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: BorderSide(width: 1, color: Theme.of(context).primaryColor),
                      backgroundColor: Theme.of(context).canvasColor,
                      labelPadding: EdgeInsets.symmetric(horizontal: 20),
                      label: Text((index+1).toString()),
                      selected: index == selectedPeopleNo,
                      selectedColor: Theme.of(context).primaryColor,
                      onSelected: (selected){
                        provider.selectPeopleNo(index);
                        _peopleNoScrollController!.animateTo(
                          (index-2)*68.toDouble() - 6,
                          duration: Duration(milliseconds: 500), 
                          curve: Curves.easeIn
                        );
                      },
                    )
                  ),
                ),
                Expanded(
                  child: Container()
                ),
                provider.isLoading 
                ? Container(
                  height: 5,
                  width: MediaQuery.of(context).size.width,
                  child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
                )
                : Container(), 
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: FloatingActionButton.extended(
                    shape: ContinuousRectangleBorder(),
                    elevation: 0,
                    onPressed: (){
                      provider.selectDate();
                      _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
                    },
                    label: Text("Alege", style: Theme.of(context).textTheme.headline4,)
                  ),
                ),
              ]
            ),
          ),
          Container( /// Second page of the PageView where the user inputs the contact phone number
            padding: EdgeInsets.only(top: 20, ),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Nume",
                    style: Theme.of(context).textTheme.headline6
                  ),
                ),
                SizedBox(height: 15,),
                Container(
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.65,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          child: TextFormField(
                            enabled: _isFormEnabled,
                            style: TextStyle(
                              color: _isFormEnabled
                                ? Colors.black
                                : Colors.grey[600],
                            ),
                            initialValue: selectedName != "" ? selectedName : null,
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
                            onChanged: (input) => provider.selectName(input),
                            keyboardType: TextInputType.name,
                            cursorColor: Theme.of(context).primaryColor,
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
                          //tooltip: "Modifică numărul de telefon",
                          onPressed: () => setState(() => _isFormEnabled = true), 
                          iconSize: 16,
                          color: Theme.of(context).primaryColor,
                          // splashColor:  Theme.of(context).colorScheme.secondary,
                          // highlightColor:  Theme.of(context).colorScheme.secondary,
                          icon: Image.asset(localAsset("edit"), width: 15,)
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Număr de telefon",
                    style: Theme.of(context).textTheme.headline6
                  ),
                ),
                SizedBox(height: 15,),
                Container(
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.65,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: _phoneNoFormKey,
                          child: TextFormField(
                            enabled: _isFormEnabled,
                            style: TextStyle(
                              color: _isFormEnabled
                                ? Colors.black
                                : Colors.grey[600],
                            ),
                            initialValue: selectedPhoneNo != "" ? selectedPhoneNo : null,
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
                            onChanged: (input) => provider.selectPhoneNo(input),
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
                          //tooltip: "Modifică numărul de telefon",
                          onPressed: () => setState(() => _isFormEnabled = true), 
                          iconSize: 16,
                          color: Theme.of(context).primaryColor,
                          // splashColor:  Theme.of(context).colorScheme.secondary,
                          // highlightColor:  Theme.of(context).colorScheme.secondary,
                          icon: Image.asset(localAsset("edit"), width: 15,)
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text.rich( /// The Details 
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Detalii", style: Theme.of(context).textTheme.headline6
                        ),
                        WidgetSpan(child: SizedBox(width: 10)),
                        WidgetSpan(child: Tooltip(
                          child: Image.asset(localAsset("question"), width: 17, color: Colors.grey[500]), 
                          message: "Dacă aveți alte informații legate de rezervare, vă rugăm să le adăugați aici",
                          verticalOffset: -50,
                          height: 50,
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: Duration(milliseconds: 1000),
                        )),
                      ]
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                Container(
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.65,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          child: TextFormField(
                            enabled: _isFormEnabled,
                            style: TextStyle(
                              color: _isFormEnabled
                                ? Colors.black
                                : Colors.grey[600],
                            ),
                            initialValue: selectedDetails,
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
                            onChanged: (input) => provider.selectDetails(input),
                            cursorColor: Theme.of(context).primaryColor,
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
                          //tooltip: "Modifică numărul de telefon",
                          onPressed: () => setState(() => _isFormEnabled = true), 
                          iconSize: 16,
                          color: Theme.of(context).primaryColor,
                          // splashColor:  Theme.of(context).colorScheme.secondary,
                          // highlightColor:  Theme.of(context).colorScheme.secondary,
                          icon: Image.asset(localAsset("edit"), width: 15,)
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container()
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: FloatingActionButton.extended(
                    shape: ContinuousRectangleBorder(),
                    elevation: 0,
                    onPressed: (){
                      if(_phoneNoFormKey.currentState!.validate()){
                        _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                    },
                    label: Text("Alege", style: Theme.of(context).textTheme.headline4,)
                  ),
                ),
              ],
            )
          ),
          Container( /// Third page of the PageView where the user reviews the data
            padding: EdgeInsets.only(top: 20),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Datele rezervării",
                    style: Theme.of(context).textTheme.headline6
                  ),
                ),
                SizedBox(height: 15,),
                Column(
                  children: [
                    Text.rich( /// Place's name 
                      TextSpan(
                        children: [
                          WidgetSpan(child: Icon(Icons.place_outlined, size: 19)),
                          WidgetSpan(child: SizedBox(width: 10)),
                          TextSpan(
                            text: place.name
                          ),
                        ]
                      )
                    ),
                    SizedBox(height: 20),
                    Row(/// TIME, DATE and PEOPLE_NNUMBER
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text.rich( /// The Time 
                          TextSpan(
                            children: [
                              WidgetSpan(child: Image.asset(localAsset('time'), width: 18)),
                              WidgetSpan(child: SizedBox(width: 10)),
                              TextSpan(
                                text: formatDateToHourAndMinutes(selectedDate)
                              ),
                            ]
                          )
                        ),
                        Text.rich( /// The Date
                          TextSpan(
                            children: [
                              WidgetSpan(child: Image.asset(localAsset('calendar'), width: 18)),
                              WidgetSpan(child: SizedBox(width: 10)),
                              TextSpan(
                                text: formatDateToDay(selectedDate)
                              ),
                            ]
                          )
                        ),
                        Text.rich( /// The People Number
                          TextSpan(
                            children: [
                              WidgetSpan(child: Image.asset(localAsset('user'), width: 15)),
                              WidgetSpan(child: SizedBox(width: 10)),
                              TextSpan(
                                text: (selectedPeopleNo + 1).toString()
                              ),
                            ]
                          )
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text.rich( /// The Details 
                      TextSpan(
                        children: [
                          WidgetSpan(child: Image.asset(localAsset('detail'), width: 20)),
                          WidgetSpan(child: SizedBox(width: 10)),
                          TextSpan(
                            text: selectedDetails != "" ? (selectedDetails.length <= 15 ? selectedDetails : selectedDetails.substring(13) + "...") : " - "
                          ),
                        ]
                      )
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Datele utilizatorului",
                    style: Theme.of(context).textTheme.headline6
                  ),
                ),
                SizedBox(height: 15),
                Column(
                  children: [
                    Text.rich( /// The User's name
                      TextSpan(
                        children: [
                          WidgetSpan(child: Icon(Icons.person_outline, size: 20)),
                          WidgetSpan(child: SizedBox(width: 10)),
                          TextSpan(
                            text: selectedName
                          ),
                        ]
                      )
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text.rich( /// The Phone Number 
                          TextSpan(
                            children: [
                              WidgetSpan(child: Image.asset(localAsset('phone'), width: 20)),
                              WidgetSpan(child: SizedBox(width: 10)),
                              TextSpan(
                                text: selectedPhoneNo != "" ? selectedPhoneNo : " - "
                              ),
                            ]
                          )
                        ),
                        Text.rich( /// The Email 
                          TextSpan(
                            children: [
                              WidgetSpan(child: Icon(Icons.email_outlined, size: 20)),
                              WidgetSpan(child: SizedBox(width: 10)),
                              TextSpan(
                                text: Provider.of<User>(context, listen: false).email!.length < 25
                                ? Provider.of<User>(context, listen: false).email! 
                                : Provider.of<User>(context, listen: false).email!.substring(0,3) + "..." + Provider.of<User>(context, listen: false).email!.substring(Provider.of<User>(context, listen: false).email!.indexOf("@") -5)
                              ),
                            ]
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Container()
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: FloatingActionButton.extended(
                    shape: ContinuousRectangleBorder(),
                    elevation: 0,
                    onPressed: () async{
                      var reservation = await provider.makeReservation();
                      if(reservation != null){
                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          MultiProvider(
                            providers: [
                              ChangeNotifierProvider(create: (context) => ReservationPageProvider(reservation, place.image! ,wrapperHomePageProvider),),
                              ChangeNotifierProvider.value(value: wrapperHomePageProvider)
                            ],
                            child: ReservationPage(),
                          )
                        ));
                      }
                      else{
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("A apărut o eroare"),
                        ));
                      }
                    },
                    label: Text("Rezervă", style: Theme.of(context).textTheme.headline4,)
                  ),
                ),
              ],
            )
          )
        ],
      ),
    );
  }

  List<Map<String,dynamic>> _getDealsForHour(DateTime? firstHourAsDate, int selectedDay, Place place, int index){
    String selectedHour =  
    firstHourAsDate!.add(Duration(minutes: index*30)).hour.toString()
        + ":" +
          (firstHourAsDate.add(Duration(minutes: index*30)).minute.toString() == '0' 
          ? '00'
          : firstHourAsDate.add(Duration(minutes: index*30)).minute.toString());
    List? hourAndDeals = place.deals![DateFormat("EEEE").format(DateTime.now().toLocal().add(Duration(days: selectedDay))).toLowerCase()];
    List<Map<String,dynamic>> deals = <Map<String,dynamic>>[];
    if(hourAndDeals != null)
      for(int i = 0; i< hourAndDeals.length; i++)
        if(selectedHour.compareTo(hourAndDeals[i]['interval'].substring(0,5))>= 0 &&
          selectedHour.compareTo(hourAndDeals[i]['interval'].substring(6,11))< 0)
          deals.add(hourAndDeals[i]);
    return deals;
  }
}