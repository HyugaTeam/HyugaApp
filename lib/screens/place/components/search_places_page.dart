import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/place/place_page.dart';
import 'package:hyuga_app/screens/place/place_provider.dart';
import 'package:hyuga_app/screens/places/components/empty_list.dart';
import 'package:hyuga_app/screens/places/places_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';

class SearchPlacesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PlacesPageProvider>();
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    return WillPopScope(
      onWillPop: () async{
        provider.pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        provider.updateNextPageIndex(0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Căutare "${provider.searchKeyword}"',),
                provider.searchedPlaces.length != 0
                ? Text("${provider.searchedPlaces.length} " + (provider.searchedPlaces.length == 1 ? "rezultat" : "rezultate"), style: Theme.of(context).textTheme.labelMedium)
                : Container(),
              ],
            ),
          ),
          leadingWidth: 80,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
              radius: 40,
              child: IconButton(
                // alignment: Alignment.centerRight,
                color: Theme.of(context).colorScheme.secondary,
                //padding: EdgeInsets.symmetric(horizontal: 20),
                onPressed: () => provider.pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut),
                icon: Image.asset(localAsset("left-arrow"), width: 18, color: Theme.of(context).primaryColor,)
              ),
            ),
          ),
        ),
        body: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          itemCount: provider.searchedPlaces.length == 0 ? 1 : provider.searchedPlaces.length,
          separatorBuilder: (context, index) => SizedBox(height: 30),
          itemBuilder: (context, index){
            if(provider.searchedPlaces.length == 0)
              return EmptyList();
            else{
              var place = provider.searchedPlaces[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                  create: (_) => PlacePageProvider(place, wrapperHomePageProvider),
                  child: PlacePage()
                ))),
                child: Container(
                  height: 310,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey,
                    image: DecorationImage(
                      image: NetworkImage(place.profileImageURL),
                      fit: BoxFit.cover
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        spreadRadius: 10,
                        blurRadius: 10,
                        offset: const Offset(0, 0)
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Align( /// Text box
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding( /// Place's name
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  place.name, 
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              Row( /// Place's address
                                children: [
                                  CircleAvatar(
                                    child: Icon(
                                      Icons.place, 
                                      size: 18,
                                      // color: Colors.grey[500],
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    backgroundColor: Theme.of(context).highlightColor, radius: 13,
                                  ),
                                  SizedBox(width: 10,),
                                  Text(place.address != null && place.address != "" ? place.address! : "Adresă", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.normal))
                                ],
          
                              ),
                              Row( /// Place's types
                                children: [
                                  CircleAvatar(
                                    child: Icon(
                                      Icons.food_bank, 
                                      size: 17, 
                                      // color: Colors.grey[500]
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    backgroundColor: Theme.of(context).highlightColor, radius: 13,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    place.types!.sublist(0,2).map((e) => kTypes[e]).toString().substring(1, place.types!.sublist(0,2).toString().length - 1)
                                  )
                                ])
                              // Column(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   crossAxisAlignment: CrossAxisAlignment.end,
                                  //   children: [
                                  //     Row(
                                  //       children: [
                                  //         Text(
                                  //           place.dateEnd != null
                                  //           ? "${formatDateToHourAndMinutes(place.dateStart)} - ${formatDateToHourAndMinutes(place.dateEnd)}"
                                  //           : "${formatDateToHourAndMinutes(place.dateStart)}", 
                                  //           style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
                                  //         ),
                                  //         SizedBox(width: 5,),
                                  //         Icon(FontAwesomeIcons.solidClock, color: Colors.grey[500], size: 16),
                                  //       ],
                                  //     ),
                                  //   ],
                                  // )
                              // Text.rich(TextSpan( /// place location
                              //   children: [
                              //     WidgetSpan(child: Icon(Icons.place, color: Colors.grey[500])),
                              //     WidgetSpan(child: SizedBox(width: 5,)),
                              //     TextSpan(text: place.locationName, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)),
                              //   ]
                              // )),
                            ],
                          ),
                        ),
                      ),
                      // Positioned( /// Date
                      //   top: 20, 
                      //   left: 20, 
                      //   child: Container(
                      //     alignment: Alignment.center,
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(15)
                      //     ),
                      //     height: 65,
                      //     width: 65,
                      //     child: Text.rich(TextSpan(
                      //       children: [
                      //         TextSpan(
                      //           text: "${formatDateToShortMonth(place.dateStart)}\n",
                      //           style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.tertiary),
                      //         ),
                      //         TextSpan(
                      //           text: "${place.dateStart.day}",
                      //           style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.primary),
                      //         )
                      //       ] 
                      //     ),textAlign: TextAlign.center,),
                      //   )
                      // ),
                      Positioned( /// Favourite
                        top: 20, 
                        right: 20, 
                        child: GestureDetector(
                          onTap: (){
                            provider.updateFavouriteStatus(index, place);
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // color: Colors.white,
                              // borderRadius: BorderRadius.circular(15)
                            ),
                            // height: 65,
                            // width: 65,
                            child: CircleAvatar(
                              radius: 23,
                              // backgroundColor: Colors.transparent,
                              backgroundColor: Colors.white,
                              child: place.favourite
                              ? Image.asset(localAsset("favourite-solid"), width: 25, color: Colors.red)
                              // : Image.asset(localAsset("favourite-solid"), width: 25, color: Colors.white)
                              : Image.asset(localAsset("favourite"), width: 25, color: Colors.black),
                            )
                          ),
                        )
                      )
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}