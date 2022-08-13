import 'package:flutter/material.dart';
import 'package:hyuga_app/services/analytics_service.dart';
import 'package:hyuga_app/services/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';


class SubscribePaymentPage extends StatefulWidget {

  @override
  _SubscribePaymentPageState createState() => _SubscribePaymentPageState();
}

class _SubscribePaymentPageState extends State<SubscribePaymentPage> {

  Map<String, String> subscriptionIDs = {
    "monthly_subscription" : "first_subscription",
    "yearly_subscription" : "first_subscription_yearly"
  };

  // void _verifyPurchases(){

  // }

  // ///Returns purchase of specific product ID
  // PurchaseDetails _hasPurchased(String productID){
  //   return _purchases.firstWhere((purchase) =>  purchase.productID == productID); 
  // }

  // /// Called within the initState method
  // void _initialize() async{
  
  //    [...]

  //     _subscription = _iap.purchaseStream.listen((data) { 
  //       setState(() {
  //         print("NEW PURCHASES COMPLETED");
  //         _purchases.addAll(data);
  //         _verifyPurchases();
  //       });
  //     }); 

  //   }
  // }  

  VoidCallback? _buySubscription(String? productID){
    switch(productID){
      case "first_subscription":
        AnalyticsService().analytics.logEvent(
          name: 'press_subscription_monthly',
        );
      break;
      case "first_subscription_yearly":
        AnalyticsService().analytics.logEvent(
          name: 'press_subscription_yearly',
        );
      break;
    }
    IAP().buySubscription(productID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "Premium",
          style: TextStyle(
            fontSize: 20*(1/MediaQuery.of(context).textScaleFactor),
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: FutureProvider<void>.value(
        value: IAP().initialized,
        initialData: null,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.1,),
                Text(
                  "Deblochează accesul nelimitat la toate ofertele și restaurantele",
                  //textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 40,),
                Text(
                  "Recuperezi costul abonamentului dintr-o singură ieșire la restaurant.",
                  //textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40,),
                ElevatedButton(                
                  style: ButtonStyle(
                    shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder?>(
                      (Set<MaterialState> states) {
                        return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)); // Use the component's default.
                      },
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        // if (states.contains(MaterialState.pressed))
                        //   return Theme.of(context).accentColor;
                        return Theme.of(context).primaryColor; // Use the component's default.
                      },
                    ),
                  ),
                  child: Container(
                    width: 150,
                    child: Text(
                      "Abonament 1 lună",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () => _buySubscription(subscriptionIDs['monthly_subscription']),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder?>(
                      (Set<MaterialState> states) {
                        return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)); // Use the component's default.
                      },
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Theme.of(context).primaryColor; // Use the component's default.
                      },
                    ),
                  ),
                  child: Container(
                    width: 150,
                    child: Text(
                      "Abonament 1 an",
                      textAlign: TextAlign.center,
                    )
                  ),
                  onPressed: () => _buySubscription(subscriptionIDs['yearly_subscription']),
                ),
              ],
            ),
          )
        
      ),
    );
  }
}