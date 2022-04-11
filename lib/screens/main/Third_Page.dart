import 'dart:typed_data';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/screens/drawer/ReservationsHistory_Page.dart.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/Reservation_Panel.dart';
import 'package:hyuga_app/widgets/drawer.dart';
import 'package:intl/intl.dart'; // ADDED FOR THE DATE FORMATTING SYSTEM
import 'package:provider/provider.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:url_launcher/url_launcher.dart';
import 'package:hyuga_app/screens/main/home/DealItem_Page.dart';
import 'package:hyuga_app/models/deal.dart';



// The generator of the third page
class ThirdPageGenerator{

  //Function which generates the ThirdPage
  static Route<dynamic> generateRoute(RouteSettings settings){
    List<dynamic> args = settings.arguments as List<dynamic>;
    Local local = args[0];  // This is the first argument(The 'Local')
    bool onlyDiscounts = args[1]; // This is the second argument(whether it shows only discounts or not)
    return MaterialPageRoute(
      builder: (_) => ThirdPage(
        local: local,
        onlyDiscounts: onlyDiscounts
      )
    );
  }
}



class ThirdPage extends StatefulWidget {

  final Local? local;
  final bool? onlyDiscounts;
  
  ThirdPage({this.local,this.onlyDiscounts}){
    
    ///Added for test
    if(this.onlyDiscounts == null){
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": local!.id,
          "place_name": local!.name,
          //"place_path": "${g.whereListTranslation[g.selectedWhere]}_${g.whatListTranslation[g.selectedWhere][g.selectedWhat]}_${g.howManyListTranslation[g.selectedHowMany]}_${g.ambianceListTranslation[g.selectedAmbiance]}_${g.areaListTranslation[g.selectedArea]}"
        }
      ).then((value) => print(local!.id!+local!.name!));
    }
    else{
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": local!.id,
          "place_name": local!.name,
          "place_path": "only_discounts"
        }
      );
    }
  }

  @override
  _ThirdPageState createState() => _ThirdPageState(
    localLongitude: local!.location!.longitude,
    localLatitude: local!.location!.latitude
  );
}

class _ThirdPageState extends State<ThirdPage> with TickerProviderStateMixin{

  Map<String?,String> weekdays = {"Monday" : "Luni", "Tuesday" : "Marti","Wednesday" : "Miercuri","Thursday" : "Joi","Friday" : "Vineri","Saturday" : "Sambata", "Sunday" : "Duminica"};
  Future<Image?>? _firstImage;
  Future <Image?>? _secondImage;
  Future <Image?>? _thirdImage;
  late DateTime today;
  
  int _selectedWeekday = 0;
  double titleOpacity = 0.0;

  late AnimationController _animationController;
  Animation<double>? _animation;

