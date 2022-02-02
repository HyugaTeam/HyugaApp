import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:hyuga_app/widgets/LoadingAnimation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

/// Singleton class user by 'ScanPlaceCode' widget
class ScanReceiptService {
    static final _scanPlaceCodeService = ScanReceiptService._instance();

    factory ScanReceiptService(){
      return _scanPlaceCodeService;
    }
    dynamic scanCode(){
      // TODO: opens the camera context
    }
    ScanReceiptService._instance();
}

/// The Page through which the user scans the table code when arriving in the restaurant
class ScanReceipt extends StatefulWidget {

  BuildContext? context;

  ScanReceipt({this.context});

  @override
  _ScanReceiptState createState() => _ScanReceiptState();
}

class _ScanReceiptState extends State<ScanReceipt> {

  PublishSubject<String>? scanStream;

  XFile? _imageFile;

  dynamic _pickImageError;

  bool isVideo = false;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  // TODO
  // Implement C.I.F verification
  // In Firebase, the C.I.F is stored only in the 7 digits format (ex: '1234567' without the 'RO')
  String checkPlaceLegalId(String text){
    print(text.substring(0,200));
    RegExp regExp = RegExp(r"((PO)|(RO)|(R0)|(P0))\d{1,9}");
    RegExpMatch? cifMatch;
    try{
      cifMatch = regExp.firstMatch(text);
      print(cifMatch);
    }
    catch(ex){
      print(ex.toString());
    }
    print(text.substring(cifMatch!.start+2, cifMatch.end));
    return text.substring(cifMatch.start+2, cifMatch.end);
  }

  String findReceiptTotal(String text){
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
    return currNum;
  }

  void _launchCamera(ImageSource source, {BuildContext? context}) async {
    _imageFile = XFile("");
    try {
      final pickedFile = await (ImagePicker().pickImage(
        source: source,
      ) as FutureOr<XFile>);
      var imgBytes = await pickedFile.readAsBytes();
      var img = await decodeImageFromList(imgBytes);
      print(img.height);
      print(img.width);
      setState(() {
        pickedFile != null 
        ? _imageFile = pickedFile
        : XFile("");
      });
    } catch (e) {
      print(e);
    }
  }

  onStepTapped(int step){
    setState(() {
      _currentStep = step;    
    });
  }

  int _currentStep = 0;
  late List<Step> _steps;

  void initSteps(String total){
    //setState(() {
      _steps = [
        Step( 
          title: Text("Totalul este ${total}RON"),
          content: Text("Este corect?"),
        ),
      ];
   // });
  }
  void onStepCont(){

  }

  void onStepCancel(){

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
          TextDetector textDetector = GoogleMlKit.vision.textDetector();
          final text = textDetector.processImage(InputImage.fromFilePath(_imageFile!.path));
          return Scaffold(
            // extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              toolbarHeight: 40,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            body: Column(
              children: [
                //SizedBox(height:,),
                Container(
                  height: MediaQuery.of(context).size.height*0.6,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                        blurRadius: 10.0),
                    BoxShadow(
                        color: Colors.black54,
                        offset: Offset(-2.0, 2.0),
                        blurRadius: 5.0),
                  ],),
                  child: Image.file(File(_imageFile!.path)),
                ),
                SizedBox(height: 10,),
                Expanded(
                  // height: 400,
                  child: FutureBuilder<RecognisedText>(
                    future: text,
                    builder: (context, ss) {
                      if(!ss.hasData){
                        return SpinningLogo();
                      }
                      else{
                        checkPlaceLegalId(ss.data!.text);
                        initSteps(findReceiptTotal(ss.data!.text));
                        return Stepper(
                          type: StepperType.horizontal,
                          physics: NeverScrollableScrollPhysics(),
                          currentStep: _currentStep,
                          //onStepTapped: (step) => onStepTapped(step),  
                          controlsBuilder: (context, {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) => Container(
                            child: ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                RaisedButton(
                                  color: Colors.orange[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                                    child: Text(
                                      "Da",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                      ),
                                    ),
                                  ),
                                  onPressed: onStepContinue,
                                ),
                                SizedBox(width: 20,),
                                RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                                    child: Text(
                                      "Nu",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                      ),
                                    ),
                                  ),
                                  onPressed: onStepCancel,
                                ),
                              ],
                            ),
                          ),
                          onStepCancel: (){
                            setState(() {
                              _currentStep--;                              
                            });
                          },
                          onStepContinue: (){
                            setState(() {
                              _currentStep < _steps.length-1 ? _currentStep++ : _currentStep=_currentStep;                              
                            });
                          },
                          steps: _steps,
                      );
                      }
                    }
                  ),
                )
              ],
            ),
          );
          // return Scaffold(
          //   body: FutureBuilder(
          //     future: text,
          //     builder: (context, AsyncSnapshot<RecognisedText> text) {
          //       if(!text.hasData)
          //         return SpinningLogo();
          //       else{
          //         findReceiptTotal(text.data.text);
          //         return Center(
          //           child: ListView(
          //             children: text.data.textBlocks.map((block) => 
          //               Text(
          //                 block.blockText + "\n"
          //               )
          //             ).toList()
          //           ),
          //         );
          //       }
          //     }
          //   )
          // );

        }
      }
    );
  }
}