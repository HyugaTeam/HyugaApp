import 'package:flutter/material.dart';

/// Singleton class user by 'ScanPlaceCode' widget
class ScanPlaceCodeService {
    static final _scanPlaceCodeService = ScanPlaceCodeService._instance();

    factory ScanPlaceCodeService(){
      return _scanPlaceCodeService;
    }
    dynamic scanCode(){
      // TODO: opens the camera context
    }
    ScanPlaceCodeService._instance();
}

/// The Page through which the user scans the table code when arriving in the restaurant
class ScanPlaceCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        leading: Align(
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            splashColor: Theme.of(context).highlightColor,
            onPressed: (){
              ScanPlaceCodeService().scanCode();
            },
          ),
          //alignment: Alignment(0,-0.7),
        ),
        title: Text(
          "Scaneaza codul de pe masa",
          style: TextStyle(
            color: Colors.black
          ),
        ),
      ),
      body: Container(
        child: Center(child: Text("Camera context comes here")),
      ),
    );
  }
}