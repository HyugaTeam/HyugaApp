import 'package:hyuga_app/config/paths.dart';
import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/history/history_provider.dart';

class EmptyTicketsList extends StatelessWidget {
  const EmptyTicketsList({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<HistoryPageProvider>();
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: provider.getData,
      child: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                localAsset("no-data"),
                //color: Colors.black54,
                width: 70,
              ),
              SizedBox(height: 20,),
              Text("Nu există evenimente trecute :(", style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 20, color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.54)))
            ],
          ),
        ),
      ),
    );
  }
}