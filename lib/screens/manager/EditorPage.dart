import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/profile_image_hero.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';



class EditorPage extends StatefulWidget {

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {

  bool areThereChanges = false; // adds an UI interaction whenever a field is changed
  ManagedLocal temporaryChanges;
  Map<String,dynamic> changesMap;
  File _unsavedProfileImage;
  String _unsavedProfileImagePath = "";
  String _unsavedTimeInterval = "";

  /// A method which builds the TextController for 'Name' & 'DeTscription' fields
  TextEditingController buildTextController(String field){
    TextEditingController textController;
    if(field == 'name'){
      textController = new TextEditingController(
        text: temporaryChanges != null? (temporaryChanges.name != null? temporaryChanges.name : ''): ''
      );
      textController.addListener(() {
        setState(() {
          areThereChanges = true;
          temporaryChanges.name = textController.value.text;
        });
      });
    }
    if(field == 'description'){
      textController = new TextEditingController(
        text: temporaryChanges != null? (temporaryChanges.description != null? temporaryChanges.description : ''): ''
      );
      textController.addListener(() {
        setState(() {
          areThereChanges = true;
          temporaryChanges.description = textController.value.text;
        });
      });
    }
    return textController;
  }

  void saveChanges(){

  }

  @override
  Widget build(BuildContext context) {
    
    temporaryChanges = Provider.of<AsyncSnapshot<dynamic>>(context).data;
    List<List<dynamic>> temporaryListOfProfiles = List<List<dynamic>>(); 
    temporaryChanges.profile.forEach((key, value) { temporaryListOfProfiles.add([key,value]); });

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 200,
        height: 40,
        child: FloatingActionButton(
          backgroundColor: areThereChanges == false ? Colors.blueGrey: Colors.orange[600],
          //backgroundColor: floatingButtonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          onPressed: (){},
          child: Text(
            "Salveaza", 
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal :30),
          children: <Widget>[
            ListTile(   // "Name: " Field
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Nume",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  )
                ),
              ),
              subtitle: Container(
                width: 100,
                child: TextField(
                  style: TextStyle(
                  ),
                  maxLength: 200,
                  controller: buildTextController('name'),
                  onSubmitted: (String changedName) => setState((){
                    print(areThereChanges);
                    //floatingButtonColor = Colors.orange[600];
                    areThereChanges = true;
                    temporaryChanges.name = changedName;
                  }),
                ),
              )
            ),
            ListTile(   // "Description: " Field
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Descriere",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ),
              subtitle: Container(
                child: TextField(
                  // minLines: 1,
                  // maxLines: 2,
                  // style: TextStyle(
                  // ),
                  maxLength: 400,
                  controller: buildTextController('description'),
                  onSubmitted: (String changedDescription) => setState((){
                    print(areThereChanges);
                    areThereChanges = true;
                    temporaryChanges.description = changedDescription;
                  }),
                ),
              )
            ),
            ListTile(   // "Capacity: " Field
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Capacitate",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ),
              // subtitle: Container(
              //   padding: EdgeInsets.only(right: 50),
              //   child: DropdownButton(
              //     hint: Text("<selecteaza>"),
              //     ///onTap: ,
              //     items: [
              //       DropdownMenuItem(
              //         value: 1,
              //         child: Text("1")
              //       ),
              //       DropdownMenuItem(
              //         value:  2,
              //         child: Text("2")
              //       )
              //     ], 
              //     onChanged: null
              //   )
              // )
              subtitle: Container(
                padding: EdgeInsets.only(right : 30),
                child: RaisedButton.icon(
                  color: Colors.blueGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  icon: Icon(Icons.person, color: Theme.of(context).backgroundColor, size: 30,),
                  label: Text(
                    temporaryChanges.capacity == null? "" : temporaryChanges.capacity.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).backgroundColor
                    ),
                  ),
                  onPressed: ()=> showDialog(
                    context: context, 
                    barrierDismissible: true, 
                    builder: (context){
                      List<dynamic> availableCapacities = [1,2,3,4,5,6,7,8,"9+"];
                      return SizedBox(
                        //height: availableCapacities.length*50.toDouble(),
                        //color: Colors.transparent,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey[300]
                              ),
                              alignment: Alignment.center,
                              //color: Colors.grey[300],
                              height: 500,
                              width: 300,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                              child: Column(
                                children: <Widget>[
                                  //Text("Capacitate"),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: availableCapacities.length,
                                    itemBuilder: (context,index){
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: MaterialButton(
                                          elevation: 20,
                                          color: Colors.blueGrey,
                                          height: 40,
                                          onPressed: (){
                                            Navigator.of(context).pop(index);
                                          },
                                          child: Center(
                                            child: Text(
                                              availableCapacities[index].toString(), 
                                              style: TextStyle(fontSize: 20,
                                              color: Colors.white),
                                            ),
                                          )
                                        ),
                                      );
                                    }
                                  ),
                                ],
                              ),
                            ),
                        ),
                      );
                    }).then((value) => setState((){
                      if(value != null)
                        temporaryChanges.capacity = int.tryParse(value.toString().substring(0,1))+1;
                      print(temporaryChanges.capacity);
                    })),
                ),
              )
            )
            ,
            // ListTile(
            //   contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            //   title: Text(
            //     "Tipul localului",
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold
            //     ),
            //   ),
            //   subtitle: Container(
            //       child: Padding(
            //         padding: const EdgeInsets.only(top: 8.0),
            //         child: Wrap(
            //           runSpacing: 7,
            //           spacing: 10,
            //           //textDirection: ,
            //           children: temporaryListOfProfiles.map((e) => 
            //             Container(
                          
            //               height: 30,
            //               width: 120,
            //               decoration: BoxDecoration(
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: Colors.black45, 
            //                     offset: Offset(1.5,1),
            //                     blurRadius: 2,
            //                     spreadRadius: 0.2
            //                   )
            //                 ],
            //                 color: Colors.orange[600],
            //                 borderRadius: BorderRadius.circular(25)
            //               ),
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 crossAxisAlignment: CrossAxisAlignment.center,
            //                 children: <Widget>[
            //                   Text(
            //                     e[0].toString() + ": " + e[1].toString(),
            //                     style: TextStyle(
            //                       fontSize: 10,
            //                       fontWeight: FontWeight.bold
            //                     ),
            //                   ),
            //                   SizedBox( // The 'X' icon
            //                     width: 20,
            //                     height: 40,
            //                     child: IconButton(
            //                       iconSize: 20,
            //                       focusColor: Colors.black,
            //                       //splashColor: Colors.black,
            //                       highlightColor: Colors.black,
            //                       icon: Icon(Icons.close), 
            //                       onPressed: (){
            //                         setState(() {
            //                           temporaryChanges.profile.remove(e[0]);
            //                         });
            //                       }
            //                     ),
            //                   )
            //                 ],
            //               ),
            //             )
            //           ).toList(),
            //         ),
            //       )

            //     ),
            // )
            ListTile(
              title: Text(
                "Poza de profil",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
              subtitle: Column(
                children: <Widget>[
                  Stack(
                    children: [
                      Container(  /// The actual Image preview; The image preview fits the entire screen when tapped
                        padding: EdgeInsets.only(top: 20),
                        width: 200,
                        height: 200,
                        child: FutureBuilder<Image>(
                          future: queryingService.getImage(temporaryChanges.id),
                          builder: (context,image){
                            if(!image.hasData)
                              return Container(
                                width: 200,
                                height: 200,
                                child: Shimmer.fromColors(child: Container(), 
                                  baseColor: Colors.white, 
                                  highlightColor: Colors.grey
                                ),
                              );
                            else
                              return GestureDetector(
                                onTap: ()=> Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => HeroProfileImage(
                                    profileImage: image.data,
                                  ),
                                )),
                                child: Hero(
                                  tag: 'profile-image',
                                  child: Container(
                                    color: Colors.transparent,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: FittedBox(
                                        child: image.data,
                                        fit: BoxFit.cover
                                      ),
                                    )
                                  ),
                                )
                              );
                          }
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          //alignment: Alignment.center,
                          width: 40,
                          height: 40,
                          child: RaisedButton(  /// The 'Pick an Image' Button
                            padding: EdgeInsets.zero,
                            elevation: 1,
                            highlightElevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.plus,
                              color: Colors.blueGrey
                            ),
                            onPressed: () async{
                              File _image = await ImagePicker.pickImage(source: ImageSource.gallery);
                              if(_image != null){
                                setState(() {
                                  _unsavedProfileImage = _image;
                                  _unsavedProfileImagePath = _image.uri.path;
                                });
                              }
                            }
                          ),
                        ),
                      ),
                    ]
                  ),
                  SizedBox(height: 20),
                  Text(
                    _unsavedProfileImagePath.substring(_unsavedProfileImagePath.lastIndexOf('/')+1),
                    overflow: TextOverflow.clip,
                  )
                ],
              ),
              
            ),
            ListTile( // The Discount Schedule set up
              title: Text(
                "Program Reduceri",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              subtitle: Column(
                children: <Widget>[
                  // GridView(
                    
                  //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: 3
                  //   ),
                  //   children: <Widget>[
                  //     Text("1"),
                  //     Text("2"),
                  //     Text("3"),
                  //     Text("4")
                  //   ],
                  // ),
                  CalendarDatePicker(
                    initialDate: DateTime.now(), 
                    firstDate: DateTime.now(), 
                    lastDate: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day+7
                    ), 
                    onDateChanged: (dateTime){
                      showTimePicker(
                        context: context, 
                        initialTime: TimeOfDay.now()
                      ).then((value) => setState((){
                        if(value != null)
                          _unsavedTimeInterval = value.format(context);
                      }));
                    }
                  ),
                  Text(
                    _unsavedTimeInterval
                  )
                ],
              ),
            ),
            // ListTile(  // Tipul localului
            //   contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            //   title: Text(
            //     "Tipul localului",
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold
            //     ),
            //   ),
            //   subtitle: Container(
            //     child: Padding(
            //       padding: const EdgeInsets.only(top: 8.0),
            //       child: Wrap(
            //         runSpacing: 7,
            //         spacing: 10,
            //         //textDirection: ,
            //         children: temporaryListOfProfiles.map((e) => 
            //           Container(
            //             height: 30,
            //             width: 120,
            //             decoration: BoxDecoration(
            //               boxShadow: [
            //                 BoxShadow(
            //                   color: Colors.black45, 
            //                   offset: Offset(1.5,1),
            //                   blurRadius: 2,
            //                   spreadRadius: 0.2
            //                 )
            //               ],
            //               color: Colors.orange[600],
            //               borderRadius: BorderRadius.circular(25)
            //             ),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: <Widget>[
            //                 Text(
            //                   e[0].toString() + ": " + e[1].toString(),
            //                   style: TextStyle(
            //                     fontSize: 10,
            //                     fontWeight: FontWeight.bold
            //                   ),
            //                 ),
            //                 SizedBox( // The 'X' icon
            //                   width: 20,
            //                   height: 40,
            //                   child: IconButton(
            //                     padding: EdgeInsets.zero,
            //                     iconSize: 20,
            //                     focusColor: Colors.black,
            //                     //splashColor: Colors.black,
            //                     highlightColor: Colors.black,
            //                     icon: Icon(Icons.close), 
            //                     onPressed: (){
            //                       setState(() {
            //                         temporaryChanges.profile.remove(e[0]);
            //                       });
            //                     }
            //                   ),
            //                 )
            //               ],
            //             ),
            //           )
            //         ).toList(),
            //       ),
            //     )
            //   ),
            // ),
            SizedBox(
              height: 100
            )
          ],
        ),
      ),
    );
  }
}