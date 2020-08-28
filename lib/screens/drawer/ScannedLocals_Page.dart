import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/drawer.dart';

class ScannedLocalsPage extends StatefulWidget {

  @override
  _ScannedLocalsPageState createState() => _ScannedLocalsPageState();
}

class _ScannedLocalsPageState extends State<ScannedLocalsPage> {

  int itemCount;

  Future<List> getScanHistory() async {
    QuerySnapshot scanHistory = await Firestore.instance.collection('users')
    .document(authService.currentUser.uid).collection('scan_history')
    .getDocuments();
    itemCount = scanHistory.documents.length;
    return scanHistory.documents.map((doc)=>doc.data).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getScanHistory(),
        builder:(context, scanHistory){ 
          if(!scanHistory.hasData)
            return Scaffold(appBar: AppBar(),body: CircularProgressIndicator(),);
          else if(scanHistory.data == 0)
            return Scaffold(appBar: AppBar(),body: Center(child: Text("Nu ai nicio scanare. \n Incepe sa scanezi pentru a revendica reduceri!"),));
          else
            return  Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(itemCount == null? "" : itemCount.toString()+" scanari"),
                backgroundColor: Colors.blueGrey,
              ),
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: ListView.builder(
                  itemCount: scanHistory.data.length,
                  itemBuilder: (context, index){
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45, 
                            offset: Offset(1.5,1),
                            blurRadius: 2,
                            spreadRadius: 0.2
                          )
                        ],
                      ),
                      height: 200,
                      width: 400,
                      child: Stack(
                        children: [
                          Container(
                              //padding: EdgeInsets.only(top: 20),
                              height: 400,
                              width: 200,
                              child: FutureBuilder(
                                future: queryingService.getImage(scanHistory.data[index]['place_id']),
                                builder: (context, image) {
                                  if(!image.hasData)
                                    return Container();
                                  else return image.data;
                                }
                              ),
                            ),
                          ListTile(
                            onTap: (){
                              Future<Image> placeImage;
                              try{
                                placeImage = queryingService.getImage(scanHistory.data[index]['place_id']);
                              }
                              catch(e){}
                              // Shows a pop-up containing the details about the bill
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context, builder: (context) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30)
                                    )
                                  ),
                                  height: MediaQuery.of(context).size.height*0.6,
                                  child: Scaffold(
                                    //backgroundColor: Colors.orangeAccent,
                                    body: Column(
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //verticalDirection: VerticalDirection.up,
                                      children: [
                                    GestureDetector( // When the image is tapped, it pushes the ThirdPage containing the place
                                      onTap: () async {
                                        await Firestore.instance
                                        .collection('locals_bucharest').document(scanHistory.data[index]['place_id']).get().then((value) => 
                                        Navigator.pushNamed(
                                            context,
                                            '/third',
                                            /// The first argument stands for the actual 'Local' information
                                            /// The second argument stands for the 'Route' from which the third page came from(for Analytics purpose)
                                            arguments: [queryingService.docSnapToLocal(value),false] 
                                        ));
                                      },
                                      child: Stack(
                                        children: [
                                          Container( // The place's profile image
                                            color: Colors.grey[100],
                                            width: double.infinity,
                                            height: 300,
                                            constraints: BoxConstraints(
                                              maxHeight: 300
                                            ),
                                            child: FutureBuilder(
                                              future: placeImage,
                                              builder: (context,img){
                                                if(!img.hasData)
                                                  return CircularProgressIndicator();
                                                else
                                                  return img.data;
                                              }
                                            ),
                                          ),
                                          Container(
                                            height: 300,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.transparent,Colors.black87]
                                              )
                                            ),
                                          ),
                                          Positioned(
                                            left: 25,
                                            bottom: 25,
                                            width: 300,
                                            //height: 300,
                                            child: Text(
                                              scanHistory.data[index]['place_name'], 
                                              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                                            )
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Container(
                                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                          children:[
                                            TextSpan(text: "Valoare finala bon: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(text: scanHistory.data[index]['total'].toString()+"RON")
                                          ]
                                        ), 
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Container(
                                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                          children:[
                                            TextSpan(text: "Discount: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(text: scanHistory.data[index]['applied_discount'].toString() + "%")
                                          ]
                                        ), 
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Container(
                                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                          children:[
                                            TextSpan(text: "Numar persoane: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(text: scanHistory.data[index]['number_of_guests'].toString())
                                          ]
                                        ), 
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Container(
                                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Comfortaa'),
                                          children:[
                                            TextSpan(text: "Data: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(
                                              text: 
                                              DateTime.fromMillisecondsSinceEpoch(scanHistory.data[index]['date'].millisecondsSinceEpoch).toString()
                                            )
                                          ]
                                        ), 
                                      ),
                                    )
                                        ],
                                      ),
                                    ),
                                )
                              );
                            },
                            isThreeLine: true,
                            title: Container(
                              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                              child: Text(
                                scanHistory.data[index]['place_name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    /// A formula which converts the Timestamp to Date format
                                    'Date: ' + DateTime.fromMillisecondsSinceEpoch(scanHistory.data[index]['date'].millisecondsSinceEpoch, isUtc: true).toLocal().toString()
                                    .substring(0,16),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[600]
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    "Discount: "+ scanHistory.data[index]['applied_discount'].toString() + '%',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.blueGrey
                                    )
                                  )
                                ),
                                Container(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        'Sum: ',
                                      ),
                                      Text(
                                        scanHistory.data[index]['total'].toString()+"RON",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                        ),
                                      )
                                    ]
                                  )
                                ),
                              ]
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                )
              ),
            );
        },
      ) ;
  }
}