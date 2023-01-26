import 'package:flutter/material.dart';
import 'package:hyuga_app/config/paths.dart';
import 'package:hyuga_app/screens/place/components/search_places_page.dart';
import 'package:hyuga_app/screens/places/components/filtered_places_list.dart';
import 'package:hyuga_app/screens/places/components/places_list.dart';
import 'package:hyuga_app/screens/places/components/places_map.dart';
import 'package:hyuga_app/screens/places/places_provider.dart';


/// Wrapping screen for the 'Places' page
/// Either a 'Google Map', or a 'List of places'
class PlacesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PlacesPageProvider>();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: AnimatedContainer(
          //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          // alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0.1,
                blurRadius: 10,
                offset: const Offset(0, 0)
              )
            ],
          ),
          duration: Duration(milliseconds: 300),
          width: 200,
          height: 30,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => provider.viewType == ViewType.map ? provider.changeViewType() : null,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: provider.viewType == ViewType.list ? Theme.of(context).colorScheme.tertiary : Colors.white,
                    borderRadius: BorderRadius.circular(30)
                  ),
                  width: 100,
                  height: 30,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Image.asset(localAsset("list"), width: 15, color: provider.viewType == ViewType.map ? Colors.grey: Theme.of(context).canvasColor,)
                        ),
                        WidgetSpan(
                          child: SizedBox(width: 10)
                        ),
                        TextSpan(
                          text: "Listă",
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 15, color: provider.viewType == ViewType.map ? Colors.grey: Theme.of(context).canvasColor)
                        )
                      ]
                    )
                  )
                ),
              ),
              GestureDetector(
                onTap: () => provider.viewType == ViewType.list ? provider.changeViewType() : null,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: provider.viewType == ViewType.map ? Theme.of(context).colorScheme.tertiary : Colors.white,
                    borderRadius: BorderRadius.circular(30)
                  ),
                  width: 100,
                  height: 30,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Image.asset(localAsset("map"), width: 15, color: provider.viewType == ViewType.list ? Colors.grey: Theme.of(context).canvasColor)
                        ),
                        WidgetSpan(
                          child: SizedBox(width: 10)
                        ),
                        TextSpan(
                          text: "Hartă",
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 15, color: provider.viewType == ViewType.list ? Colors.grey: Theme.of(context).canvasColor),
                        )
                      ]
                    )
                  )
                  // child: Text(
                  //   "Hartă",
                  //   style: Theme.of(context).textTheme.subtitle1,
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   toolbarHeight: 70,
      //   title: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
      //     child: Text("Restaurante",),
      //   ),
      //   actions: [
      //     // Padding(
      //     //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
      //     //   child: CircleAvatar(
      //     //     backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
      //     //     child: Image.asset(localAsset("more"), width: 22, color: Theme.of(context).primaryColor,),
      //     //     radius: 30,
      //     //   ),
      //     // ),
      //     Padding(
      //       padding: EdgeInsets.symmetric(horizontal: 20.0),
      //       child: IconButton(
      //         icon: Stack(
      //           children: [
      //             Center(child: Image.asset(localAsset('filter'), width: 30,)),
      //             provider.activeFilters['sorts']!.fold(false, (prev, curr) => prev || curr) || provider.activeFilters['types']!.fold(false, (prev, curr) => prev || curr)
      //             ? Positioned(
      //               right: 0,
      //               top: 12,
      //               child: Container(
      //                 width: 10.0,
      //                 height: 10.0,
      //                 decoration: new BoxDecoration(
      //                   color: Theme.of(context).colorScheme.secondary,
      //                   shape: BoxShape.circle,
      //                 ),
      //               ),
      //             )
      //             : Container()
      //           ]
      //           ,
      //         ),
      //         onPressed: (){
      //           showGeneralDialog(
      //             context: context,
      //             transitionDuration: Duration(milliseconds: 300),
      //             transitionBuilder: (context, animation, secondAnimation, child){
      //               var _animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
      //               return SlideTransition(
      //                 child: child,
      //                 position: Tween<Offset>(
      //                   begin: Offset(0,-1),
      //                   end: Offset(0,0)
      //                 ).animate(_animation),
      //               );
      //             },
      //             pageBuilder: ((context, animation, secondaryAnimation) => MultiProvider(
      //               providers: [
      //                 ChangeNotifierProvider.value(value: provider,),
      //                 // ChangeNotifierProvider.value(value: wrapperHomePageProvider)
      //               ],
      //               child: FiltersPopUpPage()
      //             )
      //           ));
      //         },
      //       )
      //     )
      //   ],
      // ),
      body: Stack(
        children: [
          IndexedStack(
            index: provider.viewType.index,
            children: [
              PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: provider.pageController,
                children: [
                  PlacesList(),
                  IndexedStack(
                    index: provider.nextPageIndex,
                    children: [
                      FilteredPlacesList(),
                      SearchPlacesPage()
                    ],
                  )
                ],
              ),
              PlacesMap()
            ],
            // children: [
            //   /// Map or list of places
            //   provider.viewType == ViewType.list
            //   ? PageView(
            //     physics: NeverScrollableScrollPhysics(),
            //     controller: provider.pageController,
            //     children: [
            //       PlacesList(),
            //       FilteredPlacesList()
            //     ],
            //   )
            //   : PlacesMap(),
            //   /// Search bar
            //   // Positioned(
            //   //   //top: MediaQuery.of(context).padding.top,
            //   //   child:  Center(
            //   //     heightFactor: 1,
            //   //     child: Container(
            //   //       alignment: Alignment.center,
            //   //       height: 50,
            //   //       width: MediaQuery.of(context).size.width*0.7 < 260 ? MediaQuery.of(context).size.width*0.7 : 260,
            //   //       child: TextFormField(
            //   //         style: TextStyle(
            //   //           color: Theme.of(context).primaryColor
            //   //         ),
            //   //         keyboardType: TextInputType.name,
            //   //         decoration: InputDecoration(
            //   //           border: OutlineInputBorder(
            //   //             borderRadius: BorderRadius.circular(30),
            //   //             borderSide: BorderSide(color: Colors.transparent),
            //   //           ),
            //   //           disabledBorder: OutlineInputBorder(
            //   //             borderRadius: BorderRadius.circular(30),
            //   //             borderSide: BorderSide(color: Colors.transparent),
            //   //           ),    
            //   //           fillColor: Theme.of(context).highlightColor,
            //   //           suffixIcon: IconButton(
            //   //             onPressed: (){},
            //   //             icon: Icon(Icons.search, color:  Theme.of(context).primaryColor,)
            //   //           ),
            //   //           // floatingLabelAlignment: FloatingLabelAlignment.center,
            //   //           label: Container(
            //   //             // alignment: Alignment.center,
            //   //             child: Text("Caută", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[500]),),
            //   //           ),
            //   //           // enabled: false
            //   //         ),
            //   //       // onChanged: (email) => provider.setEmail(email),
            //   //       ),
            //   //     ),
            //   //   ),
            //   // ),
            //   /// Loading bar
              
            // ],
          ),
          provider.isLoading
          ? Positioned(
            child: Container(
              height: 5,
              width: MediaQuery.of(context).size.width,
              child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
            ), 
            bottom: MediaQuery.of(context).padding.bottom,
          )
          : Container(),
        ],
      ),
    );
  }
}