import 'package:location/location.dart';
import 'package:test/test.dart';
import 'package:hyuga_app/services/querying_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';


void main() {
  group('Testing Querying Service:', () {
    test('Fetch only places with available deals', () async{
      Firebase.initializeApp();
      final firestore = FakeFirebaseFirestore();  
      var result = await queryingService.fetchOnlyDiscounts();
      bool allTrue = true;
      result.forEach((element) {
        if(element.deals == null)
          allTrue = false;
        else if(element.deals!.isEmpty)
          allTrue = false;
      });
      expect(allTrue, true);
      //var number = 35;
      //favorites.add(number);
      //expect(favorites.items.contains(number), true);
    });
    // test('Returns list of places', () async{
    //   queryingService.userLocation = LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0});
    //   await Firebase.initializeApp();
    //   var firestore = FakeFirebaseFirestore();  
    //   var query = await firestore.collection('locals_bucharest')
    //   .where("partner", isEqualTo: true)
    //   .get();
    //   var places = queryingService.toLocal(query.docs);
    //   expect(places.every((element){
    //     if(element.isPartner == false)
    //       return false;
    //     return true;
    //   }), true);
    // });    
  });
}