import 'package:authentication/authentication.dart';
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

class PlacesPageProvider with ChangeNotifier{
  List<Place> allPlaces = [];
  List<Place> places = [];
  List<Place> popularPlaces = [];
  List<Place> bestOfferPlaces = [];
  List<Place> favouritePlaces = [];
  List<Place> searchedPlaces = [];
  Set<Marker> markers = {};
  ViewType viewType = ViewType.list;
  bool isLoading = false;
  GoogleMapController? googleMapController;
  WrapperHomePageProvider wrapperHomePageProvider;
  BuildContext context;
  Map<String, dynamic>? city;
  Map<String, dynamic> activeFilters = {};
  bool isSearchBarFocused = false;
  String? searchKeyword;
  PageController pageController = PageController();
  TextEditingController textEditingController = TextEditingController();
  FocusNode textFieldFocusNode = FocusNode();
  int nextPageIndex = 0;

  PlacesPageProvider(this.context, this.city, this.wrapperHomePageProvider){
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
    .where("partner", isEqualTo: true)
    .orderBy('deals.${DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()}')
    .get();

    // print("query " + query.docs.length.toString());

    allPlaces = query.docs.map((doc) => docToPlace(doc)).toList();


    places = List.from(allPlaces);

    /// Fetch popular places
    popularPlaces = List.from(allPlaces);
    var popularPlacesCount = <Place, int> {};
    for(int i = 0; i < popularPlaces.length; i ++) {
      var placeDoc = await FirebaseFirestore.instance.collection('locals_bucharest').doc(allPlaces[i].id).get();
      var count = 0;
      if(placeDoc.data()!['manager_reference'] != null) {
        var query = await placeDoc.data()!['manager_reference'].collection("reservations").get();
        count = query.docs.length;
      }
      popularPlacesCount.addAll({popularPlaces[i]: count});
    }
    print(popularPlaces.length);
    popularPlaces.sort((a,b) {
      return popularPlacesCount[b]! - popularPlacesCount[a]!;
    });

    /// Fetch best offer places
    bestOfferPlaces = List.from(allPlaces);
    bestOfferPlaces.sort((a,b){
      var aDeals = a.deals![DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()];
      var bDeals = b.deals![DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()];
      int aThreshold = 0;
      int bThreshold = 0;
      aDeals.forEach((deal){
        int threshold = 0;
        try{
          threshold = int.parse(deal['threshold'].substring(0, deal['threshold'].indexOf(" ")));
        }
        catch(error){
          threshold = 0;
        }
        aThreshold += threshold;
      });
      bDeals.forEach((deal){
        int threshold = 0;
        try{
          threshold = int.parse(deal['threshold'].substring(0, deal['threshold'].indexOf(" ")));
        }
        catch(error){
          threshold = 0;
        }
        bThreshold += threshold;
      });
      print("${a.name} $aThreshold ${b.name} $bThreshold");
      return bThreshold - aThreshold;
    });

    /// Fetch favourite places
    await FirebaseFirestore.instance.collection('users').doc('${Authentication.auth.currentUser!.uid}').collection('favourite_places').get().then((places){
      favouritePlaces = places.docs.map(docToPlace).toList();
    });

    markers = await _mapPlacesToMarkers(places);

    print( "places" + allPlaces.length .toString() );
    _loading();

    notifyListeners();
  }

