  
import 'dart:typed_data';
/// Returns the full asset path for a specific file
String localAsset(String fileName){
  return "assets/icons/$fileName.png";
}

String localSvgAsset(String fileName){
  return "assets/icons/$fileName.svg";
}
Uint8List cloudAsset(String fileName){
  return kAssets[fileName];
}

/// Initialized in 'WrapperHomePageProvider's getData() method
var kAssets = {};