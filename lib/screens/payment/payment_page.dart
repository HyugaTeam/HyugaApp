import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/history/history_provider.dart';
import 'package:hyuga_app/screens/payment/payment_provider.dart';
import 'package:hyuga_app/screens/ticket/ticket_page.dart';
import 'package:hyuga_app/screens/ticket/ticket_provider.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PaymentPageProvider>();
    var wrapperHomePageProvider = context.watch<WrapperHomePageProvider>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton.extended(
      //   heroTag: "payment",
      //   elevation: 0,
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30), bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30))),
      //   onPressed: provider.isLoading
      //   ? null
      //   : () async{
      //     var result = await provider.pay(context);
      //     if(result == null || result == false){
      //       provider.handlePaymentError(context, result);
      //     }
      //     else {
      //       var ticket = await provider.makeTicket();
      //       if(ticket != null){
      //         Navigator.popUntil(context, (route) => route.isFirst);
      //         Navigator.push(context, MaterialPageRoute(builder: (context)=>
      //           MultiProvider(
      //             providers: [
      //               ChangeNotifierProvider(create: (context) => TicketPageProvider(ticket, BarcodeWidget(barcode:  Barcode.code128(), data: ticket.id, drawText: false,))),
      //             ],
      //             child: TicketPage(),
      //           )
      //         ));
      //       }
      //     }

      //   },
      //   label: Container(
      //     alignment: Alignment.center,
      //     width: MediaQuery.of(context).size.width*0.4,
      //     child: provider.isLoading
      //     ? CircularProgressIndicator(color: Theme.of(context).canvasColor)
      //     : Text(
      //       "Plătește ${removeDecimalZeroFormat(provider.total!)}RON",
      //       style: Theme.of(context).textTheme.headline6!.copyWith(
      //         fontSize: 16,
      //         color: Colors.white
      //         ),
      //     ),
      //   )
      // ),
      appBar: AppBar(
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Cumpără bilet",
              ),
            ],
          ),
        ),
        centerTitle: true,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //     child: CircleAvatar(
        //       backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
        //       child: Image.asset(localAsset("more"), width: 22, color: Theme.of(context).primaryColor,),
        //       radius: 30,
        //     ),
        //   )
        // ],
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            radius: 40,
            child: IconButton(
                // alignment: Alignment.centerRight,
                color: Theme.of(context).colorScheme.secondary,
                //padding: EdgeInsets.symmetric(horizontal: 20),
                onPressed: () => Navigator.pop(context),
                icon: Image.asset(
                  localAsset("left-arrow"),
                  width: 18,
                  color: Theme.of(context).canvasColor,
                )),
          ),
        ),
      ),
      body: Form(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(left: 40, right: 40, bottom: 40),
            child: Column(
              // padding: EdgeInsets.symmetric(horizontal: 40),
              // shrinkWrap: true,
              children: [
                /// Number of people
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.people,
                            color: Theme.of(context).primaryColor,
                            size: 19,
                          ),
                          backgroundColor: Theme.of(context).highlightColor,
                          radius: 15,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Număr persoane",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    Container(
                      //width: 100,
                      child: DropdownButton(
                          value: provider.selectedNumberOfPeople,
                          // isExpanded: true,
                          items: provider.listOfNumberOfPeople
                              .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e.toString(),
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  )))
                              .toList(),
                          onChanged: provider.updateSelectedNumberOfPeople),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),

                /// Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                            size: 19,
                          ),
                          backgroundColor: Theme.of(context).highlightColor,
                          radius: 15,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Nume",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    Container(
                      // height: 100,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextFormField(
                        initialValue: provider.selectedName,
                        style: Theme.of(context).textTheme.labelMedium,
                        onChanged: provider.updateSelectedName,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20)),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),

                /// Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.email_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 19,
                          ),
                          backgroundColor: Theme.of(context).highlightColor,
                          radius: 15,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Email",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    Container(
                      // height: 100,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        initialValue: provider.selectedEmail,
                        onChanged: provider.updateSelectedEmail,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20)),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    CircleAvatar(
                      child: Icon(
                        Icons.credit_card,
                        color: Theme.of(context).primaryColor,
                        size: 19,
                      ),
                      backgroundColor: Theme.of(context).highlightColor,
                      radius: 15,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Card",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  return CardFormField(
                    style: CardFormStyle(
                      borderWidth: 0,
                      borderRadius: 20,
                      textColor: Colors.white,
                      cursorColor: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.background,
                    ),
                    controller: provider.cardFormEditController,
                    enablePostalCode: false,
                  );
                }),
                Spacer(),
                MaterialButton(
                    // heroTag: "payment",
                    elevation: 0,
                    color: Theme.of(context).colorScheme.tertiary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30))),
                    // onPressed: (){

                    // },
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            var result = await provider.pay(context);
                            if (result == null || result == false) {
                              provider.handlePaymentError(context, result);
                            } else {
                              var ticket = await provider.makeTicket();
                              if (ticket != null) {
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                                wrapperHomePageProvider
                                    .updateSelectedScreenIndex(2);

                                /// Update tickets history
                                if (wrapperHomePageProvider
                                        .historyPageProvider !=
                                    null) {
                                  wrapperHomePageProvider.historyPageProvider!
                                      .getData();
                                  if (wrapperHomePageProvider
                                          .historyPageProvider!.viewType ==
                                      ViewType.reservations)
                                    wrapperHomePageProvider.historyPageProvider!
                                        .changeViewType();
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MultiProvider(
                                              providers: [
                                                ChangeNotifierProvider(
                                                    create: (context) =>
                                                        TicketPageProvider(
                                                            ticket,
                                                            BarcodeWidget(
                                                              barcode: Barcode
                                                                  .code128(),
                                                              data: ticket.id,
                                                              drawText: false,
                                                            ))),
                                                ChangeNotifierProvider.value(
                                                    value:
                                                        wrapperHomePageProvider)
                                              ],
                                              child: TicketPage(),
                                            )));
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Biletul a fost înregistrat! Mulțumim că ai achiziționat un bilet prin Wine Street!")));
                              }
                            }
                          },
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: provider.isLoading
                          ? CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.tertiary)
                          : Text(
                              "Plătește ${removeDecimalZeroFormat(provider.total!)}RON",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(fontSize: 16, color: Colors.white),
                            ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _finishPayment(
    BuildContext context,
    PaymentPageProvider provider,
  ) {
    //   provider.makeReservation(ticket, returnTicket, tripPageProvider, arrivalTripPageProvider)
    //   .then((newTicket){
    //     Navigator.popUntil(context, (route) => route.isFirst);
    //     // wrapperHomePageProvider.pageController.jumpToPage(0);
    //     wrapperHomePageProvider.updateSelectedScreenIndex(1);
    //     Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
    //       create: (_) => TicketPageProvider(newTicket),
    //       child: TicketPage(),
    //     )));
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           ticket.passengersNo == 1
    //           ? "Confirmarea biletului dumneavoastră a fost trimisă pe email"
    //           : "Confirmarea biletelor dumneavoastră a fost trimisă pe fiecare adresă de email"
    //         ),
    //       )
    //     );
    //   });
  }
}
