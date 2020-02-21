int selectedWhere ;
int selectedWhat ;
int selectedHowMany;
int selectedAmbiance;
Map<String,int> selectedOptions = {'Where?':selectedWhere, 'What?':selectedWhat, 
                       'How many?':selectedHowMany, 'Ambiance':selectedAmbiance};

final List<String> whereList = ["Cafè","Restaurant","Pub"]; /// Where-to-go list
final List<List<String>> whatList = [["Coffee","Tea","Lemonade","Smoothie"], /// What list
                ["Burger","Pizza","Local","Asian","Vegan","Oriental"],
                ["Beer","Craft Beer","Cocktail","Wine","Shot"]]; 
final List<String> howManyList = ['Forever Alone','Me and my date','3-5','6-8','8+']; /// How Many List
final List<String> ambianceList = ["Intimate","Calm","Social-friendly"]; ///ambiance list

  ///TODO Add a widget for the selected Area
