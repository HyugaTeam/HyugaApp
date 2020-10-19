import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_card/expansion_card.dart';
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
import 'package:shimmer/shimmer.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/services/uber_service.dart' ;
import 'package:url_launcher/url_launcher.dart';


// The generator of the third page
class ThirdPageGenerator{

  //Function which generates the ThirdPage
  static Route<dynamic> generateRoute(RouteSettings settings){
    List<dynamic> args = settings.arguments;
    Local local = args[0];  // This is the first argument(The 'Local')
    bool onlyDiscounts = args[1]; // This is the second argument(whether it shows only discounts or not)
    // return PageRouteBuilder(
    //   opaque: false,
    //   //barrierColor: Colors.white.withOpacity(0.1),
    //   transitionDuration: Duration(milliseconds: 200),
    //   transitionsBuilder: (context,animation,secondAnimation,child){
    //     var _animation = CurvedAnimation(parent: animation, curve: Curves.bounceIn);
    //     return ScaleTransition(
    //       child: child,
    //       scale: Tween<double>(
    //         begin: 0,
    //         end: 1
    //       ).animate(_animation),
    //     );
    //   },
    //   pageBuilder: (context,animation,secondAnimation){
    //     return ThirdPage(
    //       local: local,
    //       onlyDiscounts: onlyDiscounts
    //     );
    //   }
    // );
    return MaterialPageRoute(
      builder: (_) => ThirdPage(
        local: local,
        onlyDiscounts: onlyDiscounts
      )
    );
  }
}



class ThirdPage extends StatefulWidget {

  final Local local;
  final bool onlyDiscounts;
  //final Future<Image> size;
  
  ThirdPage({this.local,this.onlyDiscounts}){
    
    ///Added for test
    if(this.onlyDiscounts == null){
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": local.id,
          "place_name": local.name,
          "place_path": "${g.whereListTranslation[g.selectedWhere]}_${g.whatListTranslation[g.selectedWhere][g.selectedWhat]}_${g.howManyListTranslation[g.selectedHowMany]}_${g.ambianceListTranslation[g.selectedAmbiance]}_${g.areaListTranslation[g.selectedArea]}"
        }
      ).then((value) => print(local.id+local.name));
    }
    else{
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": local.id,
          "place_name": local.name,
          "place_path": "only_discounts"
        }
      );
    }

    // if(this.onlyDiscounts == null) /// This path is followed if the user visits the Place from the Second Page
    //   AnalyticsService().analytics.logViewItem(
    //     itemId: local.id, 
    //     itemName: local.name,
    //     itemCategory: "${g.whereList[g.selectedWhere]}_${g.whatList[g.selectedWhere][g.selectedWhat]}_${g.howManyList[g.selectedHowMany]}_${g.ambianceList[g.selectedAmbiance]}_${g.areaList[g.selectedArea]}",
    //   );
    // else AnalyticsService().analytics.logViewItem( /// ----""----- from the 'Only Discounts' Page
    //   itemId: local.id, 
    //   itemName: local.name,
    //   itemCategory: "only_discounts",
    // );
  }

  @override
  _ThirdPageState createState() => _ThirdPageState(
    localLongitude: local.location.longitude,
    localLatitude: local.location.latitude
  );
}

class _ThirdPageState extends State<ThirdPage> with TickerProviderStateMixin{

  Map<String,String> weekdays = {"Monday" : "Luni", "Tuesday" : "Marti","Wednesday" : "Miercuri","Thursday" : "Joi","Friday" : "Vineri","Saturday" : "Sambata", "Sunday" : "Duminica"};
  Future<Image> _firstImage;
  Future <Image> _secondImage;
  Future <Image> _thirdImage;
  DateTime today;
  
  int _selectedWeekday = 0;
  double titleOpacity = 0.0;

