import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:provider/provider.dart';

class SearchBarPage extends StatefulWidget {
  @override
  _SearchBarPageState createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {

  //int _searchCount = 0;
  //Stream<List> _searchResult;
  String? _keyword;
  TextEditingController? _textController;
  
  @override
  void initState() {
    super.initState();
    //_searchCount = 0;
    _keyword = "";
    _textController = TextEditingController();
    //_searchResult = [];
  } 

  Stream<List<DocumentSnapshot>>? searchResults(){
    if(_keyword != "")
      return FirebaseFirestore.instance.collection('locals_bucharest')
      .snapshots()
      .map<List<DocumentSnapshot>>((querySnapshot) {
        List<DocumentSnapshot> _searchResults = [];
        querySnapshot.docs.forEach((element) {
          DocumentSnapshot doc = element;
          String placeName = (doc.data() as Map)['name'].toString().toLowerCase();
          if(placeName.contains(_keyword!)){
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
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).accentColor,
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
              labelText: "Cauta un restaurant...",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            controller: _textController,
            onChanged: (string) => setState((){
              _keyword = string.trim();
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
          child: StreamProvider<List<DocumentSnapshot<Object?>>?>.value(
            initialData: [],
            value: searchResults(),
            builder: (context, child) {
              var result = Provider.of<List<DocumentSnapshot<Object?>>?>(context);
              if(_keyword == "")
                return Container();
              else if(result == null)
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinningLogo(),
                    ],
                  );
              else if(result.length == 0) 
                return Center(child: Text("Ne pare rau, nu exista rezultate"),);
              else return ListView.separated(
                shrinkWrap: true,
                itemCount: result.length,
                separatorBuilder: (context,index) => SizedBox(height: 15,),
                itemBuilder: (context, index) {
                  Local place = queryingService.docSnapToLocal(result[index]);
                  return SearchListTile(place: place, key: ValueKey(place.name));
                }
                  
              );
            }
          ),
        ),
      ),
    );
  }
}

class SearchListTile extends StatefulWidget {

  final Local? place;
  final Key? key;
  SearchListTile({this.place, this.key});

  @override
  _SearchListTileState createState() => _SearchListTileState();
}

class _SearchListTileState extends State<SearchListTile> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialButton(
      highlightColor: Colors.grey.withOpacity(0.2),
      splashColor: Colors.orange[600],
      onPressed: () => Navigator.pushNamed(
        context, 
        '/third',
        arguments: [widget.place,false]
      ),
      child: Container(
        height: 80,
        child: Row(
          children: [
            FutureBuilder<Image>( // The Image
              future: widget.place!.image,
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
            Container( // The name
              width: MediaQuery.of(context).size.width*0.65,
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                children: [
                  Text(
                    widget.place!.name!,
                    maxLines: 3,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20
                    )
                  ),
                ],
              ),
            )
          ]
        )
      ),
    );
  }
}