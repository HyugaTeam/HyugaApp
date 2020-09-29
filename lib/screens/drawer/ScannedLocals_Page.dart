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
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List> getScanHistory() async {
    QuerySnapshot scanHistory = await _db.collection('users')
    .doc(authService.currentUser.uid).collection('scan_history')
    //.where('approved_by_user', isEqualTo: true) 
    .get();
    itemCount = scanHistory.docs.length;
    return scanHistory.docs.map((doc)=>doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getScanHistory(),
        builder:(context, scanHistory){ 
          if(!scanHistory.hasData)
            return Scaffold(appBar: AppBar(),body: Center(child: CircularProgressIndicator()),);
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
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height*0.03, vertical: MediaQuery.of(context).size.width*0.05),
                child: ListView.separated(
                  itemCount: scanHistory.data.length,
                  separatorBuilder: (context,index) => SizedBox(
                    height: 10,
                  ),
                  itemBuilder: (context, index){
                    return GestureDetector(
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
                            height: MediaQuery.of(context).size.height*0.75,
                            child: Scaffold(
                              body: Column(
                                children: [
                                  GestureDetector( // When the image is tapped, it pushes the ThirdPage containing the place
                                    onTap: () async {
                                      await _db
                                      .collection('locals_bucharest').doc(scanHistory.data[index]['place_id'])
                                      .get().then((value) => 
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
                                          TextSpan(
                                            text: scanHistory.data[index]['number_of_guests'] != null 
                                            ? scanHistory.data[index]['number_of_guests'].toString()
                                            : "1"
                                          )
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
                                            DateTime.fromMillisecondsSinceEpoch(scanHistory.data[index]['date_start'].millisecondsSinceEpoch).toString()
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                          child: Container(
                          // constraints: BoxConstraints(
                          //   maxHeight: 225,
                          //   maxWidth: 400,
                          // ),
                          // height: 300,
                          // width: 105,
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
                          child: Stack(
                            //alignment: Alignment.center,
                            children: [
                              Container( // The background image of the List Tile
                                  //padding: EdgeInsets.only(top: 20),
                                  height: 225,
                                  width: 400,
                                  child: FutureBuilder(
                                    future: queryingService.getImage(scanHistory.data[index]['place_id']),
                                    builder: (context, image) {
                                      if(!image.hasData)
                                        return Container(); 
                                      else return image.data;
                                    }
                                  ),
                                ),
                              Container( // The Gradient over the image
                                  height: 225,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent,Colors.black87]
                                    )
                                  ),
                                ),
                              Positioned(
                                //width: MediaQuery.of(context).size.width*0.8,
                                height: 300,
                                bottom: 15,
                                left: 15,
                                child: Container(

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    verticalDirection: VerticalDirection.up,
                                    children: [ 
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.9,
                                        child: Row(
                                          
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          //spacing: MediaQuery.of(context).size.width*0.05,  
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width*0.6,
                                                ),
                                                child: Text(
                                                  //"Trattoria Buongiorno Covaci",
                                                  scanHistory.data[index]['place_name'],
                                                  style: TextStyle(
                                                    wordSpacing: 0.1,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Colors.white
                                                  ),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              indent: 10,
                                            ),
                                            ClipOval(
                                              child: Container(
                                                //padding: EdgeInsets.only(bottom: 20),
                                                color: Colors.white,
                                                height: 7,
                                                width: 7
                                              ),
                                            ),
                                            Divider(
                                              indent: 10,
                                            ),
                                            scanHistory.data[index]['total'] != null
                                            ? Flexible(
                                              child: Text(
                                                scanHistory.data[index]['total'] == scanHistory.data[index]['total'].toInt()
                                                  ? scanHistory.data[index]['total'].toInt().toString()+" RON"
                                                  : scanHistory.data[index]['total'] +" RON",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                                ),
                                                maxLines: 2,
                                              ),
                                            )
                                            : Container()
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(top: 5, bottom: 8),
                                        child: Text(
                                          /// A formula which converts the Timestamp to Date format
                                          'Data: ' + DateTime.fromMillisecondsSinceEpoch(scanHistory.data[index]['date_start'].millisecondsSinceEpoch, isUtc: true).toLocal().toString()
                                          .substring(0,16),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[600]
                                          ),
                                        ),
                                      ),
                                      // Container(
                                      //   child: Wrap(
                                      //     crossAxisAlignment: WrapCrossAlignment.center,
                                      //     children: [
                                      //       Text(
                                      //         "Total: "+scanHistory.data[index]['total'].toString()+"RON",
                                      //         style: TextStyle(
                                      //           fontSize: 20,
                                      //           color: Colors.white,
                                      //           fontWeight: FontWeight.bold
                                      //         ),
                                      //       )
                                      //     ]
                                      //   )
                                      // ),
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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