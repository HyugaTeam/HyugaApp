import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hyuga_app/widgets/WineStreetLocalsList.dart';
import 'package:hyuga_app/widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/main/SeatingInterface_Page.dart';
import 'package:hyuga_app/screens/main/home/SearchBar_Page.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:hyuga_app/screens/main/home/HomeMap.dart';

/// The Alternative Home Page for the WineStreet App

class HomeMapPage extends StatefulWidget {
  @override
  _HomeMapPageState createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> with TickerProviderStateMixin{

  Color redColor = Color(0xFF600F2B);
  Color darkRedColor = Color(0xFF340808);
  // Color whiteColor = Color(0xFFd2f898); // greenish
  // Color darkWhiteColor = Color(0xFF82A44E);
  Color whiteColor = Color(0xFFF7E297); // orangeish
  Color darkWhiteColor = Color(0xFFCFBA70);
  Color roseColor = Color(0xFFb78a97);

  bool backButtonDismisses = false;
  double titleOpacity = 0.0;
  Radius topLeftPanelCornerRadius = Radius.elliptical(210, 50);
  Radius topRightPanelCornerRadius = Radius.elliptical(210, 50);

  PanelController _panelController = PanelController();
  ScrollController? _scrollController;
  GlobalKey _listKey = GlobalKey();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();
  ProfileDrawer _drawer = ProfileDrawer();
  
  void _initScrollController(ScrollController controller){
    // if(_scrollController != null)
    //   setState(() {
    //     controller.addListener((){

    //     });
    //   });
  }

  @override
  void initState(){
    super.initState();
    // var _db = FirebaseFirestore.instance;
    // var place1 = _db.collection("locals_bucharest").doc("bistro_1568");
    // place1.set(
    //   {
    //     "name": "CLUJ - Bistro 1568",
    //     "description": "",
    //     "ambiance": "sf",
    //     "capacity": 4,
    //     "cost": 2,
    //     "location": GeoPoint(46.7715644687848, 23.591659682336378),
    //     "menu": "https://maimutaplangatoare.ro/mancare/",
    //     "partner": true,
    //     "profile": {},
    //     "reservations": true,
    //     "schedule":{
    //       "monday": "11:00-23:00",
    //       "tuesday": "11:00-23:00",
    //       "wednesday": "11:00-23:00",
    //       "thursday": "11:00-00:00",
    //       "friday": "11:00-00:00",
    //       "saturday": "11:00-00:00",
    //       "sunday": "11:00-23:00"
    //     },
    //     "deals": {
    //         "monday": [
    //           {
    //             'title': "Vin Rosé (sticlă)",
    //             'content': 'Primești o sticlă de vin rosé Duzsi Tamas Kekfrankos la o consumație de minim 150 RON',
    //             'interval': "11:00-23:00",
    //             'threshold': "150 RON"
    //           },
    //           {
    //             'title': "Vin Alb (sticlă)",
    //             'content': 'Primești o sticlă de vin alb Frittmann Irsai Oliver la o consumație de minim 150 RON',
    //             'interval': "11:00-23:00",
    //             'threshold': "150 RON"
    //           },
    //         ],
    //         "tuesday": [
    //           {
    //             'title': "Vin Rosé (sticlă)",
    //             'content': 'Primești o sticlă de vin rosé Duzsi Tamas Kekfrankos la o consumație de minim 150 RON',
    //             'interval': "11:00-23:00",
    //             'threshold': "150 RON"
    //           },
    //           {
    //             'title': "Vin Alb (sticlă)",
    //             'content': 'Primești o sticlă de vin alb Frittmann Irsai Oliver la o consumație de minim 150 RON',
    //             'interval': "11:00-23:00",
    //             'threshold': "150 RON"
    //           },
    //         ],"wednesday": [
    //           {
    //             'title': "Vin Rosé (sticlă)",
    //             'content': 'Primești o sticlă de vin rosé Duzsi Tamas Kekfrankos la o consumație de minim 150 RON',
    //             'interval': "11:00-23:00",
    //             'threshold': "150 RON"
    //           },
    //           {
    //             'title': "Vin Alb (sticlă)",
    //             'content': 'Primești o sticlă de vin alb Frittmann Irsai Oliver la o consumație de minim 150 RON',
    //             'interval': "11:00-23:00",
    //             'threshold': "150 RON"
    //           },
    //         ],"thursday": [
    //           {
    //             'title': "Vin Rosé (sticlă)",
    //             'content': 'Primești o sticlă de vin rosé Duzsi Tamas Kekfrankos la o consumație de minim 150 RON',
    //             'interval': "11:00-00:00",
    //             'threshold': "150 RON"
    //           },
    //           {
    //             'title': "Vin Alb (sticlă)",
    //             'content': 'Primești o sticlă de vin alb Frittmann Irsai Oliver la o consumație de minim 150 RON',
    //             'interval': "11:00-00:00",
    //             'threshold': "150 RON"
    //           },
    //         ],"friday": [
    //           {
    //             'title': "Vin Rosé (sticlă)",
    //             'content': 'Primești o sticlă de vin rosé Duzsi Tamas Kekfrankos la o consumație de minim 150 RON',
    //             'interval': "11:00-00:00",
    //             'threshold': "150 RON"
    //           },
    //           {
    //             'title': "Vin Alb (sticlă)",
    //             'content': 'Primești o sticlă de vin alb Frittmann Irsai Oliver la o consumație de minim 150 RON',
    //             'interval': "11:00-00:00",
    //             'threshold': "150 RON"
    //           },
    //         ],"saturday": [
    //           {
    //             'title': "Vin Rosé (sticlă)",
    //             'content': 'Primești o sticlă de vin rosé Duzsi Tamas Kekfrankos la o consumație de minim 150 RON',
    //             'interval': "11:00-00:00",
    //             'threshold': "150 RON"
    //           },
    //           {
    //             'title': "Vin Alb (sticlă)",
    //             'content': 'Primești o sticlă de vin alb Frittmann Irsai Oliver la o consumație de minim 150 RON',
    //             'interval': "11:00-00:00",
    //             'threshold': "150 RON"
    //           },
    //         ],"sunday": [
    //           {
    //             'title': "Vin Rosé (sticlă)",
    //             'content': 'Primești o sticlă de vin rosé Duzsi Tamas Kekfrankos la o consumație de minim 150 RON',
    //             'interval': "11:00-00:00",
    //             'threshold': "150 RON"
    //           },
    //           {
    //             'title': "Vin Alb (sticlă)",
    //             'content': 'Primești o sticlă de vin alb Frittmann Irsai Oliver la o consumație de minim 150 RON',
    //             'interval': "11:00-00:00",
    //             'threshold': "150 RON"
    //           },
    //         ],
    //       }
    //   },
    //   SetOptions(merge: true)
    // );
  }

  Widget buildSlidingPanel(ScrollController controller) {
    _initScrollController(controller);
    return Container(
      decoration: BoxDecoration(
        // color: whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: topLeftPanelCornerRadius,
          topRight: topRightPanelCornerRadius
        )
         
      ),
      child: ListView(
        key: _listKey,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        controller: controller,
        children: [
          SizedBox(height: 10,),
          GestureDetector( /// The slide-up button
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    height: 5,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFF70545c),
                      borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    height: 5,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                ],
              ),
            ),
            onTap: (){ // Doesn't work for some reason
              //print("sdal");
              if(!_panelController.isPanelClosed)
                _panelController.open();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 25),
            child: Text(
              "Rezervă o masă",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white
              ),
            ),
          ),
          WineStreetLocals(onlyWithDiscounts: true,)
        ],
      ),
    );
  }
  Widget buildAppBar() => AppBar(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.elliptical(210, 50),
        bottomRight: Radius.elliptical(210, 50)
      )            
    ),
    backgroundColor: Theme.of(context).primaryColor,
    elevation: 2,
    toolbarHeight: 70,
    centerTitle: true,
    title: Opacity(
      opacity: titleOpacity,
      child: Center(
        child: Text("Rezervă o masă"),
      ),
    ),
    leading: IconButton(
      padding: EdgeInsets.only(bottom: 20, left: 30),
      icon: Icon(Icons.menu),
      iconSize: 20,
      color: Colors.white,
      highlightColor: Colors.white.withOpacity(0.2),
      splashColor: Colors.white.withOpacity(0.8),
      onPressed: () async {
        _drawerKey.currentState!.openDrawer();
      },
    ),
    actions: <Widget>[
      IconButton(
        padding: EdgeInsets.only(bottom: 20, right: 30),
        splashColor: Colors.white.withOpacity(0.8),
        highlightColor: Colors.white.withOpacity(0.2),
        icon: FaIcon(FontAwesomeIcons.search, size: 18),
        color: Colors.white,
        onPressed: (){
          Navigator.push(
            context, 
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black.withOpacity(0.3),
              transitionDuration: Duration(milliseconds: 400),
              transitionsBuilder: (context,animation,secondAnimation,child){
                var _animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                return SlideTransition(
                  child: child,
                  //child: ClipPath(child: child, clipper: _clipper,),
                  position: Tween<Offset>(
                    begin: Offset(1,-1),
                    end: Offset(0,0)
                  ).animate(_animation),
                );
              },
              pageBuilder: (context,animation,secondAnimation){
                return SearchBarPage();
              }
            )
          );
        },
      )
    ],    ///Un-comment in case we want to add further Widgets on the appBar
  );

  @override
  Widget build(BuildContext context) {
    return StreamProvider<QuerySnapshot<Object?>?>.value(
      initialData: null,
      value: authService.seatingData,
      //updateShouldNotify: (oldData, newData) => (oldData != null && newData != null) && (oldData.docs != newData.docs),
      builder: (context, child) {
      var seatingData = Provider.of<QuerySnapshot<Object?>?>(context);
      if(authService.currentUser!.isAnonymous != true)
        if(seatingData == null) // Checks if the user is seated or not
          return Scaffold(body: Center(child: SpinningLogo(),));
        else if(seatingData.docs.length == 1 )
          return SeatingInterface(place: seatingData.docs[0]);
        return Scaffold(
          extendBodyBehindAppBar: true,
          key: _drawerKey,
          drawer: _drawer,
          appBar: buildAppBar() as PreferredSizeWidget?,
          //bottomNavigationBar: BottomAppBar(),
          body: Builder(
            builder: (context){
              //_controller.forward();
              return Container(
                child: WillPopScope(
                  onWillPop: (){
                    if(backButtonDismisses){
                      _panelController.close();
                      if(_scrollController != null)
                        _scrollController!.animateTo(
                          0,
                          duration: Duration(milliseconds: 0),
                          curve: Curves.linear 
                        );
                      return  Future(() => false);  
                    }
                    return Future(() => true);
                  },
                  child: SlidingUpPanel(
                    controller: _panelController,
                    color: Theme.of(context).primaryColor,
                    parallaxEnabled: true,
                    // onPanelOpened: (){
                    //   setState(() {
                    //     backButtonDismisses = true;                  
                    //   });
                    // },
                    // onPanelClosed: (){
                    //   setState(() {
                    //     backButtonDismisses = false;                  
                    //   });
                    // },
                    borderRadius: BorderRadius.only(
                      topLeft: topLeftPanelCornerRadius,
                      topRight: topRightPanelCornerRadius
                    ),
                    minHeight: MediaQuery.of(context).size.height*0.1,  
                    maxHeight: MediaQuery.of(context).size.height,
                    //panel: buildSlidingPanel(_scrollController),
                    panelBuilder: (scrollController) => buildSlidingPanel(scrollController),
                    onPanelSlide: (offset) =>
                      setState(() {
                        topLeftPanelCornerRadius = Radius.elliptical(
                          (1-offset)*210, 50
                        );
                        topRightPanelCornerRadius = Radius.elliptical(
                          (1-offset)*210, 50  
                        );
                        if(offset < 1)
                          if(offset < 0.875)
                            titleOpacity = 0;
                          else titleOpacity = 1-(1-offset)*8;
                        else titleOpacity = 1;
                      }),
                    body: HomeMap(),
                  ),
                ),
              );
            },
          )
        );
      }
    );
  }
}

