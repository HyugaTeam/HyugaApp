import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/services/querying_service.dart';
import 'package:shimmer/shimmer.dart';

/// A class which renders the list of queried locals
class Locals extends StatefulWidget {
  @override
  _LocalsState createState() => _LocalsState();
}

class _LocalsState extends State<Locals> {

  ScrollController _scrollController = ScrollController();

  @override 
  void initState(){
    _scrollController.addListener(() {
      // if we scroll all the way to the bottom of the ListView, it will fetch new data.
      // if(_scrollController.position.maxScrollExtent == _scrollController.offset){
      //   locals.loadMore();
      // }
    });
    super.initState();
  }

  Future refresh(){
    // setState(() {
    //   widget.createState();
    // });
    //(context as Element).reassemble();
    return Future((context as Element).reassemble);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: queryingService.fetch(),
      builder:(context,snapshot){
        if(!snapshot.hasData) 
          return Center(child: CircularProgressIndicator(),);
        else
          return RefreshIndicator(
            displacement: 50,
            onRefresh: refresh,
            child: Container(
            //color: Colors.grey[300],
            color: Colors.white,
            padding: EdgeInsets.only(
              //top: 30,
              left: 8,
              right: 8
            ),
            child: ListView.builder( 
              physics: const AlwaysScrollableScrollPhysics(), 
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        //color: Theme.of(context).backgroundColor,
                        //color: Colors.grey[300]
                      ),
                      child:  Stack(
                        children: <Widget>[
                          MaterialButton(
                          //color: Colors.blueGrey,
                          textTheme: ButtonTextTheme.primary,
                          // onPressed:(){
                          //   Navigator.pushNamed(
                          //     context, 
                          //     '/third',
                          //     arguments: g.placesList[index]
                          //   );
                          // },
                          onPressed: (){},
                          child: Column(
                            children: <Widget>[
                              Container( // The Main Image
                                //color: Colors.blue,
                                width: 400,
                                height: 200,
                                child: FutureBuilder(
                                  future: (snapshot.data[index]).image,
                                  builder: (context,img){
                                    if(!img.hasData)
                                      return Container(
                                        width: 400,
                                        height: 200,
                                        child: Shimmer.fromColors(child: Container(), 
                                        baseColor: Colors.white, 
                                        highlightColor: Colors.grey),
                                      );
                                    else
                                      return Container(
                                        color: Colors.transparent,
                                        child: img.data
                                        );
                                  }
                                ),
                              ),
                              Container( // Text's container
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                ),
                                padding: EdgeInsets.only(
                                  top: 8,
                                  bottom: 8,
                                  left: 20
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Text( // 'Name' text
                                        snapshot.data[index].name != null ? snapshot.data[index].name: 'null',
                                        style: TextStyle(
                                          shadows: [ Shadow(
                                            blurRadius: 2,
                                            color: Colors.black, 
                                            offset: Offset(0.7,0.7)
                                            ),
                                          ],
                                          fontSize: 20,
                                          letterSpacing: 0.4,
                                          fontWeight: FontWeight.values[4],
                                          color: Colors.white,
                                          fontFamily: 'Roboto'
                                        ),
                                      ),
                                  //Text('${QueryService().getLocation()}')
                                  ],
                                ),
                                alignment: Alignment(-1, -1),
                              ),
                            ],
                            )
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Opacity(  // The InkWell responsible for the splash effect
                            opacity: 0.2,
                            child: Material(
                              type: MaterialType.button,
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: (){
                                  Navigator.pushNamed(
                                    context, 
                                    '/third',
                                    arguments: snapshot.data[index]
                                  );
                                  print('////////////');
                                },
                                splashColor: Colors.orange[600],
                                child: Container(
                                  width: 349,
                                  height: 240 
                                )
                              )
                            ),
                          ),
                        ),
                        Positioned(  // 'Add to favorites button'
                          right:0,
                          top: 0,
                          child: FloatingActionButton(
                            hoverElevation: 0,
                            heroTag: null, // Added to prevent "There are multiple heroes that share the same tag within a subtree."
                            elevation: 1,
                            backgroundColor: Colors.orange[600],
                            child: FaIcon(FontAwesomeIcons.plus),
                            onPressed: (){
                              if(g.isSnackBarActive == false){
                                g.isSnackBarActive = true;
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.orange[600],
                                  content: Text("Added to favorites."),
                                )).closed.then((reason){
                                  g.isSnackBarActive = false;
                                });
                              }
                            },
                          ),
                        ),
                        ],
                      )
                    ),
                    SizedBox(
                      height:20
                    )
                  ],
                );
              }
            )
          ),
        );
      }
    );
  }
}