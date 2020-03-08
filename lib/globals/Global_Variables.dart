int selectedWhere = 0;
int selectedWhat ;
int selectedHowMany;
int selectedAmbiance;
int selectedArea;
Map<String,int> selectedOptions = {'Where?':selectedWhere, 'What?':selectedWhat, 
                       'How many?':selectedHowMany, 'Ambiance':selectedAmbiance};
 /// Where-to-go list
final List<String> whereList = ["Cafè","Restaurant","Pub"];
 /// What list
final List<List<String>> whatList = [["Coffee","Tea","Lemonade","Smoothie","Board Games"],
                ["Burger","Italian","Local","Asian","Vegan","Oriental"],
                ["Beer","Cocktail","Wine","Shot"]]; 
 /// How Many List
final List<String> howManyList = 
                  ['Forever Alone','Me and my date','3-4','5-8','8+'];
 /// Ambiance list
final List<String> ambianceList = ["Intimate","Anything","Social-friendly"];
 /// Area list
final List<String> areaList = ["A 15 minute walk", "Anywhere"];
