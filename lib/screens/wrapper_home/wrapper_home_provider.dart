import 'package:authentication/authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/screens/events/events_page.dart';
import 'package:hyuga_app/screens/events/events_provider.dart';
import 'package:hyuga_app/screens/history/history_page.dart';
import 'package:hyuga_app/screens/history/history_provider.dart';
import 'package:hyuga_app/screens/places/places_page.dart';
import 'package:hyuga_app/screens/places/places_provider.dart';
import 'package:hyuga_app/screens/profile/profile_page.dart';
import 'package:hyuga_app/screens/profile/profile_provider.dart';
import 'package:location/location.dart';
export 'package:provider/provider.dart';

class WrapperHomePageProvider with ChangeNotifier{

  BuildContext context;
  int selectedScreenIndex = 0;
  List<Widget> screens = [];
  bool isLoading = false;
  Map<String, dynamic>? city;
  Map<String, dynamic>? configData;
  UserProfile? currentUser; 
  List<String>? favouritePlaces;
  LocationData? currentLocation;

  List<BottomNavigationBarItem> screenLabels = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      label: "Restaurante",
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: ImageIcon(AssetImage(localAsset("restaurant")), size: 20,)
      )
    ),
    BottomNavigationBarItem(
      label: "Evenimente",
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: FaIcon(FontAwesomeIcons.calendar, size: 20),
      )
    ),
    BottomNavigationBarItem(
      label: "Istoric",
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 20,),
      )
    ),
    BottomNavigationBarItem(
      label: "Profil",
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Icon(Icons.person, size: 20),
      )
    ),
  ];

  WrapperHomePageProvider(this.context){
    getData(context);
  }

  Future<void> getData(BuildContext context) async{
    _loading();

    getLocation();

    ///Get 'currentUser' as UserProfile (with full data from both FirebaseAuth and Cloud Firestore)
    currentUser = await userToUserProfile(context.read<User?>());

    ///Get the configuration data from Cloud Firestore (such as available cities)
    var query = FirebaseFirestore.instance.collection("config").doc("config");
    var doc = await query.get();
    configData = doc.data(); 
    city = configData!['cities'][configData!['main_city']];
    city!.addAll({"id": configData!['main_city']});

    ///Get user's favourite places
    await FirebaseFirestore.instance.collection('users').doc(Authentication.auth.currentUser!.uid).collection('favourite_places')
    .get().
    then((query) => favouritePlaces = query.docs.map((doc) => doc.id).toList());

    screens = <Widget>[
      // HomeMapPage(),
      ChangeNotifierProvider(
        create: (_) => PlacesPageProvider(context, city, this),
        child: PlacesPage()
      ),
      ChangeNotifierProvider(
        create: (_) => EventsPageProvider(),
        child: EventsPage()
      ),
      ChangeNotifierProvider(
        create: (_) => HistoryPageProvider(),
        child: HistoryPage()
      ),
      ChangeNotifierProvider(
        create: (_) => ProfilePageProvider(),
        child: ProfilePage(),
      )
    ];

    _loading();
    notifyListeners();
  }
  void updateSelectedScreenIndex(int index){
    if(Authentication.auth.currentUser!.isAnonymous && (index == 2 || index == 3))
      showCupertinoDialog(
        context: context,
        barrierDismissible: true, 
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 18),
          title: Center(
            child: Container(
              child: index == 2
              ? Text("Pentru a vizualiza istoricul, trebuie să fiți logat.", textAlign: TextAlign.center,)
              : Text("Pentru a vizualiza profilul, trebuie să fiți logat.", textAlign: TextAlign.center,),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: Text(
                "Log In"
              ),
              onPressed: () {
                Navigator.pop(context);
                Authentication.signOut();
              }
            ),
          ],
      ));
    else selectedScreenIndex = index;

    notifyListeners();
  }

  /// Asks for permissions and gets the location for the user
  Future<void> getLocation() async{
    var location = new Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if(!serviceEnabled){
      serviceEnabled = await location.requestService();
      if(!serviceEnabled)
        return;
    }
    
    permissionGranted = await location.hasPermission();
    if(permissionGranted == PermissionStatus.denied || permissionGranted == PermissionStatus.deniedForever){
      permissionGranted = await location.requestPermission();
      if(permissionGranted == PermissionStatus.denied || permissionGranted == PermissionStatus.deniedForever)
        return;
    }

    currentLocation = await location.getLocation();

    notifyListeners();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }
}