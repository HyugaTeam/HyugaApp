import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        child: Theme(
            data: ThemeData(
              iconTheme: IconThemeData(
                
              )
            ),
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
                thickness: 2,
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
                  title: Text("Venituri generate cu Hyuga"),
                  //subtitle: Text("(clienti/vizualizare)"),
                  trailing: Text("2%")
              ),
            ],
          ),
        )
      ),
    );
  }
}