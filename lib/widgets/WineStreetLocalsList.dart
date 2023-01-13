import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Place_List_profile.dart';

/// A class which renders the list of queried locals
class WineStreetLocals extends StatefulWidget {

  // Used by the DiscountLocals_Page in order to obtain only the Places with Discounts 
  final bool? onlyWithDiscounts;
  WineStreetLocals({this.onlyWithDiscounts});
  @override
  _WineStreetLocalsState createState() => _WineStreetLocalsState();
}

class _WineStreetLocalsState extends State<WineStreetLocals> {

  DateTime today = DateTime.now().toLocal();
  static const List<Map<String, Object>> _discounts = [
    {
      'maxim' : 15,
      'pe_nivel' : [10, 10, 12.5, 14, 14.5, 15]
    },
    {
      'maxim' : 20,
      'pe_nivel' : [12.5, 12.5, 15, 16.5, 18, 20]
    },
    {
      'maxim' : 25,
      'pe_nivel' : [15, 15, 17.5, 20, 22.5, 25]
    },
    {
      'maxim' : 30,
      'pe_nivel': [15, 15, 20, 22.5, 25, 30]
    },
    { 'maxim' : 35,
      'pe_nivel' : [17.5, 17.5, 25, 30, 32.5, 35]
    },
    {
      'maxim' : 40,
      'pe_nivel' : [25, 25, 30, 32.5, 35, 40]
    },
    {
      'maxim' : 45,
      'pe_nivel' : [30, 30, 35, 37.5, 40, 45]
    },
    {
      'maxim' : 50,
      'pe_nivel' : [40, 40, 45, 50, 50, 50]
    },
  ];

  int getDiscountForUser(int maxDiscount){
    _discounts.firstWhere((element) => element['maxim'] as bool);
    return 0;
  }

  double? getMaxDiscountForToday(Place local){

    if(local.discounts != null)
      if(local.discounts![DateFormat('EEEE').format(today).toLowerCase()] != null){
      double maxDiscountToday = 0 ;
      local.discounts![DateFormat('EEEE').format(today).toLowerCase()].forEach((element){
        if(double.parse(element.substring(12,14)) > maxDiscountToday)
          maxDiscountToday = double.parse(element.substring(12,14));
      });
      return maxDiscountToday;
    }
    return null;
  }

  Future<List<Place>>? places;

  void getPlaces(){
    places = queryingService.fetchOnlyDiscounts();
  }

  @override
  void initState() {
    super.initState();
    getPlaces();
  }

  Future refresh(){
    return Future((context as Element).reassemble);
    
  }
 
  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<Place>?>.value(
      initialData: null,
      value: places,
      builder: (context, child){
        print("REBUILD LIST");
        var places  = Provider.of<List<Place>?>(context);
        if(places == null)
          return Center(child: SpinningLogo (),);
        else if(places.length == 0)
          return Center(
            child: Text("Ne pare rau, dar nu exista rezultate.")
          );
          else return Container(
            color: Colors.white,
            //color: Colors.grey[50],
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: places.length,
              itemBuilder: (BuildContext context, int index) {
                Place local = places[index];
                double lengthInMeter = queryingService.getLocalLocation(local.location);
                double lengthInKm = lengthInMeter/1000;
                //print(lengthInMeter.toString() + " KM");
                //PlaceListProfile place;
                PlaceListProfile place = PlaceListProfile(
                  scaffoldContext: context,
                  name: local.name, address: local.address, image: local.image, price: local.cost, discount: getMaxDiscountForToday(local), deals: local.deals,
                  distance: lengthInMeter > 1000 
                  ?  (lengthInKm <100 ? lengthInKm.toInt().toString() 
                  + '.' + ((lengthInMeter/100%10).toInt()).toString(): '99+')
                  :'0.' + ((lengthInMeter/100%10).toInt()).toString()
                  ,onTap: (){
                  Navigator.pushNamed(
                    context,
                    '/third',
                    arguments: [local,widget.onlyWithDiscounts]
                  );
                },
                );
                // return OpenContainer(
                //   closedElevation: 0,
                //   transitionDuration: Duration(milliseconds: 500),
                //   openBuilder: (context, f) => ThirdPage(
                //     local: local,
                //   ),
                //   closedBuilder: (context, f) {
                //     print(lengthInMeter.toString() + " km");
                //     PlaceListProfile place = PlaceListProfile(
                //       scaffoldContext: context,
                //       name: local.name, address: local.address, image: local.image, price: local.cost, discount: getMaxDiscountForToday(local), deals: local.deals,
                //       distance: lengthInMeter > 1000 
                //       ?  (lengthInKm <100 ? lengthInKm.toInt().toString() 
                //       + '.' + ((lengthInMeter/100%10).toInt()).toString(): '99+')
                //       :'0.' + ((lengthInMeter/100%10).toInt()).toString()
                //       ,onTap: f
                //     );
                //     return place;
                //   },
                // );
                return place;
              }
            ),
          );
      }
    );
  }
}