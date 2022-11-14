import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:provider/provider.dart';

class ScannedCodesHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    ManagedPlace _managedLocal = Provider.of<ManagedPlace>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_managedLocal.analytics!['scanned_codes'].length.toString() + ' scanari'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _managedLocal.analytics!['scanned_codes'].length,
          itemBuilder: (context,index) => ListTile(
            title: Text("Data:   " + 
            DateTime.fromMillisecondsSinceEpoch(
            _managedLocal.analytics!['scanned_codes'][index].data()['date_start'].millisecondsSinceEpoch, isUtc: true)
            .toLocal().toString()
            ),
            subtitle: Text("Suma: "+_managedLocal.analytics!['scanned_codes'][index].data()['total'].toString()),
          ),
        )
      ),
    );
  }
}