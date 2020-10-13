import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/main/home/DiscountLocals_Page.dart';
import 'package:hyuga_app/screens/main/SeatingInterface_Page.dart';
import 'package:hyuga_app/screens/main/home/QuestionsSearch.dart';
import 'package:hyuga_app/screens/main/home/SearchBar_Page.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/MainMenu_Button.dart';
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

  Widget _animatedWidget;
  Size _topWidgetSize;
  Size _bottomWidgetSize;

  Animation<double> _animation;
  AnimationController _controller;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _topWidgetSize = Size(500,0);
    _bottomWidgetSize = Size(500,0);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    //_animation = Animation
    _animation = CurvedAnimation(
      parent: _controller, 
      curve: Curves.elasticInOut
    );
    //_controller.forward();
  }

  void initWidget(BuildContext context){
    _animatedWidget = Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.orange[600],
            width: double.infinity,
            height: MediaQuery.of(context).size.height*0.5,
            child: MaterialButton(
              splashColor: Colors.black12,
              highlightColor: Colors.transparent,
              child: Text(
                "Gaseste localul perfect",
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: -0.5
                ),
              ),
              onPressed: (){
                setState(() {
                  print("Gaseste localul perfect");
                  //_animatedWidget = QuestionsSearch();
                  _animatedWidget = Text("Da");
                });
              }
            ),
          ),
        ),
        Divider(),
        Expanded(
          child: Container(
            color: Colors.blueGrey,
            width: double.infinity,
            height: MediaQuery.of(context).size.height*0.5,
            child: MaterialButton(
              splashColor: Colors.black12,
              highlightColor: Colors.transparent,
              child: Text(
                "Reducerile de astazi",
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: -0.5
                ),
              ),
              onPressed: (){
                setState(() {
                  print("Reducerile de astazi");
                  _animatedWidget = DiscountLocalsPage();
                });
              }
            ),
          ),
        ),
      ],
    );
    _topWidgetSize = Size(500,MediaQuery.of(context).size.height*0.5);
    _bottomWidgetSize = Size(500,MediaQuery.of(context).size.height*0.5);
  }

  @override
  Widget build(BuildContext context) {

    //initWidget(context);_controller.forward();

    return StreamBuilder(
      stream: authService.seatingStatus,
      builder: (context, ss) {
        //print(authService.currentUser.isAnonymous.toString() + "ANONIM");
      if(authService.currentUser.isAnonymous != true)
        if(!ss.hasData) // Checks if the user is seated or not
          return Scaffold(body: Center(child: CircularProgressIndicator(),));
        else if(ss.data.docs.length == 1 )
          return SeatingInterface(place: ss.data.docs[0]);
      //else
        return StreamBuilder<bool>(
          stream: QueryService.userLocationStream.stream,
          builder: (context, location) {
            if(!location.hasData)
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                )
              );
            if(location.data == false)
              return Scaffold(body: Container(
                padding: EdgeInsets.only(left: 30),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/hyuga-logo.png',
                      width:50
                    ),
                    SizedBox(height: 40,),
                    Text(
                      "Hyuga nu are acces la locatie :( \n Va rugam sa permiteti accesul din setari.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ));
            else {
              //_controller.forward();
              return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Theme.of(context).backgroundColor,
              key: _drawerKey,
              drawer: _drawer,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.menu),
                  iconSize: 20,
                  color: Colors.black,
                  //color: Colors.blueGrey,
                  onPressed: () async {
                    _drawerKey.currentState.openDrawer();
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    splashColor: Colors.white.withOpacity(0.8),
                    highlightColor: Colors.white.withOpacity(0.2),
                    icon: FaIcon(FontAwesomeIcons.search, size: 18),
                    color: Colors.black,
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
                  //_controller.reset();
                  _controller.forward();
                  return ScaleTransition(
                    scale: _animation,
                    child: Stack(// used a builder for the context
                    //mainAxisAlignment: MainAxisAlignment.center,
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
                                    //focalRadius: 1,
                                    //focal: Alignment.bottomLeft,
                                    transform: GradientRotation(2),
                                    colors: [
                                      Colors.orange[600],
                                      Colors.orange[800]
                                    ]
                                  )
                                ),
                                //color: Colors.orange[600],
                                width: double.infinity,
                                height: _topWidgetSize.height,
                                child: MaterialButton(
                                  splashColor: Colors.black12,
                                  highlightColor: Colors.transparent,
                                  child: Text(
                                    "Gaseste localul perfect",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: -0.5
                                    ),
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      print(_topWidgetSize.height);
                                      //_topWidgetSize = Size(500,MediaQuery.of(context).size.height*0.9);
                                      //_bottomWidgetSize = Size(500,MediaQuery.of(context).size.height*0.1);
                                      //Future.delayed(Duration(milliseconds: 500)).then((value) => _topWidgetSize = Size(500,MediaQuery.of(context).size.height*0.9));
                                    });
                                    Navigator.push(
                                        context, 
                                        PageRouteBuilder(
                                          opaque: false,
                                          //barrierColor: Colors.blueGrey.withOpacity(0.1),
                                          barrierDismissible: true,
                                          transitionDuration: Duration(milliseconds: 1500),
                                          transitionsBuilder: (context, Animation<double> animation, Animation<double> secondAnimation, Widget child){
                                            var _animation = CurvedAnimation(parent: animation, curve: Curves.elasticInOut);
                                            //var _controller = AnimationController()
                                            return SlideTransition(
                                              child: child,
                                              position: Tween<Offset>(
                                                begin: Offset(0,-1),
                                                end: Offset(0,0)
                                              ).animate(_animation)
                                            );
                                            // return ScaleTransition(
                                            //   alignment: Alignment.topCenter,
                                            //   scale: animation,
                                            //   child: child
                                            // );
                                          },
                                          pageBuilder: (context, Animation<double> animation, Animation<double> secondAnimation){
                                            return QuestionsSearch();
                                          }
                                        )
                                      ).then(
                                        (value) =>g.resetSearchParameters()
                                      );
                                    // setState(() {
                                    //   print("Gaseste localul perfect");
                                    //   //_animatedWidget = QuestionsSearch();
                                    //   //_animatedWidget = Text("Da");
                                    //   _topWidgetSize = Size(double.infinity,MediaQuery.of(context).size.height);
                                    // });
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
                                //color: Colors.blueGrey,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.topLeft,
                                    transform: GradientRotation(2),
                                    colors: [
                                      Colors.blueGrey[600],
                                      Colors.blueGrey[700]
                                    ]
                                  )
                                ),
                                width: double.infinity,
                                height: _bottomWidgetSize.height,
                                //height: MediaQuery.of(context).size.height*0.5,
                                child: MaterialButton(
                                  splashColor: Colors.black12,
                                  highlightColor: Colors.transparent,
                                  child: Text(
                                    "Reducerile de astazi",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: -0.5
                                    ),
                                  ),
                                  onPressed: (){
                                    //setState(() {
                                      // print("Reducerile de astazi");
                                      // _animatedWidget = DiscountLocalsPage();
                                      //_bottomWidgetSize = Size(600,MediaQuery.of(context).size.height);
                                      Navigator.push(
                                        context, 
                                        PageRouteBuilder(
                                          opaque: false,
                                          //barrierColor: Colors.blueGrey.withOpacity(0.1),
                                          barrierDismissible: true,
                                          transitionDuration: Duration(milliseconds: 1500),
                                          transitionsBuilder: (context, Animation<double> animation, Animation<double> secondAnimation, Widget child){
                                            var _animation = CurvedAnimation(parent: animation, curve: Curves.elasticInOut);
                                            //var _controller = AnimationController()
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
                            //fontWeight: FontWeight.bold
                          ),
                        )
                      ),
                      //ScaleTransition(scale: _animation, child: FlutterLogo(size: 150,))
                    ]
                ),
                  );
                } 
              ),
            );
            }
            
          }
        );
      }
    );
  }
}