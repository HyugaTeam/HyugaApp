import 'dart:convert';
import 'dart:io';
import 'package:authentication/authentication.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/models/ticket/ticket.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
export 'package:provider/provider.dart';

class PaymentPageProvider with ChangeNotifier{

  bool isLoading = false;
  double? total;
  int? selectedNumberOfPeople = 1;
  String? selectedName = Authentication.auth.currentUser!.displayName;
  String? selectedEmail = Authentication.auth.currentUser!.email;
  String? selectedCategory;
  List<String?> listOfCategories;
  Map<String, dynamic> prices;
  Map<String, dynamic> originalPrices;
  List<int> listOfNumberOfPeople = [1,2,3,4,5,6,7,8];
  CardFormEditController cardFormEditController = CardFormEditController();
  Event event;

  PaymentPageProvider(this.event, this.listOfCategories, this.selectedCategory, this.prices, this.originalPrices){
    getData();
  }

  Future<void> getData() async{
    _loading();

    // final directory = (await getApplicationDocumentsDirectory());
    // final file = File("${directory.path}/../../../assets/templates/ticket.html");
    // print(file.path);
    var text = await rootBundle.loadString('assets/templates/ticket.html');
    print(text);
    total = (prices[selectedCategory]*selectedNumberOfPeople).toDouble();

    _loading();
  }
  
  Future<bool?> pay(BuildContext context) async{

    _loading();
    
    bool? result = null;

    /// Create payment method
    try{
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: Authentication.auth.currentUser!.email,
              name: Authentication.auth.currentUser!.displayName == null ? "" : Authentication.auth.currentUser!.displayName,
            )
          ) 
        ),
      );


      final paymentIntentResults = await _callPayEndpointMethodId(
        useStripeSdk: true,
        paymentMethodId: paymentMethod.id,
        currency: 'ron',
        value: total!*100,
      );

      if(paymentIntentResults['erorr'] != null){
        return null;
      }

      /// NO 3DS
      /// Payments completes succesfully
      if(paymentIntentResults['clientSecret'] != null && paymentIntentResults['requiresAction'] == null)
        result =  true;

      /// 3DS
      /// User needs to confirm the payment
      if(paymentIntentResults['clientSecret'] != null && paymentIntentResults['requiresAction'] == true){
        final String clientSecret = paymentIntentResults['clientSecret'];
        
        /// User needs to confirm the payment
        try{
          final paymentIntent = await Stripe.instance.handleNextAction(clientSecret);

          if(paymentIntent.status == PaymentIntentsStatus.RequiresConfirmation){
            /// We make the Stripe API call
            Map<String, dynamic> results = await _callPayEndpointIntentId(paymentIntentId: paymentIntent.id);
            /// On 'results' contains an error
            if(results['error'] != null){
              return null;
            }

          }

        }
        catch(e) {
          print(e.toString() + " error");
          return null;
        }

      }
      result = true;
    }
    /// The user didn't fill the card info correctly
    on StripeException
    catch(e){ 
      print(e.error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Datele cardului nu sunt corecte"),
      ));
      result = false;
    }


    _loading();
    
    notifyListeners();

    return result;
  }

  Future<Map<String, dynamic>> _callPayEndpointMethodId({
    required bool useStripeSdk, 
    required String paymentMethodId,
    required String currency,
    required double value
    }) async{
      final url = Uri.parse(
        "https://us-central1-hyuga-app.cloudfunctions.net/StripePayEndpointMethodId"
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'useStripeSdk': true,
            'paymentMethodId': paymentMethodId,
            'currency': 'ron',
            'value': value
          }
        )
      );
      print(response.body);
      return json.decode(response.body);
  }

  Future<Map<String, dynamic>> _callPayEndpointIntentId({
    required String paymentIntentId,
    }) async{
      final url = Uri.parse(
        "https://us-central1-hyuga-app.cloudfunctions.net/StripePayEndpointIntentId"
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'paymentIntentId': paymentIntentId,
          }
        )
      );
      return json.decode(response.body);
  }

  void handlePaymentError(BuildContext context, result) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("A aparut o eroare ${result}"),
    ));
  }

  ///TODO:
  Future<Ticket?> makeTicket() async{
    _loading();

    try{

      var user = Authentication.auth.currentUser;

      var userTicketRef = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('tickets').doc();
      var eventTicketRef = FirebaseFirestore.instance.collection('events').doc(event.id).collection('tickets').doc(userTicketRef.id);
      var ticketData = {
        'event_name': event.name,
        'event_id': event.id,
        'event_location_name' : event.locationName,
        'event_location': event.location,
        'guest_name': selectedName,
        'guest_id': user.uid,
        'number_of_people' : selectedNumberOfPeople,
        'category': selectedCategory,
        'original_price': originalPrices[selectedCategory],
        'price': prices[selectedCategory],
        'email': selectedEmail,
        'card_last_4': cardFormEditController.details.last4,
        'photo_url': event.photoUrl,
        'date_created': FieldValue.serverTimestamp(),
        'date_start': Timestamp.fromDate(event.dateStart),
        'date_end': Timestamp.fromDate(event.dateEnd!),
        'user_ticket_ref': userTicketRef,
        'event_ticket_ref': eventTicketRef,
      };
      print("before set");
      await userTicketRef.set(ticketData);
      await eventTicketRef.set(ticketData);
      
      /// Update the user's display name
      if(user.displayName == null && selectedName != ""){
        await FirebaseFirestore.instance.collection('users').doc(user.uid)
        .set(
          {
            'display_name' : selectedName
          },
          SetOptions(merge: true)
        );
        await user.updateDisplayName(selectedName);
      }

      _loading();

      print("after set ${selectedCategory}");
      
      ticketData.update("date_created", (_) => DateTime.now().toLocal());
      print(ticketData);
      return docWithIdAndDataAsArgsToTicket(
        userTicketRef.id,
        ticketData,
        eventTicketRef,
        userTicketRef
      );
    }
    catch(e){
      print(e.toString() + "eroare");
      return null;
    }
  }

  void updateTotal(){
    total = (prices[selectedCategory]*selectedNumberOfPeople).toDouble();

    notifyListeners();
  }

  void updateSelectedNumberOfPeople(int? numberOfPeople){
    selectedNumberOfPeople = numberOfPeople;
    updateTotal();
    notifyListeners();
  }

  void updateSelectedName(String? name){
    selectedName = name;
    notifyListeners();
  }

  void updateSelectedEmail(String? email){
    selectedEmail = email;
    notifyListeners();
  }

  _loading(){
    isLoading = !isLoading;

    notifyListeners();
  }

}


enum PaymentStatus{
  initial,
  loading,
  success,
  failure
}