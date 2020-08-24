import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/drawer.dart';

class ScannedLocalsPage extends StatefulWidget {

  List<Local> favoritePlaces ;
  //DateTime date = DateTime.tryParse(formattedString)
  ScannedLocalsPage(){
    
  }


  @override
  _ScannedLocalsPageState createState() => _ScannedLocalsPageState();
}

class _ScannedLocalsPageState extends State<ScannedLocalsPage> {

  Future<List> getScanHistory() async {
    QuerySnapshot scanHistory = await Firestore.instance.collection('users')
    .document(authService.currentUser.uid).collection('scan_history')
    .getDocuments();

    return scanHistory.documents.map((doc)=>doc.data).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
      ),
      //drawer: ProfileDrawer(),
      body: FutureBuilder(
        future: getScanHistory(),
        builder:(context, scanHistory){ 
          if(!scanHistory.hasData)
            return Center(child: CircularProgressIndicator(),);
          else if(scanHistory.data == 0)
            return Center(child: Text("You have no scans! \n Start scanning now!"),);
          else
            return  Container(
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
                    height: 150,
                    width: 200,
                    child: ListTile(
                      onTap: (){
                        Future<Image> placeImage;
                        try{
                          placeImage = queryingService.getImage(scanHistory.data[index]['place_id']);
                        }
                        catch(e){}
                        // Shows a pop-up containing the details about the bill
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context, builder: (context) => Scaffold(
                          body: Wrap(
                            children: [Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              verticalDirection: VerticalDirection.up,
                              children: [
                                GestureDetector( // When the image is tapped, it pushes the ThirdPage containing the place
                                  onTap: () async {
                                    await Firestore.instance
                                    .collection('locals_bucharest').document(scanHistory.data[index]['place_id']).get().then((value) => 
                                    Navigator.pushNamed(
                                        context,
                                        '/third',
                                        arguments: queryingService.docSnapToLocal(value)
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
                                      style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Comfortaa'),
                                      children:[
                                        TextSpan(text: "Valoare finala bon: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: scanHistory.data[index]['total'].toString())
                                      ]
                                    ), 
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Container(
                                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.035),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Comfortaa'),
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
                                      style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Comfortaa'),
                                      children:[
                                        TextSpan(text: "Nr persoane: ", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Comfortaa'),
                                      children:[
                                        TextSpan(text: "Data: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(
                                          text: 
                                          scanHistory.data[index]['date'].toString()
                                        )
                                      ]
                                    ), 
                                  ),
                                )
                              ],
                            ),
                          ]),
                          )
                        );
                      },
                      isThreeLine: true,
                      contentPadding: EdgeInsets.all(20),
                      leading: Text((index+1).toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                      title: Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                        child: Text(
                          /// A formula which converts the Timestamp to Date format
                          'Place: ' + scanHistory.data[index]['place_name'],
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
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "Discount: "+ scanHistory.data[index]['applied_discount'].toString() + '%',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.blueGrey
                              )
                            )
                          )
                        ]
                      ),
                      trailing: Container(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Sum: ',
                            ),
                            Text(
                              scanHistory.data[index]['total'].toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ]
                        )
                      ),
                    ),
                  );
                }
              )
            );
        },
      ),
    );
  }
}