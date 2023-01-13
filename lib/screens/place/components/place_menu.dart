import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/place/place_provider.dart';

import 'menu_item_page.dart';

class PlaceMenu extends StatelessWidget {
  const PlaceMenu({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PlacePageProvider>();
    var place = provider.place;
    var items = [];
    ///TODO: replace items = [] with the real menu
    // if(place.menu != null)
    //   items = place.menu['items'].toList();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Meniu",
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
                                  child: MenuItemPopupPage(items[index])
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(items[index]['title'], style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(items[index]['price'], style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18,fontWeight: FontWeight.normal),),
                          )
                        ],
                      )
                    ),
                  );
                  // return ChoiceChip(
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  //   side: BorderSide(width: 1, color: Theme.of(context).primaryColor),
                  //   backgroundColor:Colors.grey[200],
                  //   selectedColor: Theme.of(context).primaryColor,
                  //   labelPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                  //   selected: index == provider.selectedCategoryIndex,
                  //   label: Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Text(
                  //        categories[index],
                  //       ),
                  //       // Text(
                  //       //   currentTime.add(Duration(days: index)).day.toString() 
                  //       //   + ' ' +
                  //       //   DateFormat('MMMM').format(currentTime.add(Duration(days: index))).substring(0,3),
                  //       // )
                  //     ],
                  //   ),
                  //   onSelected: (selected){
                  //     // provider.selectDay(index);
                  //     // _dayScrollController!.animateTo(
                  //     //   (index-1)*93.toDouble(),
                  //     //   duration: Duration(milliseconds: 500), 
                  //     //   curve: Curves.ease
                  //     // );
                  //   },
                  // );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}