  AnimationController _animationController;
  Animation<double> _animation;

  ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
    initialScrollOffset: 0
  );
  double dealWidgetHeight = 80;
  List<bool> isOfferExpanded;
  final double localLongitude,localLatitude;
  List<Uint8List> listOfImages;

  _ThirdPageState({this.localLongitude,this.localLatitude}){
    today = DateTime.now().toLocal();
    _selectedWeekday = today.weekday;
    print(_selectedWeekday);
  }

  //Deprecated
  //Queries for the other images
  Future<List<Uint8List>> _getImages() async{

      Uint8List imageFile;
      int maxSize = 6*1024*1024;
      String fileName = widget.local.id;
      String pathName = 'photos/europe/bucharest/$fileName';
      

      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      List<Uint8List> listOfImages = [];
      //int pictureIndex = 1;
      try{
        
        //do{
          //print('///////////////////'+'$fileName'+'_$pictureIndex.jpg');
          //await storageRef.child('$fileName'+'_$pictureIndex.jpg')
          await storageRef.child('$fileName'+'_1.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
          listOfImages.add(imageFile);
          //pictureIndex++;
        //}while(pictureIndex<2);

        await storageRef.child('$fileName'+'_m.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
          listOfImages.add(imageFile);
        return listOfImages;
      }
      catch(error){
      //print('///////////////////////////////$error');
        return null;
      }
  }

  Future<Image> _getFirstImage() async{
    Uint8List imageFile;
    int maxSize = 6*1024*1024;
    String fileName = widget.local.id;
    String pathName = 'photos/europe/bucharest/$fileName';
    var storageRef = FirebaseStorage.instance.ref().child(pathName);
    try{
      await storageRef.child('$fileName'+'_1.jpg')
        .getData(maxSize).then((data){
          imageFile = data;
          }
        );
      return Image.memory(
        imageFile,
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
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

  Future<Image> _getSecondImage() async{
    Uint8List imageFile;
      int maxSize = 6*1024*1024;
      String fileName = widget.local.id;
      String pathName = 'photos/europe/bucharest/$fileName';
      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      try{
        await storageRef.child('$fileName'+'_2.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
        return Image.memory(
          imageFile,
          frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
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

  Future<Image> _getThirdImage() async{
    Uint8List imageFile;
      int maxSize = 6*1024*1024;
      String fileName = widget.local.id;
      String pathName = 'photos/europe/bucharest/$fileName';
      var storageRef = FirebaseStorage.instance.ref().child(pathName);
      try{
        await storageRef.child('$fileName'+'_m.jpg')
          .getData(maxSize).then((data){
            imageFile = data;
            }
          );
        return Image.memory(
          imageFile,
          frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
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

  Future<void> _launchInBrowser(String url, [bool universalLinks = false]) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: universalLinks,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }
  
  /// Deprecated
  double getDiscountForUser(double maxDiscount){
    List<num> userDiscounts = g.discounts.firstWhere((element) => element['maxim'] == maxDiscount)['per_level'];
    return userDiscounts[authService.currentUser.getLevel()].toDouble();
  }


  // Configures how the title is progressively shown as the user's scrolling the page downwards
  @override
  void initState(){
    //print(widget.local.reference.toString());
    if(widget.local.deals != null)
      if(widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null)
        isOfferExpanded = widget.local
          .deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProfileDrawer(),
      extendBodyBehindAppBar: true,
      body: Builder(
        builder: (context) { 
          _animationController.forward();
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  // stretchTriggerOffset: 30,
                  // onStretchTrigger: (){
                  //     return Future.delayed(Duration(seconds: 1)).then((s)=>print("stretch-triggered"));
                  // },
                  // stretch: true,
                  title: Opacity(
                      opacity: titleOpacity,
                      child: Center(
                        child: Text(widget.local.name),
                      ),
                  ),
                  expandedHeight: 220,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: widget.local.name,
                      child: FutureBuilder(
                        future: widget.local.image,
                        builder: (context,imgSnapshot){
                          if(widget.local.finalImage == null)
                          //if(!imgSnapshot.hasData)
                            return Container(
                              width: 400,
                              height: 200,
                              color: Colors.white,
                            );
                          else 
                            return Container(
                              color: Colors.white,
                              child: imgSnapshot.data
                            );
                        }
                      ),
                    ),
                  ),
                  backgroundColor: Colors.blueGrey,
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
                // controller: ScrollController(
                //   keepScrollOffset: false
                // ),
                physics: ScrollPhysics(),
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
                              widget.local.name==null? 'wrong':widget.local.name,
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
                                itemCount: widget.local.cost,
                                itemBuilder: (context, costIndex){
                                  return FaIcon(FontAwesomeIcons.dollarSign, color: Colors.orange[600],);
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
                            colors: [Colors.white,Colors.orange[600],Colors.white]
                          )
                        ),
                      ),
                      Container( // 'Description '
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
                          widget.local.description==null? 'wrong':widget.local.description,
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
                                  target: LatLng(localLatitude,localLongitude),
                                  zoom: 15
                                ),
                                myLocationEnabled: true,
                                //trafficEnabled: true,
                                markers: {
                                  Marker(
                                    markerId: MarkerId('0'),
                                    position: LatLng(localLatitude,localLongitude)
                                  ),
                                },
                              ),
                            )));
                          },
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(localLatitude,localLongitude),
                            zoom: 15
                          ),
                          myLocationEnabled: true,
                          //trafficEnabled: true,
                          markers: {
                            Marker(
                              markerId: MarkerId('0'),
                              position: LatLng(localLatitude,localLongitude)
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
                            // decoration: BoxDecoration(
                            //   color: Colors.black,
                            //   //borderRadius: BorderRadius.circular(20)
                            // ),
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
                                LatLng pickup = LatLng(
                                  queryingService.userLocation.latitude, 
                                  queryingService.userLocation.longitude
                                );
                                LatLng dropoff = LatLng(
                                  widget.local.location.latitude, 
                                  widget.local.location.longitude
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
                                + widget.local.name.replaceAll(' ', '%20') +
                                "&dropoff[formatted_address]="
                                + "" +
                                "&product_id="
                                +"a1111c8c-c720-46c3-8534-2fcdd730040d"
                                ;
                                _launchInBrowser(
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
                                //await UberService().getRide();
                              },
                            ),
                          ),
                        ],
                      ),
                      Container( // First Image
                        padding: EdgeInsets.only(top:30),
                        child: FutureBuilder(
                          future: _firstImage,
                          builder: (context, image){
                            if(!image.hasData){
                              return Shimmer.fromColors(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                ), 
                                baseColor: Colors.white, 
                                highlightColor: Colors.orange[600]
                              );
                            }
                            else return image.data;
                          }
                        ),
                      ),
                      SizedBox(height: 15,),
                      DropdownButton( /// 'Select the Day' widget
                        value: weekdays.keys.toList()[_selectedWeekday-1],
                        items: weekdays.keys
                        .map((String weekday) {
                          return DropdownMenuItem(
                            value: weekday,
                            child: Text(
                              weekday != DateFormat("EEEE").format(today)
                              ? weekdays[weekday] 
                              : "Astazi - "+  weekdays[weekday] 
                            ),
                          );
                        }).toList(),
                        onChanged: (value){
                          setState((){
                            //print(weekdays.keys.toList().indexOf(value));
                            _selectedWeekday = weekdays.keys.toList().indexOf(value)+1;
                            if(widget.local.deals != null)
                              if(widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null)
                                isOfferExpanded = widget.local
                                  .deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                                  .map<bool>((key) => false).toList();
                          });
                        }
                      ),
                      // The 'Deals' Widget
                      widget.local.deals != null && widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null
                      ? Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("Oferte", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                SizedBox(
                                  width: 150
                                )
                              ],
                            ),
                            SizedBox(height: 10,),
                            AnimatedContainer(
                              //key: UniqueKey(),
                              duration: Duration(milliseconds: 200),
                              height: dealWidgetHeight,
                              child: ListView.separated(
                                padding: EdgeInsets.all(10),
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.local.deals != null ?  
                                            (widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null? 
                                              widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()].length : 0): 
                                            0,
                                separatorBuilder: (BuildContext context, int index) => SizedBox(width: 10,),
                                itemBuilder: (context,index) {
                                  ValueKey key = ValueKey(index);
                                  return Container(
                                    height: 120,
                                    width: 180,
                                    //width: MediaQuery.of(context).size.width*0.3,
                                    constraints: BoxConstraints(maxHeight: 100),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        // BoxShadow(
                                        //   offset: Offset(0,0)
                                        // )
                                      ]
                                      //color: Colors.orange[600],
                                    ),
                                    child: 
                                    //Container()
                                    ExpansionCard(
                                      key: key,
                                      borderRadius: 20,
                                      backgroundColor: Colors.orange[600],
                                      margin: EdgeInsets.zero,
                                      // background: Container(
                                      //   height: double.infinity,
                                      //   width: double.infinity,
                                      //   color: Colors.orange[600],
                                      // ),
                                      title: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index]['title'],
                                            style: TextStyle(color: Colors.black,fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          Divider(
                                            thickness: 2
                                          ),
                                          Text(widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                                            [index]['interval'].substring(0,5) 
                                            +  ' - ' + 
                                            widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                                            [index]['interval'].substring(6,11),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black
                                            ),
                                          )  // 
                                        ],
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index]['content'],
                                            style: TextStyle(
                                              //fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        )
                                      ],
                                      onExpansionChanged: (expanded) => setState((){
                                        isOfferExpanded[index] = expanded;
                                        print(isOfferExpanded);
                                        bool allClosed = true;
                                        isOfferExpanded.forEach((element) {if(element) allClosed = false;});
                                        if(allClosed)
                                          dealWidgetHeight = 80;
                                        else dealWidgetHeight = 180;
                                        }
                                      ),
                                    // ),
                                      ),
                                  // Container(
                                  //   //height: 30,
                                  //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                  //   constraints: BoxConstraints(
                                  //     maxWidth: MediaQuery.of(context).size.width*0.4
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.orange[600],
                                  //     borderRadius: BorderRadius.circular(10)
                                  //   ),
                                  //   child: Center(
                                  //     child: Column(
                                  //       crossAxisAlignment: CrossAxisAlignment.start,
                                  //       mainAxisAlignment: MainAxisAlignment.center,
                                  //       children: [
                                  //         Text(
                                  //           widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index]['title'],
                                  //           style: TextStyle(
                                  //             fontSize: 15,
                                  //             color: Colors.white,
                                  //             fontWeight: FontWeight.bold
                                  //           )
                                  //         ),
                                  //         // Text(
                                  //         //   widget.local.deals[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index]['content'],
                                  //         //   style: TextStyle(
                                  //         //       fontSize: 12
                                  //         //   )
                                  //         // ),
                                  //       ],
                                  //     )
                                  //   ),
                                  // ),
                              );}
                              )
                            ),
                          ],
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Center(child: Text(
                          "Localul nu are ${weekdays[weekdays.keys.toList()[_selectedWeekday-1]].toLowerCase()} oferte.", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                        ),
                      ),
                      Divider(
                        thickness: 3,
                      ),           
                      // The 'Discounts' Widget
                      widget.local.discounts != null && widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null
                        ? Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Reduceri", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.2,)
                                ],
                              ),
                              Container(
                                height: 100,
                                child: ListView.separated(
                                  //shrinkWrap: true,
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.local.discounts != null ?  
                                              (widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()] != null? 
                                                widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()].length : 0): 
                                              0,
                                  separatorBuilder: (BuildContext context, int index) => SizedBox(width: 10,),
                                  /// ^^^ This comparison checks if in the 'discounts' Map field imported from Firebase exist any discounts related to 
                                  /// the current weekday. If not, the field will be empty
                                  itemBuilder: (BuildContext context, int index){
                                    return Container(
                                      width: MediaQuery.of(context).size.width*0.35,
                                      height: 100,
                                      child: Column(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: (){
                                              if(g.isSnackBarActive == false){
                                                g.isSnackBarActive = true;
                                                Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Vino in local si scaneaza codul sau fa o rezervare in intervalul dorit pentru a primi reducerea.",
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    backgroundColor: Colors.orange[600],
                                                  )).closed.then((SnackBarClosedReason reason){
                                                  g.isSnackBarActive = false;
                                                });
                                              }
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black45, 
                                                    offset: Offset(-1,1),
                                                    blurRadius: 2,
                                                    spreadRadius: 0.2
                                                  )
                                                ],
                                                color: Colors.orange[600],
                                                borderRadius: BorderRadius.circular(25)
                                              ),
                                              child: Text(widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                                                      [index].substring(0,5) 
                                                      +  ' - ' + 
                                                      widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()]
                                                      [index].substring(6,11),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        //fontFamily: 'Roboto'
                                                      ),
                                                    )  // A concatenation of the string representing the time interval
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              '-'+int.parse(widget.local.discounts[weekdays.keys.toList()[_selectedWeekday-1].toLowerCase()][index].substring(12,14))
                                              .toString() + '%',
                                              /// Old computation for the Discount per level
                                              //getDiscountForUser(double.parse(widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()][index].substring(12,14)))
                                              style: TextStyle(
                                                fontSize: 20,
                                                //fontFamily: 'Roboto'
                                              )
                                              )
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                ),
                              ),
                              
                            ],
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0),
                          child: Center(
                            child: Text(
                              "Localul nu are ${weekdays[weekdays.keys.toList()[_selectedWeekday-1]].toLowerCase()} reduceri.", 
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ),
                        ),
                      // The 'Second Image'      
                      Container(
                        padding: EdgeInsets.only(top:30),
                        child: FutureBuilder(
                          future: _secondImage,
                          builder: (context, image){
                            if(!image.hasData){
                              return Shimmer.fromColors(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                ), 
                                baseColor: Colors.white, 
                                highlightColor: Colors.orange[600]
                              );
                            }
                            else return image.data;
                          }
                        ),
                      ), 
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        color: Colors.blueGrey.withOpacity(0.3),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            "Program:"
                          ),
                        )
                      ),
                      widget.local.schedule != null
                      ? Container( // The 'Schedule'
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: weekdays.keys.map((String key) => Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(weekdays[key].substring(0,2))
                                ),
                                Text(
                                  widget.local.schedule[key.toLowerCase()].substring(0,5),
                                ),
                                Text(
                                  widget.local.schedule[key.toLowerCase()].substring(6,11),
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
                              color:Colors.blueGrey,
                              child: Text(
                                "Meniu",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              onPressed: (){
                                _launchInBrowser(widget.local.menu);
                              }
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width*0.3,
                              child: Text(
                                widget.local.hasOpenspace == true
                                ? "Terasa: Da"
                                : "Terasa: Nu"
                              ),
                            )
                          ],
                        )
                      ),
                      RaisedButton(
                        color: Colors.orange[600],
                        highlightElevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(
                          "Rezerva o masa",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        onPressed: () async{
                        if(!authService.currentUser.isAnonymous){
                        if(widget.local.hasReservations == true){
                          await FirebaseFirestore.instance.collection('users').doc(authService.currentUser.uid)
                          .collection('reservations_history')
                          .where('date_start', isGreaterThan: Timestamp.fromDate(DateTime.now().toLocal())).get().then((value){
                            print(value.docs.length);
                            bool ok = true;
                            /// Checks if there are any upcoming unclaimed reservations
                            value.docs.forEach((element) { 
                              if(element.data()['accepted'] == null || (element.data()['accepted'] == true && element.data()['claimed'] == null))
                                ok = false;
                              //print(element.data());
                            });
                            if(!ok){
                                if(g.isSnackBarActive == true)
                                  Scaffold.of(context).removeCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: MaterialButton(
                                      onPressed: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ReservationsHistoryPage()));
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Ai deja o rezervare."),
                                        //   TextButton(
                                        //     child: Text(
                                        //       "Verifica aici"
                                        //     ),
                                        //     onPressed: (){
                                        //       Scaffold.of(context).removeCurrentSnackBar();
                                        //       Navigator.of(context).push(MaterialPageRoute(builder: (context){ return ReservationsHistoryPage(); }));
                                        //     },
                                        //   )
                                       ],
                                      ),
                                    ),
                                  )
                                );
                              }
                            else if(widget.local.hasReservations == true){
                              //print("nu are rezervari");
                              showDialog(context: context, builder: (newContext) => Provider(
                                create: (context) => widget.local, 
                                child: ReservationPanel(context:newContext))
                              ).then((reservation) => reservation != null 
                                ? Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Se asteapta confirmare pentru rezervarea facuta la ${reservation['place_name']} pentru ora ${reservation['hour']}")
                                  )
                                )
                                : null
                              ); 
                            }
                          });
                          }
                        else Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Localul nu accepta rezervari")
                            )
                          );
                        }
                      else if(authService.currentUser.isAnonymous == true)
                        Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Trebuie sa te loghezi pentru a face rezervari."),
                              action: SnackBarAction(
                                label: "Log In", 
                                onPressed: () async{
                                  await authService.signOut();
                                }
                              ),
                            ),
                          );
                      }
                      
                      ),
                      Container( // Third Image
                        padding: EdgeInsets.only(top:30),
                        child: FutureBuilder(
                          future: _thirdImage,
                          builder: (context, image){
                            if(!image.hasData){
                              return Shimmer.fromColors(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                ), 
                                baseColor: Colors.white, 
                                highlightColor: Colors.orange[600]
                              );
                            }
                            else return image.data;
                          }
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.only(top:30),
                      //   child: FutureBuilder(
                      //     future: _getImages(),
                      //     builder:(context,snapshot){
                      //       if(!snapshot.hasData){
                      //         // data didn't load
                      //         return Shimmer.fromColors(
                      //           period: Duration(milliseconds: 1500),
                      //           baseColor: Colors.grey[300],
                      //           highlightColor: Colors.white,
                      //           child: Container(
                      //             height: 200,
                      //             color: Colors.blueGrey,
                      //           ),
                      //         ); 
                      //       }
                      //       else {
                      //         // data is loaded
                      //         return ListView.separated(
                      //           physics: NeverScrollableScrollPhysics(),
                      //           shrinkWrap: true,
                      //           itemCount: snapshot.data.length,
                      //           separatorBuilder: (context,index){
                      //             if(index == 0){ // Shows the discounts carrousel
                      //               return widget.local.discounts != null && widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()] != null
                      //               ? ListTile(
                      //                 title: Text("Discounts", style: TextStyle(fontWeight: FontWeight.bold),),
                      //                 subtitle: Container(
                      //                   height: 120,
                      //                   child: ListView.builder(
                      //                     itemExtent: 135, /// Added to add some space between the tiles
                      //                     padding: EdgeInsets.all(10),
                      //                     scrollDirection: Axis.horizontal,
                      //                     itemCount: widget.local.discounts != null ?  
                      //                                 (widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()] != null? 
                      //                                   widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()].length : 0): 
                      //                                 0,
                      //                     /// ^^^ This comparison checks if in the 'discounts' Map field imported from Firebase exist any discounts related to 
                      //                     /// the current weekday. If not, the field will be empty
                      //                     itemBuilder: (BuildContext context, int index){
                      //                       return Container(
                      //                         width: 100,
                      //                         height: 100,
                      //                         child: Column(
                      //                           children: <Widget>[
                      //                             GestureDetector(
                      //                               onTap: (){
                      //                                 if(g.isSnackBarActive == false){
                      //                                   g.isSnackBarActive = true;
                      //                                   Scaffold.of(context).showSnackBar(
                      //                                     SnackBar(
                      //                                       content: Text(
                      //                                         "Scan your code in your preferred time interval and receive the discount.",
                      //                                         textAlign: TextAlign.center,
                      //                                       ),
                      //                                       backgroundColor: Colors.orange[600],
                      //                                     )).closed.then((SnackBarClosedReason reason){
                      //                                     g.isSnackBarActive = false;
                      //                                   });
                      //                                 }
                      //                               },
                      //                               child: Container(
                      //                                 alignment: Alignment.center,
                      //                                 height: 30,
                      //                                 width: 120,
                      //                                 decoration: BoxDecoration(
                      //                                   boxShadow: [
                      //                                     BoxShadow(
                      //                                       color: Colors.black45, 
                      //                                       offset: Offset(1.5,1),
                      //                                       blurRadius: 2,
                      //                                       spreadRadius: 0.2
                      //                                     )
                      //                                   ],
                      //                                   color: Colors.orange[600],
                      //                                   borderRadius: BorderRadius.circular(25)
                      //                                 ),
                      //                                 child: Text(widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()]
                      //                                         [index].substring(0,5) 
                      //                                         + ' - ' + 
                      //                                         widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()]
                      //                                         [index].substring(6,11),
                      //                                         style: TextStyle(
                      //                                           fontSize: 16,
                      //                                           fontFamily: 'Roboto'
                      //                                         ),
                      //                                       )  // A concatenation of the string representing the time interval
                      //                               ),
                      //                             ),
                      //                             Padding(
                      //                               padding: EdgeInsets.all(10),
                      //                               child: Text(
                                                      
                      //                                 getDiscountForUser(double.parse(widget.local.discounts[DateFormat('EEEE').format(today).toLowerCase()][index].substring(12,14)))
                      //                                 .toString() + '%',
                      //                                 style: TextStyle(
                      //                                   fontSize: 20,
                      //                                   fontFamily: 'Roboto'
                      //                                 )
                      //                                 )
                      //                             )
                      //                           ],
                      //                         ),
                      //                       );
                      //                     }
                      //                   ),
                      //                 )
                      //               )
                      //               : Padding(
                      //                 padding: const EdgeInsets.symmetric(vertical: 30.0),
                      //                 child: Center(child: Text("Localul nu are astazi reduceri.")),
                      //               );
                      //             }
                      //             else return Container();
                      //           },
                      //           // controller: ScrollController(
                      //           //   keepScrollOffset: false
                      //           // ),
                      //           itemBuilder: (context,index){
                      //             //print(snapshot.data.length);
                      //             return Column(
                      //               children: <Widget>[
                      //                 Image.memory(snapshot.data[index]),
                      //                 index == snapshot.data.length-1 ? Container() : Container(height: 20)
                      //               ],
                      //             );
                                  
                      //           },
                      //         );
                      //       }
                      //     }
                      //   )
                      // )
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
