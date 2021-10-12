import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/main/home/DiscountLocals_Page.dart';
import 'package:hyuga_app/screens/main/SeatingInterface_Page.dart';
import 'package:hyuga_app/screens/main/home/QuestionsSearch.dart';
import 'package:hyuga_app/screens/main/home/SearchBar_Page.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/widgets/drawer.dart';
import 'package:rxdart/rxdart.dart';


class Home extends StatefulWidget {
  @override

  _HomeState createState() => _HomeState();
}

// method called upon initiating the searching process


class HomeButtonsController{
  
  static int lastValue;
  static PublishSubject _whereButton = PublishSubject<int>();
  
  HomeButtonsController(){
    _whereButton.listen((value) { 
      lastValue = value;
    });
  }
  /// The stream which emits a new value whenever the 'Where' field is reselected.
  /// It emits and 'int' corresponding to the selected index.
  static Stream<int> get whereButton => _whereButton.stream;

  /// Call this method whenever you want to notify the listeners about a 'Where' index modification
  static void addWhereValue(int value){
    _whereButton.add(value);
  }
}

class _HomeState extends State<Home> with TickerProviderStateMixin{

  HomeButtonsController buttonsController;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();
  ProfileDrawer _drawer = ProfileDrawer();

  Size _topWidgetSize;
  Size _bottomWidgetSize;

  Animation<double> _animation;
  AnimationController _controller;

  double _animatedButtonWidth = 70;