  // GlobalKey _reservationButtonKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
    initialScrollOffset: 0
  );
  ScrollPhysics _scrollPhysics = ScrollPhysics();
  ScrollController _listViewScrollController = ScrollController(

  );
  double dealWidgetHeight = 100;
  List<bool>? isOfferExpanded;
  final double? localLongitude,localLatitude;
  List<Uint8List>? listOfImages;

  _ThirdPageState({this.localLongitude,this.localLatitude}){
    today = DateTime.now().toLocal();
    _selectedWeekday = today.weekday;
    print(_selectedWeekday);
  }
  
  Future<Image?> _getFirstImage() async{
    Uint8List? imageFile;
    int maxSize = 6*1024*1024;
    String? fileName = widget.local!.id;
    String pathName = 'photos/europe/bucharest/$fileName';
    var storageRef = FirebaseStorage.instance.ref().child(pathName);
    try{
      await storageRef.child('$fileName'+'_1.jpg')
        .getData(maxSize).then((data){
          imageFile = data;
          }
        );
      return Image.memory(
        imageFile!,
        frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            child: child,
            opacity: frame == null ? 0 : 1,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      );
    }
    catch(error){
      print(error);
    }
    return null; // if nothing else happens
  }

  Future<Image?> _getSecondImage() async{
    Uint8List? imageFile;
      int maxSize = 6*1024*1024;
      String? fileName = widget.local!.id;
      String pathName = 'photos/europe/bucharest/$fileName';
      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      try{
        await storageRef.child('$fileName'+'_2.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
        return Image.memory(
          imageFile!,
          frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }
            return AnimatedOpacity(
              child: child,
              opacity: frame == null ? 0 : 1,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        );
      }
      catch(error){
        print(error);
      }
      return null; // if nothing else happens
  }

  Future<Image?> _getThirdImage() async{
    Uint8List? imageFile;
      int maxSize = 6*1024*1024;
      String? fileName = widget.local!.id;
      String pathName = 'photos/europe/bucharest/$fileName';
      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      try{
        await storageRef.child('$fileName'+'_m.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
        return Image.memory(
          imageFile!,
          frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }
            return AnimatedOpacity(
              child: child,
              opacity: frame == null ? 0 : 1,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        );
      }
      catch(error){
        print(error);
      }
      return null; // if nothing else happens
  }

  // Launches both Uber app and Place's Menu
  Future<void> _launchInBrowser(BuildContext context, String url, [bool universalLinks = false]) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: universalLinks,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else if(!universalLinks){
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Meniul nu este disponibil"
          )
        )
      );
    }
  }

  Future<void> dialPhoneNumber(int? phoneNumber) async{
    String url = "tel:+$phoneNumber";   
    if (await canLaunch(url)) {
       await launch(url);
    } else {
      throw 'Could not launch $url';
    }   
  }
  
  /// Deprecated
  double getDiscountForUser(double maxDiscount){
    List<num> userDiscounts = g.discounts.firstWhere((element) => element['maxim'] == maxDiscount)['per_level'] as List<num>;
    return userDiscounts[authService.currentUser!.getLevel()].toDouble();
  }


  Color getDealColor(Deal deal){
    if(deal.title!.toLowerCase().contains("alb"))
      return Color(0xFFCFBA70);
      //return Theme.of(context).highlightColor;
    else if(deal.title!.toLowerCase().contains("roșu") || deal.title!.toLowerCase().contains("rosu"))
      return Color(0xFF600F2B);
      //return Theme.of(context).primaryColor;
    else return Color(0xFFb78a97);
    //return Theme.of(context).accentColor;
  }

  // Configures how the title is progressively shown as the user's scrolling the page downwards
  @override
  void initState(){
    if(widget.local!.deals != null)
      if(widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()] != null)
        isOfferExpanded = widget.local!
          .deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()]
          .map<bool>((key) => false).toList();
    print(isOfferExpanded);
    _firstImage = _getFirstImage();
    _secondImage = _getSecondImage();
    _thirdImage = _getThirdImage();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000)
    );
    _animation = CurvedAnimation(
      parent: _animationController, 
      curve: Curves.elasticInOut
    );

    // _listViewScrollController.attach(ScrollPosition(
    //   context: ScrollContext(),
    //   physics: ScrollP
    // ));

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.offset<197){
          titleOpacity = 0;
        }
        else 
          if(_scrollController.offset >= 197 && _scrollController.offset< 220)
            titleOpacity = (_scrollController.offset-195)*4/100;
          else titleOpacity = 1;
      });
    });
    super.initState();
  }

  Future _openReservationDialog(BuildContext context) async{
    SnackBarBehavior _snackBarBehavior = SnackBarBehavior.floating;
    if(!authService.currentUser!.isAnonymous!){
      if(widget.local!.hasReservations == true){
        await FirebaseFirestore.instance.collection('users').doc(authService.currentUser!.uid)
        .collection('reservations_history')
        .where('date_start', isGreaterThan: Timestamp.fromDate(DateTime.now().toLocal())).get().then((value){
          print(value.docs.length);
          bool ok = true;
          /// Checks if there are any upcoming unclaimed reservations
          value.docs.forEach((element) { 
            if(element.data()['accepted'] == null || (element.data()['accepted'] == true && element.data()['claimed'] == null))
              ok = false;
          });
          if(!ok){
              if(g.isSnackBarActive == true)
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: _snackBarBehavior,
                  content: MaterialButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ReservationsHistoryPage()));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Ai deja o rezervare."),
                    ],
                    ),
                  ),
                )
              );
            }
          else if(widget.local!.hasReservations == true)
            if(widget.local!.preferPhone == true) {
              dialPhoneNumber(widget.local!.phoneNumber);
            }
            else {
              showGeneralDialog(
                context: context,
                transitionDuration: Duration(milliseconds: 600),
                barrierLabel: "",
                barrierDismissible: true,
                transitionBuilder: (context,animation,secAnimation,child){
                  CurvedAnimation _anim = CurvedAnimation(
                    parent: animation,
                    curve: Curves.bounceInOut,
                    reverseCurve: Curves.easeOutExpo
                  );
                  return ScaleTransition(
                    scale: _anim,
                    child: child
                  );
                },
                pageBuilder: (newContext,animation,secAnimation){
                  return Provider(
                    create: (context) => widget.local, 
                    child: ReservationPanel(context:newContext)
                  );
                }).then((reservation) => reservation != null 
                ? ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: _snackBarBehavior,
                    content: Text("Se asteapta confirmare pentru rezervarea facuta la ${(reservation as Map)['place_name']} pentru ora ${reservation['hour']}")
                  )
                )
                : null
              ); 
            }
        });
      }
      else ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: _snackBarBehavior,
          content: Text("Localul nu accepta rezervari")
        ));
      }
      else if(authService.currentUser!.isAnonymous == true)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: _snackBarBehavior,
            content: Text("Trebuie sa te loghezi pentru a face rezervari."),
            action: SnackBarAction(
              textColor: Colors.white,
              label: "Log In", 
              onPressed: () async{
                await authService.signOut();
                Navigator.popUntil(context, (Route route){
                  return route.isFirst ? true : false;
                });
              }
            ),
            backgroundColor: Theme.of(context).accentColor,
          ),
        );
  }

  ///Method that builds the FAB widget with "rezervă o masă"
  FloatingActionButton _buildFloatingActionButton(BuildContext context) => FloatingActionButton.extended(
    elevation: 10,
    shape: ContinuousRectangleBorder(),
    backgroundColor: Theme.of(context).accentColor,
    onPressed: () => _openReservationDialog(context),
    label: Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        "Rezervă o masă",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingActionButton(context),
      drawer: ProfileDrawer(),
      extendBodyBehindAppBar: true,
      body: Builder(
        builder: (context) { 
          _animationController.forward();
          return NestedScrollView(
            controller: _scrollController,
            physics: _scrollPhysics,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  title: Opacity(
                      opacity: titleOpacity,
                      child: Center(
                        child: Text(widget.local!.name!),
                      ),
                  ),
                  expandedHeight: 220,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: widget.local!.name!,
                      child: FutureBuilder<Image>(
                        future: widget.local!.image,
                        builder: (context,image){
                          if(widget.local!.finalImage == null)
                            return Container(
                              width: 400,
                              height: 200,
                              color: Colors.white,
                            );
                          else 
                            return Container(
                              color: Colors.white,
                              child: image.data
                            );
                        }
                      ),
                    ),
                  ),
                  backgroundColor: Theme.of(context).accentColor,
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: (){
                      Navigator.pop(context);
                    }
                  ),
                ),
              ];
            },
            body: Container(
              child: ListView(
               // controller: _listViewScrollController,
               // physics: ScrollPhysics(parent: _scrollPhysics),
                //physics: NeverScrollableScrollPhysics(parent: _scrollPhysics),
                children: [
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container( // Name
                            alignment: Alignment(-0.8, 1),
                            width: 300,
                            padding: EdgeInsets.only(
                              left: 20,
                              bottom:10
                            ),
                            child: Text(
                              widget.local!.name==null? 'wrong':widget.local!.name!,
                              maxLines: 2,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 21,
                                fontWeight: FontWeight.values[5]
                              ),
                            )
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 30,top: 8),
                            constraints: BoxConstraints(
                              maxWidth: 100,
                              maxHeight: 50
                            ),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: widget.local!.cost,
                                itemBuilder: (context, costIndex){
                                  return FaIcon(FontAwesomeIcons.dollarSign, color: Theme.of(context).accentColor,);
                                },
                              ),
                          )                      
                        ],
                      ),
                      Container( // Thin line
                        padding: EdgeInsets.only(top:10),
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.orange[600]!,
                              //Theme.of(context).accentColor,
                              //Theme.of(context).primaryColor,
                              Colors.white
                            ]
                          )
                        ),
                      ),
                      SizedBox(height: 15,),
                      !widget.local!.isPartner!
                      ? Text(
                        "Localul nu este partener",
                        style: TextStyle(
                          fontSize: 18
                        ),
                      )
                      :
                      Column(
                        children: [
                          DropdownButton( /// 'Select the Day' widget
                            value: weekdays.keys.toList()[_selectedWeekday-1],
                            items: weekdays.keys
                            .map((String? weekday) {
                              return DropdownMenuItem(
                                value: weekday,
                                child: Text(
                                  weekday != DateFormat("EEEE").format(today)
                                  ? weekdays[weekday]! 
                                  : "Astazi - "+  weekdays[weekday]! 
                                ),
                              );
                            }).toList(),
                            onChanged: (dynamic value){
                              setState((){
                                _selectedWeekday = weekdays.keys.toList().indexOf(value)+1;
                                if(widget.local!.deals != null)
                                  if(widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()] != null)
                                    isOfferExpanded = widget.local!
                                      .deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()]
                                      .map<bool>((key) => false).toList();
                              });
                            }
                          ),
                          /// The new widget for both deals & discounts
                          widget.local!.discounts != null && widget.local!.discounts![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()] != null
                          ||
                          widget.local!.deals != null && widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()] != null
                          ? Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                alignment: Alignment(-1,0),
                                child: Text(
                                  "Oferte",
                                  style: TextStyle(
                                    fontSize: 20,
                                    //fontWeight: FontWeight.bold
                                  ),
                                )
                              ),
                              Container( /// The list of deals & discounts
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                width: double.infinity,
                                height: 145,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: widget.local!.deals != null ?  
                                            (widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()] != null? 
                                              widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()].length : 0): 
                                            0,
                                  separatorBuilder: (BuildContext context, int index) => SizedBox(width: 20,),
                                  itemBuilder: (context,index) { 
                                    Deal deal = Deal(
                                      title: widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()][index]['title'], 
                                      content: widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()][index]['content'], 
                                      interval: widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()][index]['interval']
                                    );
                                    return OpenContainer(  
                                      closedColor: Colors.transparent,
                                      closedElevation: 0,
                                      openElevation: 0,
                                      closedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero
                                      ),
                                      openBuilder: (context, f) => DealItemPage(
                                        place:  this.widget.local,
                                        deal: deal,
                                        dealDayOfTheWeek: _selectedWeekday,
                                      ),
              //                         onClosed: (value) {
              //                           try{
              //                             if(value.containsKey("new_reservation"))
              //                               showGeneralDialog(
              //   context: context,
              //   transitionDuration: Duration(milliseconds: 600),
              //   barrierLabel: "",
              //   barrierDismissible: true,
              //   transitionBuilder: (context,animation,secAnimation,child){
              //     CurvedAnimation _anim = CurvedAnimation(
              //       parent: animation,
              //       curve: Curves.bounceInOut,
              //       reverseCurve: Curves.easeOutExpo
              //     );
              //     return ScaleTransition(
              //       scale: _anim,
              //       child: child
              //     );
              //   },
              //   pageBuilder: (newContext,animation,secAnimation){
              //     return Provider(
              //       create: (context) => widget.local, 
              //       child: ReservationPanel(context:newContext)
              //     );
              //   }).then((reservation) => reservation != null 
              //   ? Scaffold.of(context).showSnackBar(
              //     SnackBar(
              //       behavior: SnackBarBehavior.floating,
              //       content: Text("Se asteapta confirmare pentru rezervarea facuta la ${reservation['place_name']} pentru ora ${reservation['hour']}")
              //     )
              //   )
              //   : null
              // ); 
              //                           }
              //                           catch(e){}
              //                         },
                                      closedBuilder: (context, f) => GestureDetector(
                                        child: Container(
                                          margin: EdgeInsets.all(7),
                                          //padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 0,
                                                blurRadius: 0,
                                                offset: Offset(0, 0), // changes position of shadow
                                              ),
                                            ]
                                          ),
                                          child: Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                                                  height: 50,
                                                  width: double.infinity,
                                                  color: getDealColor(deal),
                                                  //color: Theme.of(context).accentColor,
                                                  child: Text(
                                                    widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()][index]['title'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14*(1/MediaQuery.of(context).textScaleFactor)
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  "consumație minimă:\n" 
                                                  +
                                                  (widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()][index].containsKey('threshold')
                                                  ? widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()][index]['threshold']
                                                  : "*click*"),
                                                  //widget.local!.deals![weekdays.keys.toList()[_selectedWeekday-1]!.toLowerCase()][index]['interval'],
                                                  style: TextStyle(
                                                    fontSize: 14*(1/MediaQuery.of(context).textScaleFactor)
                                                  )
                                                )
                                              )
                                            ],
                                          ),
                                          height: 125,
                                          width: 120,
                                        ),
                                        onTap: f,
                                      ),
                                    );
                                  }
                                ),
                              ),
                            ],
                          )
                          // ? Column( // The place has EITHER 'Discounts' or 'Deals'
                          //   children: [
                          //     // The 'Deals' Widget
                          //     widget.local.deals != null && widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null
                          //     ? Container(
                          //       child: Column(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //             children: [
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Text("Oferte", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                          //               ),
                          //               SizedBox(
                          //                 width: 150
                          //               )
                          //             ],
                          //           ),
                          //           SizedBox(height: 10,),
                          //           AnimatedContainer(
                          //             //color: Colors.orange[600],
                          //             duration: Duration(milliseconds: 200),
                          //             height: dealWidgetHeight,
                          //             child: ListView.separated(
                          //               padding: EdgeInsets.all(10),
                          //               scrollDirection: Axis.horizontal,
                          //               itemCount: widget.local.deals != null ?  
                          //                           (widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null? 
                          //                             widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()].length : 0): 
                          //                           0,
                          //               separatorBuilder: (BuildContext context, int index) => SizedBox(width: 10,),
                          //               itemBuilder: (context,index) {
                          //                 ValueKey key = ValueKey(index);
                          //                 return Container(
                          //                   height: 120,
                          //                   width: 180,
                          //                   constraints: BoxConstraints(maxHeight: 100),
                          //                   decoration: BoxDecoration(
                          //                     borderRadius: BorderRadius.circular(10),
                          //                   ),
                          //                   child: ExpansionCard(
                          //                     trailing: GestureDetector(
                          //                       onTap: (){
                          //                         Navigator.push(context, MaterialPageRoute(builder: (context) => UserQRCode(context)));
                          //                       },
                          //                       child: FaIcon(
                          //                         FontAwesomeIcons.qrcode,
                          //                         color: Colors.black,
                          //                         size: 26,
                          //                       ),
                          //                     ),
                          //                     key: key,
                          //                     borderRadius: 20,
                          //                     backgroundColor: Colors.orange[600],
                          //                     margin: EdgeInsets.zero,
                          //                     title: Column(
                          //                       mainAxisSize: MainAxisSize.min,
                          //                       mainAxisAlignment: MainAxisAlignment.center,
                          //                       children: [
                          //                         Text(
                          //                           widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index]['title'],
                          //                           style: TextStyle(color: Colors.black,fontSize: 13*(1/MediaQuery.of(context).textScaleFactor), fontWeight: FontWeight.bold),
                          //                         ),
                          //                         Divider(
                          //                           thickness: 2
                          //                         ),
                          //                         Text(widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                          //                           [index]['interval'].substring(0,5) 
                          //                           +  ' - ' + 
                          //                           widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                          //                           [index]['interval'].substring(6,11),
                          //                           style: TextStyle(
                          //                             fontSize: 16*(1/MediaQuery.of(context).textScaleFactor),
                          //                             color: Colors.black
                          //                           ),
                          //                         )  // 
                          //                       ],
                          //                     ),
                          //                     children: [
                          //                       Padding(
                          //                         padding: const EdgeInsets.all(8.0),
                          //                         child: Text(
                          //                           widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index]['content'],
                          //                           style: TextStyle(
                          //                             fontSize: 14*(1/MediaQuery.of(context).textScaleFactor),
                          //                           ),
                          //                         ),
                          //                       )
                          //                     ],
                          //                     onExpansionChanged: (expanded) => setState((){
                          //                       isOfferExpanded[index] = expanded;
                          //                       bool allClosed = true;
                          //                       isOfferExpanded.forEach((element) {if(element) allClosed = false;});
                          //                       if(allClosed)
                          //                         dealWidgetHeight = 100;
                          //                       else dealWidgetHeight = 180;
                          //                       }
                          //                     ),
                          //                   ),
                          //                 );
                          //               }
                          //             )
                          //           ),
                          //         ],
                          //       ),
                          //     )
                          //     : Container(),
                          //     // The 'Discounts' Widget
                          //     widget.local.discounts != null && widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null
                          //     ? Container(
                          //       child: Column(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //             children: [
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Text("Reduceri", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                          //               ),
                          //               SizedBox(width: MediaQuery.of(context).size.width*0.2,)
                          //             ],
                          //           ),
                          //           Container(
                          //             height: 110,
                          //             child: ListView.separated(
                          //               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          //               scrollDirection: Axis.horizontal,
                          //               itemCount: widget.local.discounts != null ?  
                          //                           (widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null? 
                          //                             widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()].length : 0): 
                          //                           0,
                          //               separatorBuilder: (BuildContext context, int index) => SizedBox(width: 10,),
                          //               /// ^^^ This comparison checks if in the 'discounts' Map field imported from Firebase exist any discounts related to 
                          //               /// the current weekday. If not, the field will be empty
                          //               itemBuilder: (BuildContext context, int index){
                          //                 return Hero(
                          //                   tag: "discounts"+index.toString(),
                                            
                          //                   child: Container(
                          //                     width: MediaQuery.of(context).size.width*0.35,
                          //                     height: 110,
                          //                     child: Column(
                          //                       children: <Widget>[
                          //                         GestureDetector(
                          //                           onTap: (){
                          //                             // RenderBox object = _reservationButtonKey.currentContext.findRenderObject();
                          //                             // var size = object.localToGlobal(Offset.zero);
                          //                             // print(size.dy+1000);
                          //                             // _listViewScrollController.animateTo(
                          //                             //   size.dy,
                          //                             //   curve: Curves.linear,
                          //                             //   duration: Duration(milliseconds: 300)
                          //                             // ).then(
                          //                             //   (value) {
                          //                                 // if(g.isSnackBarActive == false){
                          //                                 //   g.isSnackBarActive = true;
                          //                                 //   Scaffold.of(context).showSnackBar(
                          //                                 //     SnackBar(
                          //                                 //       content: Text(
                          //                                 //         "Vino in local si scaneaza codul sau fa o rezervare in intervalul dorit pentru a primi reducerea.",
                          //                                 //         textAlign: TextAlign.center,
                          //                                 //       ),
                          //                                 //       backgroundColor: Colors.orange[600],
                          //                                 //     )).closed.then((SnackBarClosedReason reason){
                          //                                 //     g.isSnackBarActive = false;
                          //                                 //   });
                          //                                 // }
                          //                             // }
                          //                             //);
                          //                             //Navigator.push(context, MaterialPageRoute(builder: (context)=>UserQRCode(context)));
                          //                               showGeneralDialog(
                          //                                 context: context,
                          //                                 transitionDuration: Duration(milliseconds: 200),
                          //                                 barrierLabel: "",
                          //                                 barrierDismissible: true,
                          //                                 // transitionBuilder: (context,animation,secAnimation,child){
                          //                                 //   CurvedAnimation _anim = CurvedAnimation(
                          //                                 //     parent: animation,
                          //                                 //     curve: Curves.bounceInOut,
                          //                                 //     reverseCurve: Curves.easeOutExpo
                          //                                 //   );
                          //                                 //   return ScaleTransition(
                          //                                 //     scale: _anim,
                          //                                 //     child: child
                          //                                 //   );
                          //                                 // },
                          //                                 pageBuilder: (context, anim, secAnim) => DiscountHeroPage(
                          //                                   heroTag: "discounts"+index.toString(),
                          //                                   interval: widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                          //                                       [index].substring(0,5) 
                          //                                       +  ' - ' + 
                          //                                       widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                          //                                       [index].substring(6,11),
                          //                                   discount: int.parse(widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index].substring(12,14)),
                          //                                 )
                          //                               );
                          //                               // Navigator.push(context, MaterialPageRoute(
                          //                               //   builder: (context) => 
                          //                               //   DiscountHeroPage(
                          //                               //     heroTag: "discounts"+index.toString(),
                          //                               //     interval: widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                          //                               //         [index].substring(0,5) 
                          //                               //         +  ' - ' + 
                          //                               //         widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                          //                               //         [index].substring(6,11),
                          //                               //     discount: int.parse(widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index].substring(12,14)),
                          //                               //   )
                          //                               // ));
                                                      
                          //                           },
                          //                           child: Container(
                          //                             padding: EdgeInsets.symmetric(vertical: 5),
                          //                             alignment: Alignment.center,
                          //                             height: 40,
                          //                             decoration: BoxDecoration(
                          //                               boxShadow: [
                          //                                 BoxShadow(
                          //                                   color: Colors.black45, 
                          //                                   offset: Offset(-1,1),
                          //                                   blurRadius: 2,
                          //                                   spreadRadius: 0.2
                          //                                 )
                          //                               ],
                          //                               color: Colors.orange[600],
                          //                               borderRadius: BorderRadius.circular(25)
                          //                             ),
                          //                             child: Text(
                          //                               widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                          //                               [index].substring(0,5) 
                          //                               +  ' - ' + 
                          //                               widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                          //                               [index].substring(6,11),
                          //                               textAlign: TextAlign.center,
                          //                               style: TextStyle(
                          //                                 fontSize: 16*(1/MediaQuery.of(context).textScaleFactor),
                          //                                 //fontFamily: 'Roboto'
                          //                             ),
                          //                               ),
                          //                           ),
                          //                         ),
                          //                         Padding(
                          //                           padding: EdgeInsets.all(10),
                          //                           child: Text(
                          //                             '-'+int.parse(widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index].substring(12,14))
                          //                             .toString() + '%',
                          //                             /// Old computation for the Discount per level
                          //                             style: TextStyle(
                          //                               fontSize: 20,
                          //                             )
                          //                           )
                          //                         )
                          //                       ],
                          //                     ),
                          //                   ),
                          //                 );
                          //               }
                          //             ),
                          //           ),
                                    
                          //         ],
                          //       ),
                          //     )
                          //     : Container()
                          //   ]
                          // )
                      : Padding( // The place has NEITHER 'Discounts' or 'Deals'
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          "Localul nu are ${weekdays[weekdays.keys.toList()[_selectedWeekday-1]]!.toLowerCase()} oferte sau reduceri.", 
                        ),
                      )
                      ]
                      ),
                      Container( // 'Description'
                        alignment: Alignment(-0.9, 0),
                        padding: EdgeInsets.only(top:20),
                        child: Text(
                          'Descriere',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          ),
                        )
                      ),
                      Container( // Description text
                        alignment: Alignment(-0.8, 0),
                        padding: EdgeInsets.only(top:15,bottom: 15,left:10,right:5),
                        child: Text(
                          widget.local!.description==null? 'wrong':widget.local!.description!,
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic
                          ),
                        )
                      ),
                      Container( // Google Map
                        height: 150,
                        child: GoogleMap(
                          onTap: (latlng){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Scaffold(
                              extendBodyBehindAppBar: true,
                              appBar: AppBar(
                                iconTheme: IconThemeData(
                                  color: Colors.black,
                                  size: 30
                                ),
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                              ),
                              body: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(localLatitude!,localLongitude!),
                                  zoom: 15
                                ),
                                myLocationEnabled: true,
                                // ignore: sdk_version_set_literal
                                markers: {
                                  Marker(
                                    markerId: MarkerId('0'),
                                    position: LatLng(localLatitude!,localLongitude!)
                                  ),
                                },
                              ),
                            )));
                          },
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(localLatitude!,localLongitude!),
                            zoom: 15
                          ),
                          myLocationEnabled: true,
                          markers: {
                            Marker(
                              markerId: MarkerId('0'),
                              position: LatLng(localLatitude!,localLongitude!)
                            )
                          },
                            //TODO: Add a 'Return to location' button
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(// Uber Button
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Mergi cu: "
                          ),
                          Container( 
                            width: 100,
                            height: 30,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Text(
                                'Uber',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1
                                ),
                              ),
                              color: Colors.black,
                              onPressed: () async{
                                AnalyticsService().analytics.logEvent(
                                  name: "check_uber",
                                );
                                LatLng pickup = LatLng(
                                  queryingService.userLocation!.latitude!, 
                                  queryingService.userLocation!.longitude!
                                );
                                LatLng dropoff = LatLng(
                                  widget.local!.location!.latitude, 
                                  widget.local!.location!.longitude
                                );
                                String deeplink = "https://m.uber.com/ul/?client_id=LNvSpVc4ZskDaV1rDZe8hGZy02dPfN84&action=setPickup&pickup[latitude]=" 
                                + pickup.latitude.toString()+
                                "&pickup[longitude]=" 
                                + pickup.longitude.toString() +
                                "&pickup[nickname]="
                                + "" +
                                "&pickup[formatted_address]="
                                + "" +
                                "&dropoff[latitude]="
                                + dropoff.latitude.toString() + 
                                "&dropoff[longitude]="
                                + dropoff.longitude.toString() +
                                "&dropoff[nickname]="
                                + widget.local!.name!.replaceAll(' ', '%20') +
                                "&dropoff[formatted_address]="
                                + "" +
                                "&product_id="
                                +"a1111c8c-c720-46c3-8534-2fcdd730040d"
                                ;
                                _launchInBrowser(
                                  context,
                                  deeplink,
                                  //"https://login.uber.com/oauth/v2/authorize?response_type=code&client_id=LNvSpVc4ZskDaV1rDZe8hGZy02dPfN84&scope=request%20profile%20history&redirect_uri=https://www.hyuga.ro/"
                                  // "https://m.uber.com/ul/
                                  // ?client_id=LNvSpVc4ZskDaV1rDZe8hGZy02dPfN84&
                                  // action=setPickup
                                  // &pickup[latitude]=37.775818
                                  // &pickup[longitude]=-122.418028
                                  // &pickup[nickname]=UberHQ
                                  // &pickup[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103
                                  // &dropoff[latitude]=37.802374
                                  // &dropoff[longitude]=-122.405818
                                  // &dropoff[nickname]=Coit%20Tower
                                  // &dropoff[formatted_address]=1%20Telegraph%20Hill%20Blvd%2C%20San%20Francisco%2C%20CA%2094133
                                  // &product_id=a1111c8c-c720-46c3-8534-2fcdd730040d",
                                  true
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Container( // First Image
                        padding: EdgeInsets.only(top:30),
                        child: FutureBuilder<Image?>(
                          future: _firstImage,
                          builder: (context, image){
                            if(!image.hasData){
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                );
                            }
                            else return image.data!;
                          }
                        ),
                      ),
                      SizedBox(height: 15,),
                      // The 'Second Image'      
                      Container(
                        padding: EdgeInsets.only(top:30),
                        child: FutureBuilder<Image?>(
                          future: _secondImage,
                          builder: (context, image){
                            if(!image.hasData){
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                );
                            }
                            else return image.data!;
                          }
                        ),
                      ), 
                      SizedBox(
                          height: 15,
                        ),
                      //widget.local.hasReservations != true 
                      //? Container() // An empty widget
                      //:
                      Column(
                        children : [
                        Container(
                          color: Colors.blueGrey.withOpacity(0.3),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              "Program:"
                            ),
                          )
                        ),
                        widget.local!.schedule != null
                        ? Container( // The 'Schedule'
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: weekdays.keys.map((String? key) => Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(weekdays[key]!.substring(0,2))
                                  ),
                                  Text(
                                    widget.local!.schedule![key!.toLowerCase()].substring(0,5),
                                  ),
                                  Text(
                                    widget.local!.schedule![key.toLowerCase()].substring(6,11),
                                  )
                                ],
                              ),
                            ).toList()
                          )
                        )
                        : Container(),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RaisedButton(
                                highlightElevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)
                                ),
                                color: Theme.of(context).accentColor,
                                child: Text(
                                  "Meniu",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                onPressed: (){
                                  _launchInBrowser(context, widget.local!.menu!);
                                }
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Text(
                                  widget.local!.hasOpenspace == true
                                  ? "Terasa: Da"
                                  : "Terasa: Nu"
                                ),
                              )
                            ],
                          )
                        ),
                        // RaisedButton(
                        //   //key: _reservationButtonKey,
                        //   color: Colors.orange[600],
                        //   highlightElevation: 3,
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(10)
                        //   ),
                        //   child: Text(
                        //     "Rezervă o masă",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.bold
                        //     ),
                        //   ),
                        //   onPressed: () => _openReservationDialog(context)
                        // ),
                        ]
                      ),
                      Container( // Third Image
                        padding: EdgeInsets.only(top:30),
                        child: FutureBuilder<Image?>(
                          future: _thirdImage,
                          builder: (context, image){
                            if(!image.hasData){
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                );
                            }
                            else return image.data!;
                          }
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                  ],
                )
              ]
            )
          ),
        );
    })
    );
  }
}
