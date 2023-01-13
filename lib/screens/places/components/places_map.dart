import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/places/places_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';

import 'filters_popup.dart';

class PlacesMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    var provider = context.watch<PlacesPageProvider>();
    var city = wrapperHomePageProvider.city;
    return 
    // wrapperHomePageProvider.isLoading ? Positioned(
    //   bottom: MediaQuery.of(context).padding.bottom,
    //   child: Container(
    //     height: 5,
    //     width: MediaQuery.of(context).size.width,
    //     child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
    //   ),
    // )
    // : 
    Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text("Restaurante",),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //   child: CircleAvatar(
          //     backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
          //     child: Image.asset(localAsset("more"), width: 22, color: Theme.of(context).primaryColor,),
          //     radius: 30,
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: IconButton(
              icon: Stack(
                children: [
                  Center(child: Image.asset(localAsset('filter'), width: 30,)),
                  provider.activeFilters['sorts']!.fold(false, (prev, curr) => prev || curr) 
                  || provider.activeFilters['types']!.fold(false, (prev, curr) => prev || curr)
                  || provider.activeFilters['ambiences']!.fold(false, (prev, curr) => prev || curr)
                  || provider.activeFilters['costs']!.fold(false, (prev, curr) => prev || curr)
                  ? Positioned(
                    right: 0,
                    top: 12,
                    child: Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: new BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                  : Container()
                ]
                ,
              ),
              onPressed: (){
                showGeneralDialog(
                  context: context,
                  transitionDuration: Duration(milliseconds: 300),
                  transitionBuilder: (context, animation, secondAnimation, child){
                    var _animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                    return SlideTransition(
                      child: child,
                      position: Tween<Offset>(
                        begin: Offset(0,-1),
                        end: Offset(0,0)
                      ).animate(_animation),
                    );
                  },
                  pageBuilder: ((context, animation, secondaryAnimation) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: provider,),
                      // ChangeNotifierProvider.value(value: wrapperHomePageProvider)
                    ],
                    child: FiltersPopUpPage()
                  )
                ));
              },
            )
          )
        ],
      ),
      body: Builder(
        builder: (context) {
          if(provider.googleMapController != null)
            provider.googleMapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(city!['location'].latitude, city['location'].longitude), zoom: 14)));
          return Center(
            //heightFactor: 1.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                alignment: Alignment.bottomCenter,
                // padding: EdgeInsets.symmetric(horizontal: 15),
                height: MediaQuery.of(context).size.height,
                child: GoogleMap(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: city != null ?
                  CameraPosition(target: LatLng(city['location'].latitude, city['location'].longitude), zoom: 14)
                  : CameraPosition(target: LatLng(0,0)),
                  onMapCreated: (controller){
                    provider.initializeGoogleMapController(controller);
                  },
                  markers: provider.markers,
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}