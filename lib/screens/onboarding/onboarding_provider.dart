import 'package:flutter/cupertino.dart';
export 'package:provider/provider.dart';

class OnboardingPageProvider with ChangeNotifier {
  PageController pageController = PageController();
  int pageIndex = 0;

  void updateSelectedPageIndex(int index){
    pageIndex = index;

    notifyListeners();
  }

  var pages = [
    {
      "image": "log-in",
      "title": "Bun venit în comunitatea Wine Street!",
      "content": ""
    },
    {
      "image": "discount",
      "title": "Petreci mai ieftin",
      "content": "Cu Wine Street salvezi bani de fiecare dată când ieși în oraș!"
    },
    {
      "image": "dine-out",
      "title": "Economisește bani la restaurant",
      "content": "Fă o rezervare la restaurant și primești o sticlă de vin gratuit la consumația minimă."
    },
    {
      "image": "event",
      "title": "Cumpără bilete mai ieftin la evenimente",
      "content": "Cumpără bilete mai ieftin la orice concert și eveniment."
    },
    {
      "image": "bookings",
      "title": "Rezervări și bilete în aplicație",
      "content": "Poți vizualiza și administra rezervările și biletele tale direct în aplicație "
    },
  ];
}
