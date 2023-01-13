import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/config/constants.dart';
import 'package:hyuga_app/models/models.dart';
export 'package:provider/provider.dart';

class EventsPageProvider with ChangeNotifier{
  List<Event> events = [];
  // [
  //   Event(
  //     id: "1",
  //     title: "DJ mix", 
  //     content: 'Vineri, 18 Noiembrie, incepand cu ora 22:00, ne vedem in Kristal CLUB pentru o petrecere in stilul anilor 2000.\nDescopera o seara plina de amintiri, muzica pe care o iubim si un concept fresh by 2k Party #tuceculoareesti #getyourneon \nIa-ti bratara care te reprezinta: single, intr-o relatie sau e complicat si vino sa petrecem pe cele mai tari hituri impreuna cu DJ Mara Ognean, Jorge si DJ Megrov.\nDress code: 2000s fashion inspired\nREZERVARE MASA + alte detalii -\n0736688445\nSee you there!', 
  //     dateCreated: DateTime.now(), 
  //     dateStart: DateTime(2022, 12, 1, 22, 0), 
  //     dateEnd: DateTime(2022, 12, 2, 4, 0), 
  //     name: 'Halloween Party',
  //     organiserName: 'Nostalgia',
  //     location: GeoPoint(44.48105126627104, 26.071378544409477),
  //     locationName: "Casa Presei Libere", 
  //     photoUrl: 'https://dnwp63qf32y8i.cloudfront.net/da95bd742d4fa9f7114cb40200635966f98b4a40', 
  //     // placeRef: FirebaseFirestore.instance.collection("locals_bucharest").doc("martina_ristorante_pizzeria"),
  //     // price: 100,
  //     favourite: false,
  //     ref: FirebaseFirestore.instance.collection("locals_bucharest").doc("martina_ristorante_pizzeria"),
  //   )
  // ];
  List<Event> allEvents = [];
  // [
  //   Event(
  //     id: "2",
  //     title: "DJ mix", 
  //     content: 'Vineri, 18 Noiembrie, incepand cu ora 22:00, ne vedem in Kristal CLUB pentru o petrecere in stilul anilor 2000.\nDescopera o seara plina de amintiri, muzica pe care o iubim si un concept fresh by 2k Party #tuceculoareesti #getyourneon \nIa-ti bratara care te reprezinta: single, intr-o relatie sau e complicat si vino sa petrecem pe cele mai tari hituri impreuna cu DJ Mara Ognean, Jorge si DJ Megrov.\nDress code: 2000s fashion inspired\nREZERVARE MASA + alte detalii -\n0736688445\nSee you there!', 
  //     dateCreated: DateTime.now(), 
  //     dateStart: DateTime(2022, 12, 1, 22, 0), 
  //     dateEnd: DateTime(2022, 12, 2, 4, 0), 
  //     name: 'Halloween Party', 
  //     organiserName: 'Nostalgia', 
  //     location: GeoPoint(44.48105126627104, 26.071378544409477),
  //     locationName: "Casa Presei Libere", 
  //     photoUrl: 'https://dnwp63qf32y8i.cloudfront.net/da95bd742d4fa9f7114cb40200635966f98b4a40', 
  //     // placeRef: FirebaseFirestore.instance.collection("locals_bucharest").doc("martina_ristorante_pizzeria"),
  //     // price: 100,
  //     favourite: false,
  //     ref: FirebaseFirestore.instance.collection("locals_bucharest").doc("martina_ristorante_pizzeria"),
  //   )
  // ];
  bool isLoading = false;
  Map<String, dynamic> activeFilters = {};


  EventsPageProvider(){
    getData();
  }

  Future<void> getData() async{
    _loading();

    activeFilters = {
      // "types": kRestaurantFilters['types']!.map((e) => false).toList(),
      // "ambiences": kRestaurantFilters['ambiences']!.map((e) => false).toList(),
      // "costs": kRestaurantFilters['costs']!.map((e) => false).toList(),
      "sorts": kRestaurantFilters['sorts']!.map((e) => false).toList(),
    };

    var query = await FirebaseFirestore.instance.collection('events')
    // .where('date_end',isGreaterThan: Timestamp.fromDate(DateTime.now().toLocal()))
    .get();
    print(query.docs.length);
    allEvents = query.docs.map((doc) => docToEvent(doc)).toList();
    events = List.from(allEvents);

    notifyListeners();
    
    _loading();
  }

  void updateFavouriteStatus(int index, Event event){
    bool newStatus = !event.favourite!;
    events[index].favourite = newStatus;
    // event.ref.set(
    //   {
    //     "favourite": newStatus
    //   },
    //   SetOptions(merge: true)
    // );

    notifyListeners();
  }

  void filter(
    Map<String, List<bool>> filters, 
    // WrapperHomePageProvider wrapperHomePageProvider
  ) async{
    _loading();

    activeFilters = Map<String, List<bool>>.from(filters);
    
    Map<String, List<String>> finalFilters = {
      // "types" : [], "ambiences" : [], "costs": [], 
      "sorts": []
    };
    kRestaurantFilters.forEach((key, list) {
      for(int i = 0; i < list.length; i++)
      if(filters[key]![i])
        finalFilters[key]!.add(list[i]);
    });
    // List.copyRange(places, 0, allPlaces);
    events = List.from(allEvents);

    // places = allPlaces;

    //events.forEach((element) {print(element.types);});
    
    filters.forEach((key, list) {
      for(int i = 0; i < list.length; i++){
        if(list[i]){
          var value = kRestaurantFilters[key]![i];          
          switch(key){
            // case "types":
            //   events.removeWhere((place) => !place.types!.contains(value));
            // break;
            // case "ambiences":
            //   events.removeWhere((place) => place.ambience != value);
            // break;
            // case "costs":
            //   events.removeWhere((place) => place.cost.toString() != value);
            //   break;
            case "sorts":
              // events.sort((a,b) => a.arrivalTime.difference(a.departureTime).inMinutes - b.arrivalTime.difference(b.departureTime).inMinutes );
            break;
          }
        }
      }
    });

    // markers = await _mapPlacesToMarkers(places);

    notifyListeners();
    _loading();
  }

  void removeFilters() async{
    _loading();
     /// Instantiate active filters with no 'false' for each field
    activeFilters = {
      // "types": kRestaurantFilters['types']!.map((e) => false).toList(),
      // "ambiences": kRestaurantFilters['ambiences']!.map((e) => false).toList(),
      // "costs": kRestaurantFilters['costs']!.map((e) => false).toList(),
      "sorts" : kRestaurantFilters['sorts']!.map((e) => false).toList(),
    };
    /// Reinstantiate displayed places with all places
    events = List.from(allEvents);
    /// Map displayed places to Markers
    // markers = await _mapPlacesToMarkers(places);

    notifyListeners();
    _loading();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }
}