  @override
  void initState() {
    super.initState();
    _topWidgetSize = Size(500,0);
    _bottomWidgetSize = Size(500,0);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller, 
      curve: Curves.elasticInOut
    );
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: authService.seatingStatus,
      builder: (context, ss) {
      if(authService.currentUser.isAnonymous != true)
        if(!ss.hasData) // Checks if the user is seated or not
          return Scaffold(body: Center(child: SpinningLogo(),));
        else if(ss.data.docs.length == 1 )
          return SeatingInterface(place: ss.data.docs[0]);
        // return StreamBuilder<bool>(
        //   stream: QueryService.userLocationStream.stream,
        //   builder: (context, hasLocation) {
        //     bool prevData;
        //     QueryService.userLocationStream.stream.last.then((prevData) => prevData = prevData);
        //     if(!hasLocation.hasData && queryingService.userLocation == null)
        //       return Scaffold(
        //         body: Center(
        //           child: SpinningLogo(),
        //         )
        //       );
        //     else if(hasLocation.data == false || prevData == false) // Permission for location denied
        //       return Scaffold(body: Container(
        //         padding: EdgeInsets.only(left: 30),
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Image.asset(
        //               'assets/images/hyuga-logo.png',
        //               width:50
        //             ),
        //             SizedBox(height: 40,),
        //             RichText(
        //               textAlign: TextAlign.center,
        //               text: TextSpan(
        //                 children: [
        //                   TextSpan(
        //                     text: "Hyuga nu are acces la locatie :(\n"

        //                   ),
        //                   TextSpan(
        //                     text: "Va rugam sa permiteti accesul din setari."
        //                   )                          
        //                 ],
        //                 style: TextStyle(
        //                   fontFamily: 'Comfortaa',
        //                   fontSize: 16,
        //                   color: Colors.black,
        //                   fontWeight: FontWeight.bold
        //                 )
        //               ),
                      
        //             ),
        //           ],
        //         ),
        //       ));
         //else {
            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Theme.of(context).backgroundColor,
              key: _drawerKey,
              drawer: _drawer,
              // floatingActionButton: AnimatedContainer(
              //   // width: _animatedButtonWidth,
              //   duration: Duration(milliseconds: 300),
              //   child: GestureDetector(
              //     // onLongPress: (){
              //     //   setState(() {
              //     //     _animatedButtonWidth = 200;     
              //     //   });
              //     // },
              //     // onLongPressEnd: (detail){
              //     //   setState(() {
              //     //     _animatedButtonWidth = 70;     
              //     //   });
              //     // },
              //     child: FloatingActionButton(
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              //       child: Icon(
              //         Icons.camera_alt,
              //         size: 30,
              //       ),
              //       onPressed: (){
              //         Navigator.push(context, MaterialPageRoute(builder: (context)=> ScanReceipt()));
              //       },                
              //     ),
              //   ),
              // ),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 70,
                centerTitle: true,
                // title: IconButton(
                //   icon: Icon(
                //     Icons.camera_alt,
                //     size: 40,
                //   ),
                //   onPressed: (){},
                // ),
                leading: IconButton(
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
              ),
              body: Builder(
                builder: (context) {
                  _controller.forward();
                  return ScaleTransition(
                    scale: _animation,
                    child: Stack(// used a builder for the context
                    alignment: Alignment.center,
                    children: <Widget>[
                      Column( // The Two Options Widget
                        children: [
                          Expanded(
                            child: AnimatedSize(
                              vsync: this,
                              duration: Duration(milliseconds: 1000),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.bottomRight,
                                    transform: GradientRotation(2),
                                    colors: [
                                      Colors.blueGrey[600],
                                      Colors.blueGrey[700]
                                    ]
                                  )
                                ),
                                width: double.infinity,
                                height: _topWidgetSize.height,
                                child: MaterialButton(
                                  color: Colors.blueGrey.withOpacity(0.2),
                                  splashColor: Colors.black26,
                                  highlightColor: Colors.black12,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        child: Image(
                                          filterQuality: FilterQuality.high,
                                          image: AssetImage(
                                            'assets/images/stars.png',
                                          ),
                                          width: 50,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Text(
                                        "Gaseste localul perfect",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      print(_topWidgetSize.height);
                                    });
                                    AnalyticsService().analytics.logEvent(
                                      name: 'find_perfect_escape',
                                    );
                                    Navigator.push(
                                        context, 
                                        PageRouteBuilder(
                                          opaque: false,
                                          transitionDuration: Duration(milliseconds: 1500),
                                          transitionsBuilder: (context, Animation<double> animation, Animation<double> secondAnimation, Widget child){
                                            var _animation = CurvedAnimation(parent: animation, curve: Curves.elasticInOut, reverseCurve: Curves.elasticInOut);
                                            return SlideTransition(
                                              child: child,
                                              position: Tween<Offset>(
                                                begin: Offset(0,-1),
                                                end: Offset(0,0)
                                              ).animate(_animation)
                                            );
                                          },
                                          pageBuilder: (context, Animation<double> animation, Animation<double> secondAnimation){
                                            return QuestionsSearch();
                                          }
                                        )
                                      ).then(
                                        (value) =>g.resetSearchParameters()
                                      );
                                  }
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 10,
                          ),
                          Expanded(
                            child: AnimatedSize(
                              vsync: this,
                              duration: Duration(milliseconds: 1000),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.topLeft,
                                    transform: GradientRotation(2),
                                    colors: [
                                      Colors.orange[500],
                                      Colors.orange[800]
                                    ]
                                  )
                                ),
                                width: double.infinity,
                                height: _bottomWidgetSize.height,
                                child: MaterialButton(
                                  color: Colors.orange[600].withOpacity(0.6),
                                  splashColor: Colors.black26,
                                  highlightColor: Colors.black12,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.percentage,
                                        size: 42,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        "Reducerile de astazi",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          letterSpacing: -0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 30)
                                    ],
                                  ),
                                  onPressed: (){
                                      AnalyticsService().analytics.logEvent(
                                        name: 'highest_discounts',
                                      );
                                      Navigator.push(
                                        context, 
                                        PageRouteBuilder(
                                          opaque: false,
                                          transitionDuration: Duration(milliseconds: 1500),
                                          transitionsBuilder: (context, Animation<double> animation, Animation<double> secondAnimation, Widget child){
                                            var _animation = CurvedAnimation(parent: animation, curve: Curves.elasticInOut, reverseCurve: Curves.elasticInOut);
                                            return SlideTransition(
                                              child: child,
                                              position: Tween<Offset>(
                                                begin: Offset(0,1),
                                                end: Offset(0,0)
                                              ).animate(_animation)
                                            );
                                          },
                                          pageBuilder: (context, Animation<double> animation, Animation<double> secondAnimation){
                                            return DiscountLocalsPage();
                                          }
                                        )
                                      );
                                    //});
                                  }
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(///  'HYUGA' TITLE
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.02),
                        child: Text(
                          "hyuga",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 25.0,
                            color: Colors.white70
                          ),
                        )
                      ),
                    ]
                ),
                  );
                } 
              ),
            );
           // }
            
          }
        );
     }
    //);
  }
// }