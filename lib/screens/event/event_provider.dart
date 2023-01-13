import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
export 'package:provider/provider.dart';

class EventPageProvider with ChangeNotifier{
  Event event;
  bool isDescriptionExpanded = false;
  ScrollController scrollController = ScrollController();
  double dateOpacity = 0;

  EventPageProvider(this.event){
    scrollController.addListener(() {
      if(scrollController.offset < 80)
        dateOpacity = 0;
      else 
          if(scrollController.offset >= 80 && scrollController.offset< 100)
            dateOpacity = scrollController.offset * 0.045 - 3.5;
          else dateOpacity = 1;
      notifyListeners();
    });
  }

  void updateIsDescriptionExpanded(){
    isDescriptionExpanded = !isDescriptionExpanded;

    notifyListeners();
  }
}