import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/querying_service.dart';

class SearchBarPage extends StatefulWidget {
  @override
  _SearchBarPageState createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {

  int _searchCount = 0;
  //Stream<List> _searchResult;
  String _keyword;
  TextEditingController _textController;
  
  @override
  void initState() {
    super.initState();
    _searchCount = 0;
    _keyword = "";
    _textController = TextEditingController();
    //_searchResult = [];
  } 

  Stream<List<DocumentSnapshot>> searchResults(){
    if(_keyword != "")
      return FirebaseFirestore.instance.collection('locals_bucharest')
      .snapshots()
      .map<List<DocumentSnapshot>>((querySnapshot) {
        List<DocumentSnapshot> _searchResults = List();
        querySnapshot.docs.forEach((element) {
          DocumentSnapshot doc = element;
          String placeName = doc.data()['name'].toString().toLowerCase();
          if(placeName.contains(_keyword)){
            //print(_searchResults);
            _searchResults.add(doc);
          }
        });
      // print("gata");
        return _searchResults;
      });
    else return null;
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            
            style: TextStyle(
              color: Colors.white
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(3),
              fillColor: Colors.white,
              suffixIcon: Icon(Icons.search,size: 15,color: Colors.white,),
              labelText: "Cauta un restaurant..."
            ),
            controller: _textController,
            onChanged: (string) => setState((){
              _keyword = string;
            }),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: MediaQuery.of(context).size.width*0.05,

        ),
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height*0.9,
        child: Container(
          child: StreamBuilder(
            stream: searchResults(),
            builder: (context, result) {
              if(!result.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else if(result.data.length == 0) 
                return Center(child: Text("Ne pare rau, nu exista rezultate"),);
              else return ListView.separated(
                shrinkWrap: true,
                itemCount: result.data.length,
                separatorBuilder: (context,index) => SizedBox(height: 15,),
                itemBuilder: (context, index) =>
                  SearchListTile(place: queryingService.docSnapToLocal(result.data[index]))
              );
            }
          ),
        ),
      ),
    );
  }
}

class SearchListTile extends StatefulWidget {

  final Local place;
  SearchListTile({this.place});

  @override
  _SearchListTileState createState() => _SearchListTileState();
}

class _SearchListTileState extends State<SearchListTile> with AutomaticKeepAliveClientMixin{

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context, 
        '/third',
        arguments: [widget.place,false]
      ),
      child: Container(
        // padding: EdgeInsets.symmetric(
        //   //vertical: 100,
        //   horizontal: MediaQuery.of(context).size.width*0.05,
        // ),
        height: 80,
        child: Row(
          children: [
            FutureBuilder(
              future: widget.place.image,
              builder: (context,image){
                if(!image.hasData)
                  return SizedBox(
                    width: 50,
                  );
                else return SizedBox(
                  width: 50,
                  height: 50,
                  child: image.data,
                );
                
              },
            ),
            SizedBox(width: 10,),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      Text(
                        widget.place.name,
                        maxLines: 3,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20
                        )
                      ),
                    ],
                  )
                ],
              ),
            )
          ]
        )
      ),
    );
  }
}