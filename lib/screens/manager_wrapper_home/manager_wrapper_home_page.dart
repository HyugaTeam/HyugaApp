import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/screens/manager/ActiveGuests_Page.dart';
import 'package:hyuga_app/screens/manager/AnalysisPage.dart';
import 'package:hyuga_app/screens/manager/EditorPage.dart';
import 'package:hyuga_app/screens/manager/ReservationsPage.dart';
import 'package:hyuga_app/screens/manager_wrapper_home/manager_wrapper_home_provider.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/screens/manager/ManagerQRScan_Page.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:hyuga_app/widgets/drawer.dart';
import 'package:provider/provider.dart';

class ManagerWrapperHomePage extends StatelessWidget {
  
  Future<void> fetchBigQueryData() async {
    // try{
      
    //   Client client = Client();
      
    //   String str = BigqueryApi.BigqueryReadonlyScope;
    //   BigqueryApi bigqueryApi = BigqueryApi(
    //     client,
    //     rootUrl: 'https://bigquery.googleapis.com/',
    //     servicePath: 'bigquery/v2/'
    //   );
    //   var data = bigqueryApi.tables;
    //   await data.get(
    //     'hyuga-app',
    //     'hyuga-app:analytics_223957065',
    //     'hyuga-app:analytics_223957065.events_20200909'
    //   );
    //   print(data);
    // }
    // catch(error){
    //   print('ERROR');
    //   print(error);
    //   print('/////');
    // }
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<ManagerWrapperHomePageProvider>();
    return provider.isLoading 
    /// The managed place's data is loading
    ? Scaffold(body: Center(child: SpinningLogo(),))
    /// The managed place's data is loaded
    : DefaultTabController(
      length: 4,
      child: Scaffold(
        drawer: ProfileDrawer(),
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          actions: [IconButton(
            icon: Icon(Icons.camera_alt),
            iconSize: 30,
            tooltip: "Scaneaza un cod si activeaza o masa",
            highlightColor: Colors.white30,
            color: Theme.of(context).highlightColor,
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
              Provider(
                create: (context) => provider.managedPlace,
                child: ManagerQRScan()
              ),
              ));
            },
          ),],
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: Text(
            provider.managedPlace!.name!
          ),
          bottom: TabBar(
            labelPadding: EdgeInsets.all(5),
            tabs: [Text("Mese active"),Text("Rezervari"),Text("Analiza & Facturi"), Text("Editor")]
          ),
        ),
        body: TabBarView(
          children: [
            ChangeNotifierProvider<ManagerWrapperHomePageProvider>.value(
              value: provider,
              child: ActiveGuestsPage()
            ),
            ChangeNotifierProvider<ManagerWrapperHomePageProvider>.value(
              value: provider,
              child: ReservationsPage()
            ),
            ChangeNotifierProvider<ManagerWrapperHomePageProvider>.value(
              value: provider,
              child: AnalysisPage()
            ),
            ChangeNotifierProvider<ManagerWrapperHomePageProvider>.value(
              value: provider,
              child: EditorPage()
            ),
          ]
        )
      ),
    );
    // return FutureBuilder<ManagedPlace>(
    //   future: _getPlaceData(),
    //   initialData: null,
    //   builder: (context, provider.managedPlace) {
    //     print("hasData " + provider.managedPlace.hasData.toString());
    //     if(!provider.managedPlace.hasData)
    //       return Scaffold(body: Center(child: SpinningLogo(),));
    //     else 
    //       return DefaultTabController(
    //         length: 4,
    //         child: Scaffold(
    //           drawer: ProfileDrawer(),
    //           backgroundColor: Theme.of(context).backgroundColor,
    //           appBar: AppBar(
    //             actions: [IconButton(
    //               icon: Icon(Icons.camera_alt),
    //               iconSize: 30,
    //               tooltip: "Scaneaza un cod si activeaza o masa",
    //               highlightColor: Colors.white30,
    //               color: Theme.of(context).highlightColor,
    //               onPressed: () async {
    //                 Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
    //                 Provider(
    //                   create: (context) => provider.managedPlace,
    //                   child: ManagerQRScan()
    //                 ),
    //                 ));
    //               },
    //             ),],
    //             backgroundColor: Theme.of(context).primaryColor,
    //             centerTitle: true,
    //             title: Text(
    //               provider.managedPlace.data!.name!
    //             ),
    //             bottom: TabBar(
    //               labelPadding: EdgeInsets.all(5),
    //               tabs: [Text("Mese active"),Text("Rezervari"),Text("Analiza & Facturi"), Text("Editor")]
    //             ),
    //           ),
    //           body: TabBarView(
    //             children: [
    //               Provider<AsyncSnapshot<ManagedPlace>>(
    //                 create: (context) => provider.managedPlace,
    //                 child: ActiveGuestsPage()
    //               ),
    //               Provider<AsyncSnapshot<ManagedPlace>>(
    //                 create: (context) => provider.managedPlace,
    //                 child: ReservationsPage()
    //               ),
    //               Provider<AsyncSnapshot<ManagedPlace>>(
    //                 create: (context) => provider.managedPlace,
    //                 child: AnalysisPage()
    //               ),
    //               Provider<AsyncSnapshot<ManagedPlace>>(
    //                 create: (context) => provider.managedPlace,
    //                 child: EditorPage()
    //               ),
    //             ]
    //           )
    //         ),
    //       );
    //   }
    // );
  }
}