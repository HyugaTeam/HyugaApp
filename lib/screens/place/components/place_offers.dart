import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/place/place_provider.dart';

import 'deal_item_page.dart';

class PlaceOffers extends StatelessWidget {
  const PlaceOffers({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PlacePageProvider>();
    var place = provider.place;
    var items;
    if(place.deals != null)
      items = place.deals!["saturday"].toList();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Oferte",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            height: 130,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (context, index) {
                  return SizedBox(width: 15,);
                },
                itemBuilder: (context, index){
                  return MaterialButton(
                    padding: EdgeInsets.zero,
                    onPressed: (){
                      showModalBottomSheet(
                        context: context, 
                        // elevation: 0,
                        isScrollControlled: true,
                        backgroundColor: Theme.of(context).primaryColor,
                        barrierColor: Colors.black.withOpacity(0.35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                        builder: (context) => Container(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Column( 
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(height: 4, width: 40, margin: EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: Theme.of(context).canvasColor,borderRadius: BorderRadius.circular(30),)),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                child: Container(
                                  color: Theme.of(context).canvasColor,
                                  child: DealItemPopupPage(items[index])
                                )
                              ),
                            ],
                          ),
                        )
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      width: 160,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor,
                        borderRadius: BorderRadius.circular(30)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(items[index]['title'], style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 17),),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(items[index]['threshold'], style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 16,fontWeight: FontWeight.normal),),
                          )
                        ],
                      )
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}