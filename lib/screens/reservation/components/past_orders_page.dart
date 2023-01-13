// import 'package:flutter/material.dart';

// class PastOrdersPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var pastOrders = 
//     return Scaffold(
//         body: ScrollConfiguration(
//           behavior: ScrollBehavior(androidOverscrollIndicator: AndroidOverscrollIndicator.stretch),
//           child: ListView.separated(
//             separatorBuilder: (context, index) => SizedBox(height: 20), 
//             itemCount: pastOrders == null ? 1 : pastOrders.length,
//             itemBuilder: (context, index) {
//               if(pastOrders == null)
//                 return Container(
//                   padding: EdgeInsets.only(top: 95),
//                   height: 100,
//                   child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
//                 );
//               else {
//                 var order = pastOrders[index];
//                 return Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: MaterialButton(
//                         padding: EdgeInsets.zero,
//                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>
//                           ChangeNotifierProvider.value(
//                             value: provider,
//                             child: OrderItemPage(order),
//                           )
//                         )).whenComplete(() => provider.getData()),
//                         child: Container(
//                           color: Theme.of(context).highlightColor,
//                           //padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                           height: 100,
//                           child: Row(
//                             children: [
//                               SizedBox(width: 20,),
//                               Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Comandă la ${formatDateToHourAndMinutes(order.dateCreated)}", style: Theme.of(context).textTheme.labelMedium),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           )
//                         ),
//                       ),
//                     ),
//                     ],
//                   ),
//                 );
//               }
//             }, 
//           ),
//         )
//       ),
//   }
// }