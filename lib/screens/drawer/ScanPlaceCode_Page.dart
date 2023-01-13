import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

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
class ScanPlaceCode extends StatefulWidget {

  final BuildContext? context;

  ScanPlaceCode({this.context});

  @override
  _ScanPlaceCodeState createState() => _ScanPlaceCodeState();
}

class _ScanPlaceCodeState extends State<ScanPlaceCode> {

  PublishSubject<String>? scanStream;

  XFile? _imageFile;

  dynamic _pickImageError;

  bool isVideo = false;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  

  void findReceiptTotal(String text){
    int index = text.indexOf("TOTAL");
    print(index);
    bool found = false;
    String currNum = "";
    while(!found || index == text.length){
      if(int.tryParse(text[index]) != null || text[index] == '.'){
        //if(currNum == "")
          currNum += text[index];
      }
      else if(currNum != ""){
        found = true;
      }
      index++;
    }
    if(double.tryParse(currNum) != null)
      print(currNum);
  }

  void _launchCamera(ImageSource source, {BuildContext? context}) async {
    _imageFile = XFile("");
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
      );
      setState(() {
        pickedFile != null 
        ? _imageFile = pickedFile
        : XFile("");
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: scanStream,
      builder:(context,scanResult) {
        if(_imageFile == null){
          _launchCamera(ImageSource.camera, context: widget.context);
          return Scaffold();
        }
        else if(_imageFile!.path == "")
          return Scaffold();
        else{
          TextRecognizer textDetector = GoogleMlKit.vision.textRecognizer();
          final text = textDetector.processImage(InputImage.fromFilePath(_imageFile!.path));
          return Scaffold(
            body: FutureBuilder(
              future: text,
              builder: (context, AsyncSnapshot<RecognizedText> text) {
                if(!text.hasData)
                  return SpinningLogo();
                else{
                  findReceiptTotal(text.data!.text);
                  return Center(
                    child: Text(
                      text.data!.text
                    ),
                  );
                }
              }
            )
          );
        }
      }
    );
  }
}