  void updateNextPageIndex(int index){
    nextPageIndex = index;
    
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

  void updateSearchKeyword(String? value){
    searchKeyword = value;

    notifyListeners();
  }

  void updateIsSearchBarFocused(){
    isSearchBarFocused = !isSearchBarFocused;
  }

  void initializeGoogleMapController(GoogleMapController controller){
    googleMapController = controller;

    notifyListeners();
  }

  void pushFilteredPlaces(String? filter){
    switch(filter){
      case null:
      break;
      case 'favourite':
        removeFilters();
        this.filter(
          {
              "types": kRestaurantFilters['types']!.map((e) => false).toList(), 
              "ambiences" : kRestaurantFilters['ambiences']!.map((e) => false).toList(), 
              "costs": kRestaurantFilters['costs']!.map((e) => false).toList() , 
              "sorts": kRestaurantFilters['sorts']!.map((e){ return e == "favourite" ? true : false; }).toList()
            }, 
        );
      break;
      case 'distance':
        removeFilters();
        this.filter(
          {
              "types": kRestaurantFilters['types']!.map((e) => false).toList(), 
              "ambiences" : kRestaurantFilters['ambiences']!.map((e) => false).toList(), 
              "costs": kRestaurantFilters['costs']!.map((e) => false).toList() , 
              "sorts": kRestaurantFilters['sorts']!.map((e){ return e == "distance" ? true : false; }).toList()
            }, 
        );
      break;
      case 'best-offer':
        removeFilters();
        this.filter(
          {
              "types": kRestaurantFilters['types']!.map((e) => false).toList(), 
              "ambiences" : kRestaurantFilters['ambiences']!.map((e) => false).toList(), 
              "costs": kRestaurantFilters['costs']!.map((e) => false).toList() , 
              "sorts": kRestaurantFilters['sorts']!.map((e){ return e == "best-offer" ? true : false; }).toList()
            }, 
        );
      break;
      case 'popular':
        removeFilters();
        this.filter(
          {
            "types": kRestaurantFilters['types']!.map((e) => false).toList(), 
            "ambiences" : kRestaurantFilters['ambiences']!.map((e) => false).toList(), 
            "costs": kRestaurantFilters['costs']!.map((e) => false).toList() , 
            "sorts": kRestaurantFilters['sorts']!.map((e){ return e == "popular" ? true : false; }).toList()
          }, 
        );
      break;
    }

    pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);

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
            case "sorts":{
              sortPlaces(value);
            }
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

  void updateSearchedPlaces(){
    _loading();

    searchedPlaces = List.from(places);

    if(searchKeyword != null && searchKeyword!.length != 0)
      searchedPlaces.retainWhere((place) {
        return place.name.toLowerCase().contains(searchKeyword!.toLowerCase());
      });
    _loading();
    notifyListeners();
  }

  Future<void> sortPlaces(String value) async{
    switch(value){
      case "distance":
        // places.sort((a,b) => a.arrivalTime.difference(a.departureTime).inMinutes - b.arrivalTime.difference(b.departureTime).inMinutes );
      break;
      case "best-offer":
        places.sort((a,b){
          var aDeals = a.deals![DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()];
          var bDeals = b.deals![DateFormat('EEEE').format(DateTime.now().toLocal()).toLowerCase()];
          int aThreshold = 0;
          int bThreshold = 0;
          aDeals.forEach((deal){
            int threshold = 0;
            try{
              threshold = int.parse(deal['threshold'].substring(0, deal['threshold'].indexOf(" ")));
            }
            catch(error){
              threshold = 0;
            }
            aThreshold += threshold;
          });
          bDeals.forEach((deal){
            int threshold = 0;
            try{
              threshold = int.parse(deal['threshold'].substring(0, deal['threshold'].indexOf(" ")));
            }
            catch(error){
              threshold = 0;
            }
            bThreshold += threshold;
          });
          print("${a.name} $aThreshold ${b.name} $bThreshold");
          return bThreshold - aThreshold;
        });
      break;
      case "popular":
        var popularPlacesCount = <Place, int> {};
        for(int i = 0; i < places.length; i ++) {
          var placeDoc = await FirebaseFirestore.instance.collection('locals_bucharest').doc(places[i].id).get();
          var count = 0;
          if(placeDoc.data()!['manager_reference'] != null) {
            var query = await placeDoc.data()!['manager_reference'].collection("reservations").get();
            count = query.docs.length;
          }
          popularPlacesCount.addAll({popularPlaces[i]: count});
        }
        places.sort((a,b) {
          return popularPlacesCount[b]! - popularPlacesCount[a]!;
        });
      break;
      case "favourite":
      break;
    }

    notifyListeners();
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