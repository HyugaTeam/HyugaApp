import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:hyuga_app/models/locals/managed_local.dart';
import 'package:hyuga_app/screens/manager/ScannedCodesHistoryPage.dart';
import 'package:provider/provider.dart';

class AnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    ManagedLocal _managedLocal = Provider.of<AsyncSnapshot<dynamic>>(context).data;

    return Scaffold(
      
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(
              //dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 50),
              title: Text("Vizualizari in timp real"),
              //leading: Text("leading"),
              subtitle: Text("(ultimele 14 zile)"),
              trailing: Text("119")
            ),
            Divider(thickness: 1,),
            ListTile(
              //dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 50),
              title: Text("Venituri generate de Hyuga"),
              //leading: Text("leading"),
              subtitle: Text("(ultimele 30 zile)"),
              trailing: Text("??")
            ),
            ListTile(
              //dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 50),
              title: Text("Clienti adusi de Hyuga"),
              //leading: Text("leading"),
              subtitle: Text("(ultimele 30 zile)"),
              trailing: Text("??")
            ),
            ListTile(
                //dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                title: Text("Retentie utilizatori"),
                subtitle: Text("(clienti/vizualizare)"),
                trailing: Text("2%")
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
                //dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                title: Text("Vizualizari"),
                //subtitle: Text("(clienti/vizualizare)"),
                trailing: Text("2%")
            ),
            ListTile(
                //dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                title: Text("Venituri generate de Hyuga"),
                //subtitle: Text("(clienti/vizualizare)"),
                trailing: Text(_managedLocal.analytics['all_time_income'].toString()+"\nRON")
            ),
            //Divider(thickness: 2,),
            MaterialButton(
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
                  create: (context)=> _managedLocal,
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