import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/history/history_provider.dart';
import 'package:hyuga_app/screens/reservation/reservation_provider.dart';

class CancelReservationPopupPage extends StatelessWidget {
  const CancelReservationPopupPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<ReservationPageProvider>();
    var reservationsPageProvider;
    try{
      context.watch<HistoryPageProvider>();
    }
    catch(error){}
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: 200,
      child: Container(
        padding: EdgeInsets.only(top: 20),
        // height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text("Sunteți sigur că vreți să anulați rezervarea?", style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),),
            ),
            provider.isLoading
            ? Container(
              height: 5,
              width: MediaQuery.of(context).size.width,
              child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), backgroundColor: Colors.transparent,)
            )
            : Container(), 
            Container(
              width: MediaQuery.of(context).size.width,
              child: FloatingActionButton.extended(
                shape: ContinuousRectangleBorder(),
                elevation: 0,
                onPressed: () async{
                  await provider.cancelReservation()
                  .then((value){
                    if(reservationsPageProvider != null)
                      reservationsPageProvider.getData(context);
                    Navigator.pop(context);
                  });
                },
                label: Text("Anulează", style: Theme.of(context).textTheme.headline4,)
              ),
            ),
          ],
        ),
      )
    );
  }
}