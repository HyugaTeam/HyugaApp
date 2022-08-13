import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/profile_image_hero.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;



class EditorPage extends StatefulWidget {

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {  

  bool areThereChanges = false; // adds an UI interaction whenever a field is changed
  ManagedLocal? temporaryChanges;
  ManagedLocal? unchangedData;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
  Map<String,dynamic>? changesMap;
  XFile? _unsavedProfileImage;
  String _unsavedProfileImagePath = "";

  /// A method which builds the TextController for 'Name' & 'DeTscription' fields
  TextEditingController? buildTextController(String field){
    TextEditingController? textController;
    if(field == 'name'){
      textController = new TextEditingController(
        text: temporaryChanges != null? (temporaryChanges!.name != null? temporaryChanges!.name : ''): ''
      );
      // textController.addListener(() {
      //   setState(() {
      //     areThereChanges = true;
      //     temporaryChanges.name = textController.value.text;
      //   });
      // });
    }
    if(field == 'description'){
      textController = new TextEditingController(
        text: temporaryChanges != null? (temporaryChanges!.description != null? temporaryChanges!.description : ''): ''
      );
      // textController.addListener(() {
      //   setState(() {
      //     areThereChanges = true;
      //     temporaryChanges.description = textController.value.text;
      //   });
      // });
    }
    return textController;
  }
  // Pops a dialog which shows the user the changes
  Future showChanges(){
    return showModalBottomSheet(context: context, builder: (context) => 
      Scaffold(
        //key: _scaffoldKey,
        body: Builder(
          builder:(context)=> Container(
            height: MediaQuery.of(context).size.height*0.8,
            child: ListView(
              children: <Widget>[
                ListTile(title: Text("Schimbari:")),
                temporaryChanges!.name != unchangedData!.name 
                  ? Column(
                    children: <Widget>[
                      Text("Nume vechi:", style: TextStyle(color: Colors.red),maxLines: 10,),
                      Text(unchangedData!.name!),
                      Text("Nume nou:", style: TextStyle(color: Colors.green),maxLines: 10,),
                      Text(temporaryChanges!.name!),
                    ],
                  )
                  : Container(),
                  temporaryChanges!.description != unchangedData!.description 
                  ? Column(
                    children: <Widget>[
                      Text("Descriere veche:", style: TextStyle(color: Colors.red),maxLines: 10,),
                      Text(unchangedData!.description!),
                      Text("Descriere noua:", style: TextStyle(color: Colors.green),maxLines: 10,),
                      Text(temporaryChanges!.description!),
                    ],
                  )
                  : Container(),
                  temporaryChanges!.capacity != unchangedData!.capacity 
                  ? Column(
                    children: <Widget>[
                      Text("Capacitate veche:", style: TextStyle(color: Colors.red),maxLines: 10,),
                      Text(unchangedData!.capacity.toString()),
                      Text("Capacitate noua:", style: TextStyle(color: Colors.green),maxLines: 10,),
                      Text(temporaryChanges!.capacity.toString()),
                    ],
                  )
                  : Container(),
                RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: Text("Salveaza"),
                  onPressed: (){
                    showDialog(context: context, builder: (context) =>
                      AlertDialog(
                        title: Center(child: Text("Esti sigur?"),),
                        actions: <Widget>[
                          RaisedButton(
                            child: Text("Da"),
                            onPressed: (){
                              Navigator.of(context).pop(true);
                            }
                          ),
                          RaisedButton(
                            child: Text("Nu"),
                            onPressed: (){
                              Navigator.of(context).pop(false);
                            }
                          ),
                        ],
                      )
                    ).then((value){
                      if(value){
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: FutureBuilder(
                              future: saveChanges(temporaryChanges!),
                              builder: (context,complete){
                                if(!complete.hasData)
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Se salveaza..."),
                                      CircularProgressIndicator(),
                                    ],
                                  );
                                else
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Gata!"),
                                      FaIcon(FontAwesomeIcons.check)
                                    ],
                                  );
                              }
                            )
                          )
                        );
                      }
                    });
                  }
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  Future<void> saveChanges(ManagedLocal place) async{
    FirebaseFirestore _db = FirebaseFirestore.instance;
    DocumentReference placeRef = _db.collection('locals_bucharest').doc(place.id);
    
    placeRef.set(
      {
        'name': place.name,
        'description': place.description,
        'capacity': place.capacity
      },
      SetOptions(
        merge: true
      )
    );
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference photoRef = storage.ref().child('photos/europe/bucharest/${place.id}/${place.id}'+'_profile.jpg');
    if(_unsavedProfileImage != null)
      photoRef.putFile(File(_unsavedProfileImage!.path));
    
  }

  @override
  Widget build(BuildContext context) {
    
    unchangedData = Provider.of<AsyncSnapshot<ManagedLocal>>(context).data; // Used to compare with the changed properties
    temporaryChanges = Provider.of<AsyncSnapshot<ManagedLocal>>(context).data; // The actual changed properties
    List<List<dynamic>> temporaryListOfProfiles = <List<dynamic>>[]; // NOT IN USE
    temporaryChanges!.profile!.forEach((key, value) { temporaryListOfProfiles.add([key,value]); }); // NOT IN USE

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 200,
        height: 40,
        child: FloatingActionButton(
          backgroundColor: areThereChanges == false ? Theme.of(context).primaryColor: Colors.orange[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          onPressed: (){
            if(areThereChanges != true){
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Nu sunt schimbari!"),
                )
              );
            
            }
            else{
              showChanges();
            }
          },
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
                    onChanged: (name){
                        areThereChanges = true;
                        temporaryChanges!.name = name;
                    },
                    controller: buildTextController('name'),
                    onSubmitted: (String changedName) => setState((){
                      print(areThereChanges);
                      areThereChanges = true;
                      temporaryChanges!.name = changedName;
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
                    maxLength: 400,
                    onChanged: (description){
                        areThereChanges = true;
                        temporaryChanges!.description = description;
                    },
                    controller: buildTextController('description'),
                    onSubmitted: (String changedDescription) => setState((){
                      print(areThereChanges);
                      areThereChanges = true;
                      temporaryChanges!.description = changedDescription;
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
                subtitle: Container(
                  padding: EdgeInsets.only(right : 30),
                  child: RaisedButton.icon(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    icon: Icon(Icons.person, color: Theme.of(context).backgroundColor, size: 30,),
                    label: Text(
                      temporaryChanges!.capacity == null? "" : temporaryChanges!.capacity.toString(),
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
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey[300]
                                ),
                                alignment: Alignment.center,
                                height: 500,
                                width: 300,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                                child: Column(
                                  children: <Widget>[
                                    ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: availableCapacities.length,
                                      itemBuilder: (context,index){
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: MaterialButton(
                                            elevation: 20,
                                            color: Theme.of(context).primaryColor,
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
                          temporaryChanges!.capacity = int.tryParse(value.toString().substring(0,1))!+1;
                        print(temporaryChanges!.capacity);
                      })),
                  ),
                )
              ),
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
                            future: queryingService.getImage(temporaryChanges!.id),
                            builder: (context,image){
                              if(!image.hasData)
                                return Container(
                                  width: 200,
                                  height: 200,
                                  child: Container(),
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
                                color: Theme.of(context).primaryColor
                              ),
                              onPressed: () async{
                                XFile? _image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                if(_image != null){
                                  setState(() {
                                    areThereChanges = true;
                                    _unsavedProfileImage = _image;
                                    _unsavedProfileImagePath = _image.path;
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
              SizedBox(
                height: 100
              )
            ],
          ),
        ),
    );
  }
}