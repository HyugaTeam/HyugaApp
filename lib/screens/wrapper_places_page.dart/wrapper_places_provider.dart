import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/config/constants.dart';
import 'package:hyuga_app/config/paths.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/screens/place/place_page.dart';
import 'package:hyuga_app/screens/place/place_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';
import 'package:intl/intl.dart';
export 'package:provider/provider.dart';

class WrapperPlacesPageProvider with ChangeNotifier{
  List<Place> allPlaces = [];
  List<Place> places = [];
  Set<Marker> markers = {};
  ViewType viewType = ViewType.list;
  bool isLoading = false;
  GoogleMapController? googleMapController;
  WrapperHomePageProvider wrapperHomePageProvider;
  BuildContext context;
  Map<String, dynamic>? city;
  Map<String, dynamic> activeFilters = {};
  bool isSearchBarFocused = false;

  WrapperPlacesPageProvider(this.context, this.city, this.wrapperHomePageProvider){
    getData(context);
  }

  Future<void> getData(BuildContext context) async{
    _loading();

    ///Initialize each filter with false
    activeFilters = {
      "types": kRestaurantFilters['types']!.map((e) => false).toList(),
      "ambiences": kRestaurantFilters['ambiences']!.map((e) => false).toList(),
      "costs": kRestaurantFilters['costs']!.map((e) => false).toList(),
      "sorts": kRestaurantFilters['sorts']!.map((e) => false).toList(),
    };

    var query = await FirebaseFirestore.instance.collection("locals_bucharest")
    .where("city", isEqualTo: city!['id'])
    .orderBy('deals.${DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()}')
    .get();

    // print("query " + query.docs.length.toString());

    allPlaces = query.docs.map((doc) => docToPlace(doc)).toList();


    places = List.from(allPlaces);

    markers = await _mapPlacesToMarkers(places);

    print( "places" + allPlaces.length .toString() );
    _loading();

    notifyListeners();
  }

  void updateFavouriteStatus(int index, Place place){
    bool newStatus = !place.favourite;
    places[index].favourite = newStatus;
    // event.ref.set(
    //   {
    //     "favourite": newStatus
    //   },
    //   SetOptions(merge: true)
    // );

    notifyListeners();
  }

  Future<Set<Marker>> _mapPlacesToMarkers(List<Place> places) async{
    Set<Marker> markers = {};
    places.forEach((place) async{
      var icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(20,20), devicePixelRatio: 0), 
        localAsset("pin"),
      );
      var marker = Marker(
        icon: icon,
        markerId: MarkerId(place.name),
        position: LatLng(place.location.latitude, place.location.longitude), 
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => 
          MultiProvider(
            providers: [
              ChangeNotifierProvider<PlacePageProvider>(create: (context) => PlacePageProvider(place, wrapperHomePageProvider),),
              ChangeNotifierProvider.value(value: wrapperHomePageProvider)
            ],
            builder: (context, child) => PlacePage()
          )
        ))
      );
      markers.add(marker);
    });
    return markers;
  }

  void changeViewType() async{
    _loading();
    if(viewType == ViewType.map)
      viewType = ViewType.list;
    else viewType = ViewType.map;
    notifyListeners();
    _loading();
  }

  void initializeGoogleMapController(GoogleMapController controller){
    googleMapController = controller;

    notifyListeners();
  }

  void updateIsSearchBarFocused(){
    isSearchBarFocused = !isSearchBarFocused;
    
    notifyListeners();
  }

  void filter(
    Map<String, List<bool>> filters, 
    // WrapperHomePageProvider wrapperHomePageProvider
  ) async{
    _loading();

    activeFilters = Map<String, List<bool>>.from(filters);
    
    Map<String, List<String>> finalFilters = {
      "types" : [], "ambiences" : [], "costs": [], 
      "sorts": []
    };
    kRestaurantFilters.forEach((key, list) {
      for(int i = 0; i < list.length; i++)
      if(filters[key]![i])
        finalFilters[key]!.add(list[i]);
    });
    // List.copyRange(places, 0, allPlaces);
    places = List.from(allPlaces);

    // places = allPlaces;

    //tickets.forEach((element) {print(element.types);});
    
    filters.forEach((key, list) {
      for(int i = 0; i < list.length; i++){
        if(list[i]){
          var value = kRestaurantFilters[key]![i];          
          switch(key){
            case "types":
              places.removeWhere((place) => !place.types!.contains(value));
            break;
            case "ambiences":
              // places.removeWhere((place) => place.ambience != value);
            break;
            case "costs":
              places.removeWhere((place) => place.cost.toString() != value);
              break;
            case "sorts":
              // places.sort((a,b) => a.arrivalTime.difference(a.departureTime).inMinutes - b.arrivalTime.difference(b.departureTime).inMinutes );
            break;
          }
        }
      }
    });

    markers = await _mapPlacesToMarkers(places);

    notifyListeners();
    _loading();
  }

  void removeFilters() async{
    _loading();
     /// Instantiate active filters with no 'false' for each field
    activeFilters = {
      "types": kRestaurantFilters['types']!.map((e) => false).toList(),
      "ambiences": kRestaurantFilters['ambiences']!.map((e) => false).toList(),
      "costs": kRestaurantFilters['costs']!.map((e) => false).toList(),
      "sorts" : kRestaurantFilters['sorts']!.map((e) => false).toList(),
    };
    /// Reinstantiate displayed places with all places
    places = List.from(allPlaces);
    /// Map displayed places to Markers
    markers = await _mapPlacesToMarkers(places);

    notifyListeners();
    _loading();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }

}

enum ViewType{
  list,
  map
}