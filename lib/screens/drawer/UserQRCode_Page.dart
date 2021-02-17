import 'package:flutter/material.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

// The page containing the user's QR code
class UserQRCode extends StatelessWidget {

  BuildContext globalContext;

  UserQRCode(this.globalContext);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.blueGrey),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        alignment: Alignment(0, 0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Text(
                "Acesta este codul tau unic. \nSolicita scanarea codului tau la venirea in local pentru a revendica reducerea.",
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: QrImage(
                padding: EdgeInsets.all(0),
                data: authService.currentUser.uid,
                size: 320,
                gapless: false,
                errorStateBuilder: (cxt, err) {
                  return Container(
                    child: Center(
                      child: Text(
                        "Oops! Ceva a mers gresit...",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
