import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/place/place_page.dart';
import 'package:hyuga_app/screens/place/place_provider.dart';
import 'package:hyuga_app/screens/places/places_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';

class PlacesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    var provider = context.watch<PlacesPageProvider>();
    var places = provider.places;
    var popularPlaces = provider.popularPlaces;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text("Restaurante",),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () {
                provider.updateNextPageIndex(0);
                provider.pushFilteredPlaces(null);
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 15),
                // width: 100,
                decoration: BoxDecoration(
                  // color: Theme.of(context).highlightColor,
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Row(
                  children: [
                    Text(
                      "Vezi toate", 
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        // color: Theme.of(context).primaryColor),
                        color: Theme.of(context).canvasColor,
                        // fontWeight: FontWeight.normal
                      )
                    ),
                    SizedBox(width: 10,),
                    Icon(Icons.arrow_forward_ios, size: 15, color: Theme.of(context).canvasColor,)
                  ],
                ),
              ),
            ),
          )
          // TextButton(
          //   style: Theme.of(context).textButtonTheme.style!.copyWith(
          //     padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          //     backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).highlightColor)
          //   ),
          //   onPressed: (){},
          //   child: Text("Vezi toate", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).primaryColor),),
          // )
        ],
        // actions: [
        //   // Padding(
        //   //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //   //   child: CircleAvatar(
        //   //     backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
        //   //     child: Image.asset(localAsset("more"), width: 22, color: Theme.of(context).primaryColor,),
        //   //     radius: 30,
        //   //   ),
        //   // ),
        //   Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 20.0),
        //     child: IconButton(
        //       icon: Stack(
        //         children: [
        //           Center(child: Image.asset(localAsset('filter'), width: 30,)),
        //           provider.activeFilters['sorts']!.fold(false, (prev, curr) => prev || curr) || provider.activeFilters['types']!.fold(false, (prev, curr) => prev || curr)
        //           ? Positioned(
        //             right: 0,
        //             top: 12,
        //             child: Container(
        //               width: 10.0,
        //               height: 10.0,
        //               decoration: new BoxDecoration(
        //                 color: Theme.of(context).colorScheme.secondary,
        //                 shape: BoxShape.circle,
        //               ),
        //             ),
        //           )
        //           : Container()
        //         ]
        //         ,
        //       ),
        //       onPressed: (){
        //         showGeneralDialog(
        //           context: context,
        //           transitionDuration: Duration(milliseconds: 300),
        //           transitionBuilder: (context, animation, secondAnimation, child){
        //             var _animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
        //             return SlideTransition(
        //               child: child,
        //               position: Tween<Offset>(
        //                 begin: Offset(0,-1),
        //                 end: Offset(0,0)
        //               ).animate(_animation),
        //             );
        //           },
        //           pageBuilder: ((context, animation, secondaryAnimation) => MultiProvider(
        //             providers: [
        //               ChangeNotifierProvider.value(value: provider,),
        //               // ChangeNotifierProvider.value(value: wrapperHomePageProvider)
        //             ],
        //             child: FiltersPopUpPage()
        //           )
        //         ));
        //       },
        //     )
        //   )
        // ],
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 60),
        children: [
          Container( /// Search field
            alignment: Alignment.center,
            height: 50,
            width: MediaQuery.of(context).size.width*0.7 < 260 ? MediaQuery.of(context).size.width*0.7 : 260,
            child: TextFormField(
              maxLength: 15,
              focusNode: provider.textFieldFocusNode,
              controller: provider.textEditingController,
              style: TextStyle(
                color: Theme.of(context).canvasColor
              ),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.transparent),
                ),    
                fillColor: Theme.of(context).colorScheme.tertiary,
                // fillColor: Theme.of(context).highlightColor,
                suffixIcon: AnimatedContainer(
                  width: 100,
                  alignment: Alignment.centerRight,
                  duration: Duration(milliseconds: 300),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        child: provider.textFieldFocusNode.hasFocus ? IconButton(
                          icon: Icon(Icons.cancel, color:  Theme.of(context).canvasColor,),
                          onPressed: (){provider.textFieldFocusNode.unfocus(); provider.textEditingController.clear(); provider.updateSearchKeyword("");},
                        )
                        : Container(),
                      ),
                      IconButton(
                        icon: Icon(Icons.search, color:  Theme.of(context).canvasColor,),
                        onPressed: (){
                          if(provider.searchKeyword != null && provider.searchKeyword != "") {
                            provider.textFieldFocusNode.unfocus();
                            provider.updateSearchedPlaces();
                            provider.updateNextPageIndex(1);
                            provider.pageController.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                          }
                          // Navigator.push(context, PageRouteBuilder(
                          //   pageBuilder: (context, animation, secAnimation) => ChangeNotifierProvider.value(
                          //     value: provider,
                          //     child: SearchPlacesPage(),
                          //   ),
                          //   transitionDuration: Duration(milliseconds: 300),
                          //   transitionsBuilder: (context, animation, secAnimation, child){
                          //     var _animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                          //     return SlideTransition(
                          //       child: child,
                          //       position: Tween<Offset>(
                          //         begin: Offset(1, 0),
                          //         end: Offset(0, 0)
                          //       ).animate(_animation),
                          //     );
                          //   },
                          // ));
                        },
                      )
                    ],
                  ),
                ),
                // floatingLabelAlignment: FloatingLabelAlignment.center,
                label: Container(
                  // alignment: Alignment.center,
                  child: Text("Caută", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).canvasColor,),),
                ),
                // enabled: false
              ),
              onChanged: provider.updateSearchKeyword,
            ),
          ),
          SizedBox(height: 20),
          ///Best deal list
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              //vertical: 20 
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cele mai bune oferte",
                  style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 23),
                ),
                CircleAvatar(
                  // backgroundColor: Theme.of(context).highlightColor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios, 
                      // color: Theme.of(context).primaryColor,
                      color: Theme.of(context).canvasColor,
                      size: 16
                    ),
                    onPressed: (){
                      provider.updateNextPageIndex(0);
                      provider.pushFilteredPlaces('best-offer');
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.isLoading ? 2 : provider.bestOfferPlaces.length,
              separatorBuilder: (context, index) => SizedBox(width: 20),
              itemBuilder: (context, index){
                if(provider.isLoading)
                  return Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          spreadRadius: 0.1,
                          blurRadius: 10,
                          offset: const Offset(0, 0)
                        )
                      ],
                      borderRadius: BorderRadius.circular(30),
                      // color: Colors.white
                    ),
                    width: 250,
                    child: Row(
                      children: [
                        Container( /// Place's image
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                            color: Colors.grey[500],
                          ),
                        ),
                        Container( /// Place's description
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  );
                var place = provider.bestOfferPlaces[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                    create: (_) => PlacePageProvider(place, wrapperHomePageProvider),
                    child: PlacePage()
                  ))),
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          spreadRadius: 0.1,
                          blurRadius: 10,
                          offset: const Offset(0, 0)
                        )
                      ],
                      borderRadius: BorderRadius.circular(30),
                      // color: Colors.white
                    ),
                    width: 250,
                    child: Row(
                      children: [
                        Container( /// Place's image
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                            color: Colors.grey[500],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                            child: Image.network(
                              place.profileImageURL,
                              fit: BoxFit.cover,
                            ),
                          )
                        ),
                        Container( /// Place's description
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0, right: 2),
                                child: Text(
                                  place.name,
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(),
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Text.rich(TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.place, size: 13, color: Colors.grey[500]),
                                  ),
                                  WidgetSpan(
                                    child: SizedBox(
                                      width: 10,
                                    )
                                  ),
                                  TextSpan(
                                    text: place.area == null ? "Adresă" : (place.area!.length > 11 ? place.area!.substring(0,1) : place.area),
                                  )
                                ]
                              )),
                              Text.rich(TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.food_bank, size: 13, color: Colors.grey[500]),
                                  ),
                                  WidgetSpan(
                                    child: SizedBox(
                                      width: 5,
                                    )
                                  ),
                                  TextSpan(
                                    text: place.types!.sublist(0,2).toString().substring(1, place.types!.sublist(0,2).toString().length - 1)
                                  )
                                ]
                              ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
          ///Popular list
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Populare",
                  style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 23),
                ),
                CircleAvatar(
                  // backgroundColor: Theme.of(context).highlightColor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios, 
                      // color: Theme.of(context).primaryColor, 
                      color: Theme.of(context).canvasColor,
                      size: 16
                    ),
                    onPressed: (){
                      provider.updateNextPageIndex(0);
                      provider.pushFilteredPlaces('popular');
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.isLoading ? 2 : popularPlaces.length ,
              separatorBuilder: (context, index) => SizedBox(width: 20),
              itemBuilder: (context, index){
                if(provider.isLoading)
                  return Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          spreadRadius: 0.1,
                          blurRadius: 10,
                          offset: const Offset(0, 0)
                        )
                      ],
                      borderRadius: BorderRadius.circular(30),
                      // color: Colors.white
                    ),
                    width: 250,
                    child: Row(
                      children: [
                        Container( /// Place's image
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                            color: Colors.grey[500],
                          ),
                        ),
                        Container( /// Place's description
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  );
                var place = popularPlaces[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                    create: (_) => PlacePageProvider(place, wrapperHomePageProvider),
                    child: PlacePage()
                  ))),
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          spreadRadius: 0.1,
                          blurRadius: 10,
                          offset: const Offset(0, 0)
                        )
                      ],
                      borderRadius: BorderRadius.circular(30),
                      // color: Colors.white
                    ),
                    width: 250,
                    child: Row(
                      children: [
                        Container( /// Place's image
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                            color: Colors.grey[500],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                            child: Image.network(
                              place.profileImageURL,
                              fit: BoxFit.cover,
                            ),
                          )
                        ),
                        Container( /// Place's description
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0, right: 2),
                                child: Text(
                                  place.name,
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(),
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Text.rich(TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.place, size: 13, color: Colors.grey[500]),
                                  ),
                                  WidgetSpan(
                                    child: SizedBox(
                                      width: 10,
                                    )
                                  ),
                                  TextSpan(
                                    text: place.area == null ? "Adresă" : (place.area!.length > 11 ? place.area!.substring(0,1) : place.area),
                                  )
                                ]
                              )),
                              Text.rich(TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.food_bank, size: 13, color: Colors.grey[500]),
                                  ),
                                  WidgetSpan(
                                    child: SizedBox(
                                      width: 5,
                                    )
                                  ),
                                  TextSpan(
                                    text: place.types!.sublist(0,2).toString().substring(1, place.types!.sublist(0,2).toString().length - 1)
                                  )
                                ]
                              ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
          ///Favourite list
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20 
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Favorite",
                  style: Theme.of(context).textTheme.headline6,
                ),
                CircleAvatar(
                  // backgroundColor: Theme.of(context).highlightColor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios, 
                      // color: Theme.of(context).primaryColor, 
                      color: Theme.of(context).canvasColor,
                      size: 16
                    ),
                    onPressed: (){},
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.favouritePlaces.length > 0 ? provider.favouritePlaces.length : 1,
              separatorBuilder: (context, index) => SizedBox(width: 20),
              itemBuilder: (context, index){
                if(provider.favouritePlaces.length == 0)
                  return GestureDetector(
                    onTap: () {
                      provider.updateNextPageIndex(0);
                      provider.pushFilteredPlaces(null);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).highlightColor
                      ),
                      width: 120,
                      height: 140,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Vezi\ntoate", 
                            textAlign: TextAlign.center, 
                            style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).primaryColor)
                          ),
                          SizedBox(height: 20,),
                          Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor,)
                        ],
                      ),
                    ),
                  );
                else{
                  var place = provider.favouritePlaces[index];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                      create: (_) => PlacePageProvider(place, wrapperHomePageProvider),
                      child: PlacePage()
                    ))),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600,
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: const Offset(0, 15)
                          )
                        ],
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white
                      ),
                      width: 220,
                      height: 180,
                      child: Column(
                        children: [
                          Container( /// Place's image
                            decoration: BoxDecoration(
                              color: Colors.grey[500],
                              borderRadius: BorderRadius.circular(30)
                            ),
                            width: 220,
                            height: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                              child: Image.network(
                                place.profileImageURL,
                                fit: BoxFit.cover,
                                // frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => Container(color: Colors.grey[500]),
                              ),
                            )
                          )
                        ],
                      ),
                    ),
                  );
                }
              }
            ),
          ),
          // ///All places list
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: 10.0,
          //     vertical: 20 
          //   ),
          //   child: Text(
          //     "Toate",
          //     style: Theme.of(context).textTheme.headline6,
          //   ),
          // ),
          // Container(
          //   height: 180,
          //   child: ListView.separated(
          //     scrollDirection: Axis.horizontal,
          //     itemCount: popularPlaces.length,
          //     separatorBuilder: (context, index) => SizedBox(width: 20),
          //     itemBuilder: (context, index){
          //       var place = popularPlaces[index];
          //       return Container(
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(30),
          //           color: Colors.white
          //         ),
          //         width: 150,
          //         height: 180,
          //         child: Column(
          //           children: [
          //             Container( /// Place's image
          //               decoration: BoxDecoration(
          //                 color: Colors.grey[500],
          //                 borderRadius: BorderRadius.circular(30)
          //               ),
          //               //width: 50,
          //               height: 120,
          //               child: ClipRRect(
          //                 borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          //                 child: Image.network(
          //                   place.profileImageURL,
          //                   fit: BoxFit.cover,
          //                 ),
          //               )
          //             )
          //           ],
          //         ),
          //       );
          //     }
          //   ),
          // ),
          /// All places list
          // ListView.separated(
          //   shrinkWrap: true,
          //   padding: EdgeInsets.symmetric(vertical: 30),
          //   physics: NeverScrollableScrollPhysics(),
          //   itemCount: places.length == 0 ? 1 : places.length,
          //   separatorBuilder: (context, index) => SizedBox(height: 30),
          //   itemBuilder: (context, index){
          //     if(places.length == 0)
          //       return EmptyList();
          //     else{
          //       var place = places[index];
          //       return GestureDetector(
          //         onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
          //           create: (_) => PlacePageProvider(place, wrapperHomePageProvider),
          //           child: PlacePage()
          //         ))),
          //         child: Container(
          //           height: 300,
          //           child: Stack(
          //             children: [
          //               Align( /// Text box
          //                 alignment: Alignment.bottomCenter,
          //                 child: Container(
          //                   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          //                   height: 300,
          //                   decoration: BoxDecoration(
          //                     color: Colors.white,
          //                     borderRadius: BorderRadius.circular(15)
          //                   ),
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //                     children: [
          //                       Padding(
          //                         padding: const EdgeInsets.only(left: 10.0),
          //                         child: Text(
          //                           place.name, 
          //                           style: Theme.of(context).textTheme.headline6,
          //                         ),
          //                         // child: Text.rich(TextSpan( // place name
          //                         //   children: [
          //                         //     TextSpan(text: place.name, style: Theme.of(context).textTheme.headline6,),
          //                         //     WidgetSpan(child: SizedBox(width: 20,)),
          //                         //     // TextSpan( 
          //                         //     //   text: "by " + place.organiserName,
          //                         //     //   style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
          //                         //     // )
          //                         //   ]
          //                         // ),),
          //                       ),
          //                       // SizedBox(height: 6),
          //                       // Padding(
          //                       //   padding: const EdgeInsets.only(left: 10.0),
          //                       //   child: Text( /// organiser name
          //                       //     "by " + place.organiserName,
          //                       //     style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
          //                       //   ),
          //                       // ),
          //                       Row(
          //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                         children: [
          //                           Row(
          //                             children: [
          //                               Icon(Icons.place, color: Colors.grey[500], size: 20),
          //                               SizedBox(width: 5,),
          //                               Text(place.address!, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal))
          //                             ],

          //                           ),
          //                           // Row(
          //                           //   children: [
          //                           //     Icon(Icons.access_time_filled_rounded, color: Colors.grey[500], size: 18),
          //                           //     SizedBox(width: 5,),
          //                           //     Text(
          //                           //       place.dateEnd != null
          //                           //       ? "${formatDateToHourAndMinutes(place.dateStart)} - ${formatDateToHourAndMinutes(place.dateEnd)}"
          //                           //       : "${formatDateToHourAndMinutes(place.dateStart)}", 
          //                           //       style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
          //                           //     ),
          //                           //   ],
          //                           // ),
          //                         ],
          //                       ),
                                
          //                       // Column(
          //                           //   mainAxisAlignment: MainAxisAlignment.end,
          //                           //   crossAxisAlignment: CrossAxisAlignment.end,
          //                           //   children: [
          //                           //     Row(
          //                           //       children: [
          //                           //         Text(
          //                           //           place.dateEnd != null
          //                           //           ? "${formatDateToHourAndMinutes(place.dateStart)} - ${formatDateToHourAndMinutes(place.dateEnd)}"
          //                           //           : "${formatDateToHourAndMinutes(place.dateStart)}", 
          //                           //           style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)
          //                           //         ),
          //                           //         SizedBox(width: 5,),
          //                           //         Icon(FontAwesomeIcons.solidClock, color: Colors.grey[500], size: 16),
          //                           //       ],
          //                           //     ),
          //                           //   ],
          //                           // )
          //                       // Text.rich(TextSpan( /// place location
          //                       //   children: [
          //                       //     WidgetSpan(child: Icon(Icons.place, color: Colors.grey[500])),
          //                       //     WidgetSpan(child: SizedBox(width: 5,)),
          //                       //     TextSpan(text: place.locationName, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500], fontWeight: FontWeight.normal)),
          //                       //   ]
          //                       // )),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //               // Positioned( /// Date
          //               //   top: 20, 
          //               //   left: 20, 
          //               //   child: Container(
          //               //     alignment: Alignment.center,
          //               //     decoration: BoxDecoration(
          //               //       color: Colors.white,
          //               //       borderRadius: BorderRadius.circular(15)
          //               //     ),
          //               //     height: 65,
          //               //     width: 65,
          //               //     child: Text.rich(TextSpan(
          //               //       children: [
          //               //         TextSpan(
          //               //           text: "${formatDateToShortMonth(place.dateStart)}\n",
          //               //           style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.tertiary),
          //               //         ),
          //               //         TextSpan(
          //               //           text: "${place.dateStart.day}",
          //               //           style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.primary),
          //               //         )
          //               //       ] 
          //               //     ),textAlign: TextAlign.center,),
          //               //   )
          //               // ),
          //               Positioned( /// Favourite
          //                 top: 20, 
          //                 right: 20, 
          //                 child: GestureDetector(
          //                   onTap: (){
          //                     provider.updateFavouriteStatus(index, place);
          //                   },
          //                   child: AnimatedContainer(
          //                     duration: Duration(milliseconds: 300),
          //                     alignment: Alignment.center,
          //                     decoration: BoxDecoration(
          //                       // color: Colors.white,
          //                       // borderRadius: BorderRadius.circular(15)
          //                     ),
          //                     // height: 65,
          //                     // width: 65,
          //                     child: CircleAvatar(
          //                       radius: 23,
          //                       // backgroundColor: Colors.transparent,
          //                       backgroundColor: Colors.white,
          //                       child: place.favourite
          //                       ? Image.asset(localAsset("favourite-solid"), width: 25, color: Colors.red)
          //                       // : Image.asset(localAsset("favourite-solid"), width: 25, color: Colors.white)
          //                       : Image.asset(localAsset("favourite"), width: 25, color: Colors.black),
          //                     )
          //                   ),
          //                 )
          //               )
          //             ],
          //           ),
          //         ),
          //       );
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}