import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';



/// The service that handles all In-App Purchases
class IAP{
  
  static final IAP _instance = new IAP._privateConstructor();

  Future<bool> initialized = Future.value(false);

   /// IAP Plugin Interface
  static InAppPurchase _iap = InAppPurchase.instance;
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Checks if the IAP API is available on this device
  static bool? _isIapAvailable;

  /// Products for sale
  static List<ProductDetails> _products = [];

  
  /// Past Purchases
  static List<PurchaseDetails> _purchases = [];

  static late StreamSubscription _subscription; 

  static final List<String> _testIDs = ['first_subscription', 'first_subscription_yearly'];  

  /// Fetches the available products
  Future<void> _getProducts() async{
    print(_products.toString()+ "PPPPPPPPPPPPPPPPPPPPPPPPPPPP");
    Set<String> ids = Set.from(_testIDs); 
    print(ids.toString()+ "ids");
    try{
      print("START QUERYING PRODUCT DETAILS");
      ProductDetailsResponse response = await _iap.queryProductDetails(ids);
      print(response.notFoundIDs.toString() + " NOT FOUND ");
      print("GGGGGGGGGGGGGGGGGGGG");
      _products = response.productDetails;
      print(_products.toString()+ "PPPPPPPPPPPPPPPPPPPPPPPPPPPP");
    }
    catch(err){
      print(err);
    }
  }
  /// Gets past purchases
  Future<void> _getPastPurchases() async{
    
  }

  void buySubscription(String? productID){
    // print(_isIapAvailable);
    // print(_products);
    try{
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: _products.where((product) => product.id == productID).first
      );
      print("sm");
      _iap.buyNonConsumable(
        purchaseParam: purchaseParam
      );
    }
    catch(err){
      print(err);
    }
  }

  /// Handles the events whenever the purchaseStream updates
  void _handlePurchase(List<PurchaseDetails> purchaseDetailsList){
    purchaseDetailsList.forEach((purchaseDetails) { 
      if(purchaseDetails.status == PurchaseStatus.purchased){
        ///showPendingUI
        print("Pending purchase");
        var userPurchaseRef = _db.collection('users').doc(authService.currentUser!.uid).collection('purchases').doc();
        userPurchaseRef.set(
          {
            "date_purchased": Timestamp.fromDate(DateTime.now().toUtc()),
            "purchase_token": purchaseDetails.purchaseID,
            "product_id": purchaseDetails.productID
          },
          SetOptions(merge: true)
        );
      }
    });
  }

  void _verifyPurchases(){
    
  }

  Future initialize() async{

    /// Check availability of the API
    _isIapAvailable = await _iap.isAvailable();
    
    print("is IAP available: " + _isIapAvailable.toString());
    
    if(_isIapAvailable != null && _isIapAvailable == true){
      /// Fetches the available products
      /// Fetches the past purchases
      /// We're doing this concurrently so it's done
      List<Future> futures = [_getProducts(), _getPastPurchases()];
      await Future.wait(futures);
    }


    _subscription = _iap.purchaseStream.listen((purchaseDetailsList) {
      _handlePurchase(purchaseDetailsList);
    });

    initialized = Future.value(true);
  }

  IAP._privateConstructor(){
    /// Enables the In-App Purchase connection (only for Android)
    print(defaultTargetPlatform);
    if (defaultTargetPlatform == TargetPlatform.android) {
      InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    }
  }

  factory IAP(){
    return _instance;
  }

}