import 'package:hyuga_app/models/locals/local.dart';

int selectedWhere;
int selectedWhat;
int selectedHowMany;
int selectedAmbiance;
int selectedArea;

void resetSearchParameters(){
  selectedWhere = selectedWhat = selectedHowMany = selectedAmbiance = selectedArea = null;
}

/// Used around the app to check for an eventual active SnackBar
bool isSnackBarActive = false;
bool isStarting = true;
bool isIOS = false; // Added for the AppleID Sign In method (only available on IOS)
bool isNewUser = false;

List<Local> placesList = [];

Map<String,int> selectedOptions = {
  'Categorie':selectedWhere, // 'Where?'
  'Specific':selectedWhat,  // 'What?'
  'Numar persoane':selectedHowMany, //'How many?'
  'Ambienta':selectedAmbiance //'Ambiance'
};
 /// Where-to-go list
final List<String> whereList = ["Cafè","Restaurant","Pub"];
 /// What list
final List<List<String>> whatList = [["Coffee","Tea","Lemonade","Smoothie","Board Games"],
                ["Burger","Italian","Local","Asian","Oriental","Sushi"],
                ["Beer","Cocktail","Wine"]]; 
 /// How Many List
final List<String> howManyList = 
                  ['Forever Alone','Me & my date','3-4','5-8','8+'];
 /// Ambiance list
final List<String> ambianceList = ["Intimate","Anything","Social-friendly"];
 /// Area list
final List<String> areaList = ["15 minute walk", "Anywhere"];

final List<Map<String, Object>> discounts = [
    {
      'maxim' : 15,
      'per_level' : [10, 10, 12.5, 14, 14.5, 15]
    },
    {
      'maxim' : 20,
      'per_level' : [12.5, 12.5, 15, 16.5, 18, 20]
    },
    {
      'maxim' : 25,
      'per_level' : [15, 15, 17.5, 20, 22.5, 25]
    },
    {
      'maxim' : 30,
      'per_level': [15, 15, 20, 22.5, 25, 30]
    },
    { 'maxim' : 35,
      'per_level' : [17.5, 17.5, 25, 30, 32.5, 35]
    },
    {
      'maxim' : 40,
      'per_level' : [25, 25, 30, 32.5, 35, 40]
    },
    {
      'maxim' : 45,
      'per_level' : [30, 30, 35, 37.5, 40, 45]
    },
    {
      'maxim' : 50,
      'per_level' : [40, 40, 45, 50, 50, 50]
    },
];
