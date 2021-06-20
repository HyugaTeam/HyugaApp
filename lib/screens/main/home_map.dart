import 'package:animations/animations.dart';
import 'package:hyuga_app/widgets/WineStreetLocalsList.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/main/SeatingInterface_Page.dart';
import 'package:hyuga_app/screens/main/home/DiscountLocals_Page.dart';
import 'package:hyuga_app/screens/main/home/SearchBar_Page.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:hyuga_app/screens/main/home/HomeMap.dart';

/// The Alternativ Home Page for the WineStreet App

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

  double titleOpacity = 0.0;
  Radius topLeftPanelCornerRadius = Radius.elliptical(210, 50);
  Radius topRightPanelCornerRadius = Radius.elliptical(210, 50);
  PanelController _panelController = PanelController();

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();

  @override
  void initState(){
    super.initState();
  }

  Widget buildSlidingPanel(ScrollController controller) =>
    Container(
      decoration: BoxDecoration(
        // color: whiteColor,
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.elliptical(210, 50),
        //   topRight: Radius.elliptical(210, 50)
        // )
        //  
      ),
      height: MediaQuery.of(context).size.height,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        controller: controller,
        children: [
          SizedBox(height: 10,),
          GestureDetector(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(10),
                height: 5,
                width: 30,
                decoration: BoxDecoration(
                  color: darkWhiteColor,
                  borderRadius: BorderRadius.circular(12)
                ),
              ),
            ),
            onTap: (){
              print("sdal");
              if(_panelController.isPanelOpen)
                _panelController.open();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 20),
            child: Text(
              "Reducerile de azi",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20
              ),
            ),
          ),
          WineStreetLocals(onlyWithDiscounts: true,)
        ],
      ),
    );

  Widget buildAppBar() => AppBar(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.elliptical(210, 50),
        bottomRight: Radius.elliptical(210, 50)
      )            
    ),
    backgroundColor: darkWhiteColor,
    elevation: 0,
    toolbarHeight: 70,
    centerTitle: true,
    title: Opacity(
      opacity: titleOpacity,
      child: Center(
        child: Text("Reducerile de azi"),
      ),
    ),
    leading: IconButton(
      padding: EdgeInsets.only(bottom: 20),
      icon: Icon(Icons.menu),
      iconSize: 20,
      color: Colors.white,
      highlightColor: Colors.white.withOpacity(0.2),
      splashColor: Colors.white.withOpacity(0.8),
      onPressed: () async {
        _drawerKey.currentState.openDrawer();
      },
    ),
    actions: <Widget>[
      IconButton(
        padding: EdgeInsets.only(bottom: 20),
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
              transitionDuration: Duration(milliseconds: 200),
              transitionsBuilder: (context,animation,secondAnimation,child){
                var _animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                return SlideTransition(
                  child: child,
                  position: Tween<Offset>(
                    begin: Offset(0,-1),
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
    return StreamBuilder(
      stream: authService.seatingStatus,
      builder: (context, ss) {
        if(!ss.hasData) // Checks if the user is seated or not
          return Scaffold(body: Center(child: SpinningLogo(),));
        else if(ss.data.docs.length == 1 )
          return SeatingInterface(place: ss.data.docs[0]);
        return Scaffold(
          extendBodyBehindAppBar: true,
          key: _drawerKey,
          appBar: buildAppBar(),
          //bottomNavigationBar: BottomAppBar(),
          body: Builder(
            builder: (context){
              //_controller.forward();
              return Container(
                child: SlidingUpPanel(
                  controller: _panelController,
                  color: whiteColor,
                  parallaxEnabled: true,
                  borderRadius: BorderRadius.only(
                    topLeft: topLeftPanelCornerRadius,
                    topRight: topRightPanelCornerRadius
                  ),
                  minHeight: MediaQuery.of(context).size.height*0.1,  
                  maxHeight: MediaQuery.of(context).size.height,
                  panelBuilder: (scrollController) { 
                    return buildSlidingPanel(scrollController);
                  },
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
              );
            },
          )
        );
      }
    );
  }
}