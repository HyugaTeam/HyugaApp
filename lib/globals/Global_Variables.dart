import 'package:hyuga_app/models/locals/local.dart';

int selectedWhere;
int selectedWhat;
int selectedHowMany;
int selectedAmbiance;
int selectedArea;

/// Used around the app to check for an eventual active SnackBar
bool isSnackBarActive = false;
bool isStarting = true;

List<Local> placesList = [];

Map<String,int> selectedOptions = {'Where?':selectedWhere, 'What?':selectedWhat, 
                       'How many?':selectedHowMany, 'Ambiance':selectedAmbiance};
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
