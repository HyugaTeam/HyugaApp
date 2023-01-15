import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';
import 'components/cancel_reservation_popup_page.dart';
import 'components/place_directions_page.dart';
import 'components/place_offers.dart';
import 'reservation_provider.dart';

class ReservationPage extends StatelessWidget {

  final _scrollController = ScrollController(
    keepScrollOffset: true,
    initialScrollOffset: 0
  );
  final bool manager;
  ReservationPage([this.manager = false]);

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<ReservationPageProvider>();
    var wrapperHomePageProvider; 
    if(!manager)
      wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    var reservation = provider.reservation;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        //toolbarHeight: 70,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(210, 30), bottomRight: Radius.elliptical(210, 30))),
        // title: Center(child: Text("Rezervare confirmată", style: Theme.of(context).textTheme.headline4,)),
        backgroundColor: Colors.transparent,
        toolbarHeight: 100,
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
      floatingActionButton: reservation.canceled || (reservation.claimed != null && reservation.claimed!) || (reservation.accepted != null && !reservation.accepted!)
      ? Container()
      : FloatingActionButton.extended(
        elevation: 0, 
        shape: ContinuousRectangleBorder(),
        backgroundColor: reservation.canceled
        ? Colors.grey
        : Theme.of(context).primaryColor,
        onPressed: 
        reservation.canceled
        ? null
        :(){
          showModalBottomSheet(
            context: context, 
            // elevation: 0,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).primaryColor,
            barrierColor: Colors.black.withOpacity(0.35),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
            builder: (context) => ChangeNotifierProvider<ReservationPageProvider>.value(
              value: provider,
              child: Container(
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
                        child: CancelReservationPopupPage()
                      )
                    ),
                  ],
                ),
              )
            )
          );
        },
        label: Opacity(
          opacity: reservation.canceled
            ? 0.7
            : 1,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              reservation.canceled
              ? "Anulată"
              :"Anulează rezervarea", 
              textAlign: TextAlign.center, 
              style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 18),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Stack( /// The place's image
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(150,30), bottomRight: Radius.elliptical(200,50)),
                    child: Container(
                      height: 220 + MediaQuery.of(context).padding.top,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(150,30), bottomRight: Radius.elliptical(200,50)),
                    child: Stack(
                      children: [
                        Container(
                          height: 200 + MediaQuery.of(context).padding.top,
                          width: MediaQuery.of(context).size.width,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: FutureBuilder<Image>(
                              future: provider.image,
                              builder: (context, image){  
                                if(!image.hasData)
                                  return Container(
                                    width: 400,
                                    height: 200,
                                    color: Colors.transparent,
                                  );
                                else 
                                  return image.data!;
                              }
                            ),
                          ),
                        ),
                        reservation.canceled
                        ? Container(
                          height:  200 + MediaQuery.of(context).padding.top,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black54,
                          child: Center(
                            child: Text("Anulată", style: Theme.of(context).textTheme.headline4),
                          ),
                        )
                        : Container(),
                        reservation.active == true
                          ? Container(
                            height:  200 + MediaQuery.of(context).padding.top,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.black54,
                            child: Center(
                              child: Text("Rezervare activă", style: Theme.of(context).textTheme.headline4),
                            ),
                          )
                          : Container()
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "Rezervare la",
                  style: Theme.of(context).textTheme.headline6
                ),
              ),
              Padding( /// The place's name
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  "${reservation.placeName}",
                  style: Theme.of(context).textTheme.headline3
                ),
              ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(/// TIME, DATE 
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: Image.asset(localAsset('calendar'), color: Theme.of(context).primaryColor, width: 16,),
                              backgroundColor: Theme.of(context).highlightColor, radius: 15,
                            ),
                            SizedBox(width: 10),
                            Text( 
                              formatDateToDay(reservation.dateStart)!,
                              style: Theme.of(context).textTheme.overline!.copyWith(fontSize: 15)
                            ),
                          ]
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            CircleAvatar(
                              child: Image.asset(localAsset('time'), color: Theme.of(context).primaryColor, width: 16,),
                              backgroundColor: Theme.of(context).highlightColor, radius: 15,
                            ),
                            SizedBox(width: 10),
                            Text( 
                              formatDateToHourAndMinutes(reservation.dateStart)!,
                              style: Theme.of(context).textTheme.overline!.copyWith(fontSize: 15)
                            ),
                          ]
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            CircleAvatar(
                              child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 16,),
                              backgroundColor: Theme.of(context).highlightColor, radius: 15,
                            ),
                            SizedBox(width: 10),
                            Text( 
                              reservation.guestName == null 
                              ? ( Authentication.auth.currentUser!.displayName!.length < 20 ?  Authentication.auth.currentUser!.displayName! : reservation.guestName!.substring(0,20))
                              : ( Authentication.auth.currentUser!.displayName != null
                              ? Authentication.auth.currentUser!.displayName!.length < 20 ?  Authentication.auth.currentUser!.displayName! : reservation.guestName!.substring(0,20)
                              : "fără nume"),
                              style: Theme.of(context).textTheme.overline!.copyWith(fontSize: 15, color: Theme.of(context).colorScheme.secondary)
                            ),
                          ]
                        )
                      ],
                    ),                    
                    Column(///Number of people
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: Image.asset(localAsset('user'), color: Theme.of(context).primaryColor, width: 16,),
                              backgroundColor: Theme.of(context).highlightColor, radius: 15,
                            ),
                            SizedBox(width: 10),
                            Text(
                              reservation.numberOfGuests.toString(),
                              style: Theme.of(context).textTheme.overline!.copyWith(fontSize: 15)
                            ),
                          ]
                        ),
                        SizedBox(height: 20,),
                        // Text.rich( /// The Discount 
                        //   TextSpan(
                        //     children: [
                        //       WidgetSpan(child: Image.asset(localAsset('time'), width: 16)),
                        //       WidgetSpan(child: SizedBox(width: 10)),
                        //       TextSpan(
                        //         text: reservation.deals != null && reservation.discount != 0
                        //           ? reservation.discount.toString() 
                        //           : "fără reducere",
                        //         style: Theme.of(context).textTheme.overline!.copyWith(fontSize: 15)
                        //       ),
                        //     ]
                        //   )
                        // ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            CircleAvatar(
                              child: Image.asset(localAsset('phone'), color: Theme.of(context).primaryColor, width: 16,),
                              backgroundColor: Theme.of(context).highlightColor, radius: 15,
                            ),
                            SizedBox(width: 10),
                            Text(
                              reservation.contactPhoneNumber!,
                              style: Theme.of(context).textTheme.overline!.copyWith(fontSize: 15)
                            ),
                          ]
                        )
                      ],
                    ),
                  ],
                ),
              ),
              provider.place != null && provider.place!.importantInformation != null
              ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich( /// The Date
                      TextSpan(
                        children: [
                          WidgetSpan(child: CircleAvatar(
                                child: Image.asset(localAsset('important'), color: Theme.of(context).primaryColor, width: 16,),
                                backgroundColor: Theme.of(context).highlightColor, radius: 15,
                              ),),
                          WidgetSpan(child: SizedBox(width: 10)),
                          TextSpan(
                            text: "Informații importante",
                            style: Theme.of(context).textTheme.headline6
                          ),
                        ]
                      )
                    ),
                    SizedBox(
                      height: 10
                    ),
                    Text("Discount-urile se aplică doar la meniul de mâncare, fără băuturi")
                  ],
                ),
              )
              : Container(),
              !manager
              ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    style: Theme.of(context).textButtonTheme.style!.copyWith(
                      //backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 20))
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: provider,),
                          !manager
                          ? ChangeNotifierProvider<WrapperHomePageProvider>.value(value: wrapperHomePageProvider,)
                          : ChangeNotifierProvider.value(value: null)
                        ],
                        child: PlaceDirectionsPage()
                      ))
                    ),
                    icon: Image.asset(localAsset("map"), width: 20, color: Theme.of(context).canvasColor),
                    label: Text("Cum ajung?", style: Theme.of(context).textTheme.overline!.copyWith(fontSize: 13, color: Theme.of(context).canvasColor),),
                  ),
                  SizedBox(width: 30,),
                  SizedBox(
                    width: 80,
                    child: TextButton(
                      style: Theme.of(context).textButtonTheme.style!.copyWith(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero)
                      ),
                      onPressed: () => provider.launchUber(context, wrapperHomePageProvider.currentLocation),
                      //icon: Image.asset(asset("map"), width: 20,),
                      child: Text("Uber", style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 13),),
                    ),
                  ),
                ],
              )
              : Container(),
              SizedBox(height: 30,),
              provider.place != null
              ? PlaceOffers(provider.place!)
              : Container(),
              Container(height: MediaQuery.of(context).size.height*0.1,)
              // reservation.claimed == true
              // ? Center(
              //   child: TextButton(
              //     style: Theme.of(context).textButtonTheme.style!.copyWith(
              //       //backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              //       padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 20))
              //     ),
              //     onPressed: () => Navigator.push(context, MaterialPageRoute(
              //       builder: (context) => MultiProvider(
              //         providers: [
              //           ChangeNotifierProvider.value(value: provider,),
              //           // !manager
              //           // ? ChangeNotifierProvider<WrapperHomePageProvider>.value(value: wrapperHomePageProvider,)
              //           // : ChangeNotifierProvider.value(value: null)
              //         ],
              //         child: PastOrdersPage()
              //       ))
              //     ),
              //     child: Text("Comenzi", style: Theme.of(context).textTheme.overline!.copyWith(fontSize: 13),),
              //   ),
              // )
              // : Container(),
            
              // Padding(
              //   padding: const EdgeInsets.all(15.0),
              //   child: Text(
              //     reservation.accepted == null
              //     ? "Rezervare în așteptare"
              //     : (reservation.accepted == true 
              //       ? "Rezervare acceptată"
              //       : "Rezervare refuzată"
              //     ),
              //     style: Theme.of(context).textTheme.headline3
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(15.0),
              //   child: Text(
              //     reservation.accepted == null
              //     ? "Rezervarea va fi în scurt timp confirmată"
              //     : (reservation.accepted == true 
              //       ? "Rezervare acceptată"
              //       : "Rezervare refuzată"
              //     ),
              //     style: Theme.of(context).textTheme.headline6
              //   ),
              // ),
            ]),
          ),
        ],
      )
    );
  }
}