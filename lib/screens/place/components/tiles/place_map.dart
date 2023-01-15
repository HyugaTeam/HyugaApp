import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/place/place_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';

class PlaceMapPage extends StatelessWidget {

  PlaceMapPage();

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PlacePageProvider>();
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    var placeLocation = provider.place.location;
    var userLocation = wrapperHomePageProvider.currentLocation;
    // print(provider.distanceBetween(userLocation!, placeLocation));
    if(userLocation != null && provider.distance == null && provider.time == null)
      provider.getTimeAndDistance(userLocation, placeLocation);
    if(userLocation != null && provider.polyline == null)
      provider.getPolylines(context, LatLng(userLocation.latitude!, userLocation.longitude!),  LatLng(placeLocation.latitude, placeLocation.longitude));
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).highlightColor,
            radius: 40,
            child: IconButton(
              // alignment: Alignment.centerRight,
              color: Theme.of(context).colorScheme.secondary,
              //padding: EdgeInsets.symmetric(horizontal: 20),
              onPressed: () => Navigator.pop(context),
              icon: Image.asset(localAsset("left-arrow"), width: 18, color: Theme.of(context).primaryColor,)
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Align(
        alignment: Alignment(0,0.8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
               padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  boxShadow: [
                    BoxShadow(offset: Offset(0,1), color: Colors.black54)
                  ]
                ),
                //height: 100,
                width: 230,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.place.name, style: Theme.of(context).textTheme.labelMedium,),
                    // Container(
                    //   height: 100,
                    //   width: 220,
                    //   child: Text.rich(
                    //       TextSpan(
                    //         children: [
                    //           TextSpan(text: "Deschide în",style: Theme.of(context).textTheme.subtitle1!.copyWith(letterSpacing: 0, fontWeight: FontWeight.bold),),
                    //           WidgetSpan(child: SizedBox(width: 10,)),
                    //           WidgetSpan(child: Image.asset(localAsset('google-maps'), width: 18, ))
                    //         ]
                    //       )

                    //     ),
                    // ),
                    SizedBox(height: 10,),
                    provider.distance != null && provider.time != null
                    ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(localAsset("distance"), width: 18,),
                              SizedBox(width: 20),
                              Text(provider.distance!)
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Image.asset(localAsset("time"), width: 16,),
                              SizedBox(width: 20),
                              Text(provider.time!)
                            ],
                          ),
                          // Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     MaterialButton(
                          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          //       color: Theme.of(context).highlightColor,
                          //       padding: EdgeInsets.zero,
                          //       child: Text("w"),
                          //       onPressed: (){}
                          //     ),
                          //     MaterialButton(
                          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          //       color: Theme.of(context).highlightColor,
                          //       padding: EdgeInsets.zero,
                          //       child: Text("w"),
                          //       onPressed: (){}
                          //     ),
                          //     MaterialButton(
                          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          //       padding: EdgeInsets.zero,
                          //       color: Theme.of(context).highlightColor,
                          //       child: Text("w"),
                          //       onPressed: (){}
                          //     ),
                          //   ],
                          // )
                        ],
                      ),
                    )
                    : Container(),
                    //SizedBox(height: 20),
                    userLocation == null
                    ? Container(
                      height: 40,
                      width: 220,
                      child: FloatingActionButton.extended(
                        elevation: 0,
                        label: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Traseu",style: Theme.of(context).textTheme.subtitle1!.copyWith(letterSpacing: 0, fontWeight: FontWeight.bold),),
                              // WidgetSpan(child: SizedBox(width: 10,)),
                              // WidgetSpan(child: Image.asset(localAsset('google-maps'), width: 18, ))
                            ]
                          )

                        ),
                        onPressed: () => wrapperHomePageProvider.getLocation()
                      ),
                    )
                    : Container(),
                    // SizedBox(width: 10,),
                    // Container(
                    //   height: 40,
                    //   width: 150,
                    //   child: FloatingActionButton.extended(
                    //     label: Column(
                    //       children: [
                    //         Text("Comandă", style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),),
                    //       ],
                    //     ),
                    //     onPressed: () {},
                    //   ),
                    // ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          /// We have the user's location
          userLocation != null
          ? GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (userLocation.latitude! + placeLocation.latitude) / 2, (userLocation.longitude! + placeLocation.longitude) / 2
              ),
              zoom: 13
            ),
            myLocationEnabled: true,
            markers: provider.pin != null
            ? {
              Marker(
                icon: provider.pin!,
                markerId: MarkerId('place'),
                position: LatLng(placeLocation.latitude,placeLocation.longitude)
              ),
              Marker(
                icon: provider.pin!,
                markerId: MarkerId('user'),
                position: LatLng(userLocation.latitude!, userLocation.longitude!)
              ),
            }
            : {},
            polylines: provider.polyline != null
            ? {
              provider.polyline!
            }
            : {},
          )
          /// We don't have the user's location
          : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(placeLocation.latitude, placeLocation.longitude),
              zoom: 15
            ),
            myLocationEnabled: true,
            markers: provider.pin != null
            ? {
              Marker(
                icon: provider.pin!,
                markerId: MarkerId('0'),
                position: LatLng(placeLocation.latitude ,placeLocation.longitude)
              ),
            }
            : {},
          ),
          provider.pin == null && provider.polyline == null
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