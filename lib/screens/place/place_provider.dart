import 'package:flutter/cupertino.dart';
import 'package:hyuga_app/config/constants.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/services/analytics_service.dart';

class PlacePageProvider with ChangeNotifier{
  Place place;
  Future<Image?>? firstImage;
  Future <Image?>? secondImage;
  Future <Image?>? thirdImage;

  bool? onlyDiscounts;

  PlacePageProvider(this.place, [this.onlyDiscounts]){
    getData();

    ///Added for test
    if(this.onlyDiscounts == null){
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": place.id,
          "place_name": place.name,
          //"place_path": "${g.whereListTranslation[g.selectedWhere]}_${g.whatListTranslation[g.selectedWhere][g.selectedWhat]}_${g.howManyListTranslation[g.selectedHowMany]}_${g.ambianceListTranslation[g.selectedAmbiance]}_${g.areaListTranslation[g.selectedArea]}"
        }
      ).then((value) => print(place.id!+place.name!));
    }
    else{
      AnalyticsService().analytics.logEvent(
        name: 'view_place',
        parameters: {
          "place_id": place.id,
          "place_name": place.name,
          "place_path": "only_discounts"
        }
      );
    }
  }

  Future<void> getData() async{
    if(place.deals != null)
      if(place.deals![kWeekdaysFull.keys.toList()[_selectedWeekday-1].toLowerCase()] != null)
        isOfferExpanded = widget.place!
          .deals![kWeekdaysFull.keys.toList()[_selectedWeekday-1].toLowerCase()]
          .map<bool>((key) => false).toList();
    print(isOfferExpanded);
    firstImage = _getFirstImage();
    secondImage = _getSecondImage();
    thirdImage = _getThirdImage();
  }
}