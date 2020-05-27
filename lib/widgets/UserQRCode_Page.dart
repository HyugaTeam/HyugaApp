import 'package:flutter/material.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';

// The page containing the user's QR code
class UserQRCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.blueGrey
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        alignment: Alignment(0,0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "Scan your code for the preffered discount."
            ),
            QrImage(
              padding: EdgeInsets.all(0),
              data: authService.currentUser.uid,
              //version: 1,
              size: 320,
              gapless: false,
              errorStateBuilder: (cxt, err) {
                return Container(
                  child: Center(
                    child: Text(
                      "Uh oh! Something went wrong...",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}