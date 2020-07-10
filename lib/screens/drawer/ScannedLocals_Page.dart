import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/auth_service.dart';
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