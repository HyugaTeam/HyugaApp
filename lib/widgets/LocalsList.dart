import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:intl/intl.dart';

import 'Place_List_profile.dart';

/// A class which renders the list of queried locals
class Locals extends StatefulWidget {

  // Used by the DiscountLocals_Page in order to obtain only the Places with Discounts 
  final bool? onlyWithDiscounts;
  Locals({this.onlyWithDiscounts});
  @override
  _LocalsState createState() => _LocalsState();
}

class _LocalsState extends State<Locals> {

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

  Future refresh(){
    return Future((context as Element).reassemble);
    
  }
 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Place>?>(
      future: widget.onlyWithDiscounts != true? queryingService.fetch(false) : queryingService.fetchOnlyDiscounts(),
      builder:(context,locals){
        if(!locals.hasData)
          return Center(child: SpinningLogo (),);
        else if(locals.data!.length == 0)
          return Center(
            child: Text("Ne pare rau, dar nu exista rezultate.\nIncearca sa cauti altceva.")
          );
          else return RefreshIndicator(
            displacement: 50,
            onRefresh: refresh,
            child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 5,
              right: 5
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(), 
              itemCount: locals.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Place local = locals.data![index];
                double lengthInKm = queryingService.getLocalLocation(local.location!);
                double lengthInMeter = queryingService.getLocalLocation(local.location!);
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
                 return place;
              }
            )
          ),
        );
      }
    );
  }
}