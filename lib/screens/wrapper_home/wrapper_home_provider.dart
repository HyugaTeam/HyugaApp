import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/screens/authentication/authentication_provider.dart';
import 'package:hyuga_app/screens/events/events_page.dart';
import 'package:hyuga_app/screens/events/events_provider.dart';
import 'package:hyuga_app/screens/history/history_page.dart';
import 'package:hyuga_app/screens/history/history_provider.dart';
import 'package:hyuga_app/screens/main/home_map.dart';
import 'package:hyuga_app/screens/profile/profile_page.dart';
import 'package:hyuga_app/screens/profile/profile_provider.dart';
export 'package:provider/provider.dart';

class WrapperHomePageProvider with ChangeNotifier{

  BuildContext context;
  int selectedScreenIndex = 0;
  List<Widget> screens = [];
  bool isLoading = false;

  List<BottomNavigationBarItem> screenLabels = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      label: "Restaurante",
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: FaIcon(FontAwesomeIcons.percentage, size: 20,),
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
        child: FaIcon(FontAwesomeIcons.history, size: 20,),
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

  void getData(BuildContext context){
    _loading();

    screens = <Widget>[
      HomeMapPage(),
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
  }
  void updateSelectedScreenIndex(int index){
    selectedScreenIndex = index;

    notifyListeners();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }
}