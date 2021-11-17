import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hyuga_app/models/locals/local.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;

class WriteTextPainter  extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size){

  }

  @override
  bool shouldRepaint(WriteTextPainter oldDelegate) => false;
}


class HomeMap extends StatefulWidget {
  const HomeMap({ Key key }) : super(key: key);

  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  
  List<Local> places = [];
  List<BitmapDescriptor> pins = [];

  Future getPlaces(){
    return queryingService.fetchOnlyDiscounts().then((fetchedPlaces) async{

      List customPins = List<BitmapDescriptor>();
      for(int i = 0 ; i < fetchedPlaces.length; i++) {
        BitmapDescriptor customPin = await createCustomMarkerBitmap(fetchedPlaces[i].name);
        // print("CUSTOM PIN " + customPin.toString());
        customPins.add(customPin);
        // print(customPins.length.toString() + " LUNGIME CURENTA");
      }

    // print("length places:" + fetchedPlaces.length.toString());
    // print("length pins:" + customPins.length.toString());

      setState(() {
        pins = customPins;
        places = fetchedPlaces;      
      });
    });
  }
  @override
    void initState() {
      super.initState();
      getPlaces();
    }

  Future<BitmapDescriptor> createCustomMarkerBitmap(String name) async {

    /// The 'size' field doesn't work for some reason
    var pin = 
    g.isIOS ? BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 0, size: Size(50,50)), 
      "assets/images/pins/ios/wine-street-logo-pin.png", 
    )
    : BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 0, size: Size(50,50)), 
      "assets/images/pins/android/wine-street-logo-pin.png", 
    );
    return pin;

    final height = 100, width = 100;
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.blue;
    final Radius radius = Radius.circular(20.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: 'Hello world',
      style: TextStyle(fontSize: 25.0, color: Colors.white),
    );
    painter.layout();
    painter.paint(canvas, Offset((width * 0.5) - painter.width * 0.5, (height * 0.5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());

    // PictureRecorder recorder = new PictureRecorder();
    // Canvas c = new Canvas(recorder);
    
    // /// Create the text we want to add over the icon     
    // ParagraphBuilder paragraphBuilder = ParagraphBuilder(
    //   ParagraphStyle(
    //     fontSize: 20
    //   )
    // );
    // paragraphBuilder.addText(
    //   name
    // );
    // Paragraph paragraph = paragraphBuilder.build();
    
    // c.drawParagraph(paragraph, Offset(0,0));
    // /* Do your painting of the custom icon here, including drawing text, shapes, etc. */

    // Picture p = recorder.endRecording();
    // ByteData pngBytes = await (await p.toImage(
    //     100,100))
    //     .toByteData(format: ImageByteFormat.png);

    // Uint8List data = Uint8List.view(pngBytes.buffer);
    // print(data.length.toString() + "lungime buffer");

    // //return BitmapDescriptor.fromBytes(data);
    }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: GoogleMap(
        mapToolbarEnabled: false,
        cameraTargetBounds: CameraTargetBounds(
          LatLngBounds(
            northeast: LatLng(44.573465, 26.310127),
            southwest: LatLng(44.313637, 25.903731)
          )
        ),
        padding: EdgeInsets.only(bottom: 50,),
        initialCameraPosition: CameraPosition(
          target: LatLng(44.427466, 26.102500),
          //target: LatLng(queryingService.userLocation.latitude, queryingService.userLocation.longitude),
          zoom: 14  
        ),
        markers: places.map( (item) =>
          Marker(
            icon: pins[places.indexOf(item)],
            infoWindow: InfoWindow(
              title: item.name,
              snippet: "Apasa pentru oferta",
              onTap: () => Navigator.pushNamed(
                context,
                '/third',
                /// The first argument stands for the actual 'Place' information
                /// The second argument stands for the 'Route' from which the third page came from(for Analytics purpose)
                arguments: [item,false] 
            )
              //snippet: item.name
            ),
            markerId: MarkerId(item.name),
            position: LatLng(item.location.latitude, item.location.longitude), 
          )
        ).toSet(),
      ),
    );
  }
}