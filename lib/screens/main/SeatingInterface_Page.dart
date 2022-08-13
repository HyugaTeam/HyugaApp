import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SeatingInterface extends StatefulWidget {

  final DocumentSnapshot? place;
  SeatingInterface({this.place}){
    //getPlaceData()
  }

  @override
  _SeatingInterfaceState createState() => _SeatingInterfaceState();
}

class _SeatingInterfaceState extends State<SeatingInterface> with TickerProviderStateMixin{

  Image placeImage = Image.memory(Uint8List(0));
  ScrollController? _scrollController;
  TabController? _tabController;

  GlobalKey<ScaffoldState>? _scaffoldKey;

  late AnimationController _controller;
  late Animation<double> _animation;

  /// Workaround variable for the 'widget.place.data()' Object to Map
  dynamic reservationData;

  Stream<String> get time{
    return Stream.periodic(
      Duration(milliseconds: 1000),
      (i){
        Timestamp dateStart = reservationData['date_claimed'] == null ? reservationData['date_start'] : reservationData['date_claimed'];
        Duration duration = DateTime.now().toLocal().difference(DateTime.fromMillisecondsSinceEpoch(dateStart.millisecondsSinceEpoch));
        String hours = duration.inHours< 10 ? '0'+duration.inHours.toString() : duration.inHours.toString();
        String minutes = duration.inMinutes%60 < 10 ? '0'+(duration.inMinutes%60).toString(): (duration.inMinutes%60).toString();
        String seconds = duration.inSeconds%60 < 10 ? '0'+(duration.inSeconds%60).toString() : (duration.inSeconds%60).toString();
        return 
          hours +':'+
          minutes.toString()+':'+
          seconds.toString(); 
      }
    );
  }

  Future<Place> getPlaceData() async{
    DocumentSnapshot placeData = await FirebaseFirestore.instance
    .collection('locals_bucharest').doc(reservationData['place_id']).get();
    print(placeData.data());
    Place place = queryingService.docSnapToLocal(placeData);
    return place;
  }
  
  String formatDeals(List? deals){
    String result = "";
    if(deals != null)
      deals.forEach((element) {
        result += element['title'] + " - ";
        result += element['content']+'\n\n';
      });
    return result == "" ? "Nicio oferta" : result;
    
  }

