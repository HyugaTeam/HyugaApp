import 'package:flutter/material.dart';
import 'package:hyuga_app/models/models.dart';
import 'package:hyuga_app/screens/manager/ScannedCodesHistoryPage.dart';
import 'package:hyuga_app/screens/manager_wrapper_home/manager_wrapper_home_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnalysisPage extends StatelessWidget {

  ManagedPlace? _managedLocal;

  @override
  Widget build(BuildContext context) {

    _managedLocal = Provider.of<ManagerWrapperHomePageProvider>(context).managedPlace;

    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20,),
            Center(
              child: Text(
                "Ultimele 30 de zile", 
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 50),
              title: Text("Venituri generate de Hyuga"),
              subtitle: Text("(ultimele 30 zile)"),
              trailing: Text(
                _managedLocal!.analytics!['thirty_days_income'].toString()+"\nRON"
              )
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 50),
              title: Text("Clienti adusi de Hyuga"),
              subtitle: Text("(ultimele 30 zile)"),
              trailing: Text(
                _managedLocal!.analytics!['thirty_days_guests'].toString()
              )
            ),
            Divider(
              thickness: 1,
            ),
            Center(
              child: Text(
                "Lifetime", 
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
            ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                title: Text("Venituri generate de Hyuga"),
                trailing: Text(_managedLocal!.analytics!['all_time_income'].toString()+"\nRON")
            ),
            ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                title: Text("Clienti adusi de Hyuga"),
                trailing: Text(_managedLocal!.analytics!['all_time_guests'].toString())
            ),
            Divider(thickness: 1,),
            Center(
              child: Text(
                "Facturi", 
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top : 20),
              child: Text("Factura curenta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
            ), 
            ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                title: Text("Valoare"),
                trailing: Text(_managedLocal!.analytics!['current_bill_total'].toStringAsFixed(2)+"\nRON")
            ),
            ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                title: Text("Data emisa"),
                trailing: Text(DateFormat("yyyy-MMM-dd").format(_managedLocal!.analytics!['emission_date']).toString())
            ),
            ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                title: Text("Data scadenta"),
                trailing: Text(
                  DateFormat("yyyy-MMM-dd").format(_managedLocal!.analytics!['maturity_date']).toString()
                )
            ),
            MaterialButton( /// Scan History button
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(
                    width: 1,
                    color: Colors.black26
                  )
                ),
              minWidth: double.infinity,
              height: MediaQuery.of(context).size.height*0.07,
              child: Center(child: Text("Istoric scanari", style: TextStyle(fontSize: 18),)),
              onPressed:(){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Provider(
                  create: (context)=> _managedLocal!,
                  child: ScannedCodesHistoryPage()
                )));
                
            }
              )
          ],
          )
      ),
    );
  }
}