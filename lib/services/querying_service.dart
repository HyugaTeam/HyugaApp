import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/models/locals/local.dart';

class QueryService{
  // Converts a map of Firebase Locals to OUR Locals
  List<Local> toLocal(var localsMap){
      List<Local> placesList = [];
      for(int i = 0; i < localsMap.length; i++){
        Local newLocal = Local(
          name: localsMap[i]['name'],
          imageUrl: localsMap[i]['imageUrl'],
          description: localsMap[i]['description'],
          location: localsMap[i]['location']
        );
        placesList.add(newLocal);
      }
      return placesList;
  }


  // Queries by the 'HowMany' and 'Ambiance' fields
  Future <QuerySnapshot> getDataByHowManyAndAmbiance() {
    
    String selectedAmbiance; 
    int selectedHowMany;
    
    switch (g.selectedAmbiance) {
      case 0:
        selectedAmbiance = 'c';
        break;
      case 2:
        selectedAmbiance = 'sf';
        break;
      default: selectedAmbiance = null;
    }

    switch (g.selectedHowMany) {
      case 0:
        selectedHowMany = 1;
        break;
      case 1:
        selectedHowMany = 2;
        break;
      case 2:
        selectedHowMany = 4;
        break;
      case 3:
        selectedHowMany = 6;
        break;
      default: selectedHowMany = 9;
    }
    
    if(selectedAmbiance != null)
      return Firestore.instance.collection('locals_bucharest')
          .where('ambiance',isEqualTo: selectedAmbiance)
          //.where('score.lemonade',isGreaterThan: null)///////////////
          .where('capacity',isGreaterThanOrEqualTo: selectedHowMany)
          .getDocuments();
    else
      return Firestore.instance.collection('locals_bucharest')
          .where('capacity',isGreaterThanOrEqualTo: selectedHowMany)
          .getDocuments();
  }

  //Queries data from the specific collection (by 'What' criteria)
  Future<QuerySnapshot> getDataByWhat(String collectionName){
    collectionName = collectionName.toLowerCase();
    return Firestore.instance
    .collection('_$collectionName').orderBy('score',descending: true)
    .getDocuments();
  }

  // Handles the whole process of querying
  void queryForLocals() async{
    
    var localsMap = [];
    QuerySnapshot queriedSnapshotByWhat = await getDataByWhat(g.whatList[g.selectedWhere][g.selectedWhat]);
    List<String> listOfQueriedDocuments = [];  // a list of the ID's from the query
    
    for(int i = 0 ; i < queriedSnapshotByWhat.documents.length ; i++){
      listOfQueriedDocuments.add(queriedSnapshotByWhat
                                .documents[i].documentID);
    }// creates a list of IDs from the collection queried by 'What'
    Set<String> queriedDocumentsByWhat = listOfQueriedDocuments.toSet();
  
    
    // A snapshot of the documents ('Ambiance' and 'How Many')
    QuerySnapshot queriedSnapshotByAmbAndHM = await getDataByHowManyAndAmbiance();
    listOfQueriedDocuments.clear();
    for(int i = 0 ; i < queriedSnapshotByAmbAndHM.documents.length ; i++){
      listOfQueriedDocuments.add(queriedSnapshotByAmbAndHM
                                .documents[i].documentID);
    }// creates a list of IDs from the collection queried by 'Amb and HM'
    Set<String> queriedDocumentsByAmbAndHM = listOfQueriedDocuments.toSet();
    
    listOfQueriedDocuments.clear();
    listOfQueriedDocuments = 
    queriedDocumentsByAmbAndHM.intersection(queriedDocumentsByWhat).toList();
    for(int i = 0 ; i < listOfQueriedDocuments.length; i++){
        var db = await Firestore.instance
                .collection('locals_bucharest')
                .document(listOfQueriedDocuments[i])
                .get();
        localsMap.add(db.data);
    }
    List<Local> placesList = toLocal(localsMap);
    print(localsMap);
  }

}