  @override
  void initState() {
    super.initState();
    
    /// Here is the workaround
    reservationData = widget.place!.data() as Map?;

    _scaffoldKey = GlobalKey<ScaffoldState>();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController(initialScrollOffset: 0);
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this
    );
    _animation = CurvedAnimation(
      parent: _controller, 
      curve: Curves.elasticInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: Icon(Icons.report,color: Colors.blueGrey,),
            tooltip: "Raporteaza o problema",
            onPressed: (){
              if(reservationData['issue_ref'] == null)
              showDialog(
                context: context,
                builder: (context){
                  return Dialog(
                    insetAnimationDuration: Duration(milliseconds: 1000),
                    insetAnimationCurve: Curves.elasticIn,
                    child: DefaultTabController(
                      initialIndex: 0,
                      length: 2,
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.5,
                        width: MediaQuery.of(context).size.width*0.5,
                        child: TabBarView(
                          controller: _tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            Container( /// First Step
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ai o problema?",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  RaisedButton(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    color: Colors.white,
                                    highlightColor: Colors.grey.withOpacity(0.4),
                                    splashColor: Colors.orange[600],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    elevation: 1,
                                    highlightElevation: 2,
                                    child: Text(
                                      "Nu pot folosi aplicatia, desi am parasit localul.",
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: (){
                                      AnalyticsService().analytics.logEvent(name: "need_help", parameters: {"place_id": reservationData['place_id']});
                                      DocumentReference issueRef = FirebaseFirestore.instance.collection('issues').doc();
                                      issueRef.set(
                                        {
                                          'guest_id': authService.currentUser!.uid,
                                          'guest_name': authService.currentUser!.displayName,
                                          'place_id': reservationData['place_id'],
                                          'place_name': reservationData['place_name'],
                                          'issue_ref': widget.place!.reference
                                        }
                                      );
                                      widget.place!.reference.set(
                                        {
                                          'issue_ref': issueRef
                                        },  
                                        SetOptions(merge: true)
                                      );
                                      _tabController!.animateTo(
                                        1
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Te vom ajuta in scurt timp",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Text(
                                    "Daca inca nu ai parasit localul, cere ajutorul personalului.",
                                    style: TextStyle(fontSize: 14),
                                  )
                                ],
                              ),
                            )
                          ]
                        ),
                      ),
                    ),
                  );
                }
              ).then((value) => _tabController!.index = 0);
              else _scaffoldKey!.currentState!.showSnackBar(
                SnackBar(
                  content: Text("O problema a fost deja raportata.")
                )
              );
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body:  Builder(
        builder: (context) {
          _controller.forward();
          return ScaleTransition(
            scale: _animation,
            child: FutureBuilder<Place>(
              future: getPlaceData(),
              builder: (context, place) {
                if(!place.hasData)
                  return Center(child: SpinningLogo());
                else {
                  return Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    GoogleMap( /// The background Google Map
                      markers: {
                        Marker(
                          markerId: MarkerId("1"),
                          position: LatLng(place.data!.location!.latitude,place.data!.location!.longitude),
                        )
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(place.data!.location!.latitude,place.data!.location!.longitude),
                        zoom: 16
                      ),
                    ),
                    Opacity( // An orange shade on the map
                      opacity: 0.2,                
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.orange[600],
                      ),
                    ),
                    Positioned( // The text about the place
                      top: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)),
                          color: Colors.white
                        ),
                        width: MediaQuery.of(context).size.width*0.8,
                        height: MediaQuery.of(context).size.height*0.2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                "Te afli la ${reservationData['place_name']}",
                                style: TextStyle(
                                  fontSize: 18
                                ),
                              )
                            ),
                            SizedBox(height: 15,),
                            Text(
                              "Pofta buna!",
                              style: TextStyle(
                                fontSize: 23
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.25,
                      maxChildSize: 0.8,
                      builder: (context,_scrollController){
                        return SingleChildScrollView(
                          controller: _scrollController,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                              color: Colors.white,
                            ),
                            height: MediaQuery.of(context).size.height*0.8,
                            child: Column(
                              children: [
                                Container(// The place's image
                                  constraints: BoxConstraints(
                                    maxHeight: 400
                                  ),
                                  child: AspectRatio( 
                                    aspectRatio: 16/9,
                                    child: FutureBuilder<Image>(
                                      future: place.data!.image,
                                      builder: (context, image){
                                        if(!image.hasData)
                                          return Container();
                                        else return ClipRRect(
                                          child: image.data,
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                                        );
                                      }
                                    ),
                                  ),
                                ),
                                Text(
                                  "* Reducerea in procent si ofertele se pot aplica doar individual si nu se cumuleaza. Clientul trebuie sa aleaga intre reducere si oferte",
                                  style: TextStyle(
                                    fontSize: 12
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container( /// Discount
                                  padding: EdgeInsets.symmetric(vertical: 20,),
                                  child: Text.rich(
                                     TextSpan(
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Reducere   ",
                                          style: TextStyle(
                                            fontSize: 20,
                                            
                                          )
                                        ),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: ClipOval(
                                            child: Container(
                                              alignment: Alignment.center,
                                              color: Colors.black,
                                              height: 7,
                                              width: 7
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '   ' + reservationData['discount'].toString()+'%',
                                          style: TextStyle()
                                        )
                                      ]
                                    )
                                  ),
                                ),
                                Container( /// Deals
                                  padding: EdgeInsets.symmetric(vertical: 20,),
                                  child: 
                                     Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RaisedButton(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          color: Theme.of(context).highlightColor,
                                          child: Text(
                                            "Oferte disponibile",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                          onPressed: (){
                                            showDialog(
                                              context: context, 
                                              builder: (context) => AlertDialog(
                                                content: Text(
                                                  '\n' + formatDeals(reservationData['deals']),
                                                  style: TextStyle(
                                                    fontSize: 16
                                                  )
                                                ),
                                              )
                                            );
                                          },
                                        ),
                                      ]
                                    ),
                                ),
                                Container( /// Discount
                                  padding: EdgeInsets.symmetric(vertical: 20,),
                                  child: Text.rich(
                                     TextSpan(
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Ora de inceput   ",
                                          style: TextStyle(
                                            fontSize: 20,
                                          )
                                        ),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: ClipOval(
                                            child: Container(
                                              alignment: Alignment.center,
                                              color: Colors.black,
                                              height: 7,
                                              width: 7
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '   ' 
                                          + DateFormat('hh:mm').format(DateTime.fromMillisecondsSinceEpoch(
                                            reservationData['date_start'].millisecondsSinceEpoch
                                            ))
                                            .toString(),
                                          style: TextStyle()
                                        )
                                      ]
                                    )
                                  ),
                                ),
                                StreamProvider<String?>.value(
                                  initialData: null,
                                  value: time,
                                  builder: (context, child){
                                    var time = Provider.of<String?>(context);
                                    return Text(
                                      time != null
                                      ? time
                                      : "00:00:00",
                                      style: TextStyle(
                                        color: Colors.orange[600],
                                        fontSize: 35*(1/MediaQuery.of(context).textScaleFactor),
                                        fontWeight: FontWeight.bold
                                      ),
                                    );
                                  }
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                );
                }
              }
            ),
          );
        }
      ),
    );
  }
}