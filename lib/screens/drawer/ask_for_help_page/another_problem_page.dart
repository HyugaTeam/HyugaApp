import 'package:flutter/material.dart';

class AnotherProblemPage extends StatefulWidget {
  @override
  _AnotherProblemPageState createState() => _AnotherProblemPageState();
}

class _AnotherProblemPageState extends State<AnotherProblemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ajutor",
          style: TextStyle(
            fontSize: 20*(1/MediaQuery.of(context).textScaleFactor),
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 20
        ),
        // child: RichText(
        //   maxLines: 10,
        //   text: TextSpan(
        //     children: [
        //       TextSpan(
        //         text: "Ai întâmpinat vreo problemă de când folosești aplicația? Contactează-ne pe adresa "
        //       ),
        //       // TextSpan(
        //       //   text: "support@winestreet.ro" 
        //       // )
        //     ] 
        //   )
        // ),
        child: Text(
          "Ai întâmpinat vreo problemă de când folosești aplicația? Contactează-ne pe adresa support@winestreet.ro",
          style: TextStyle(
            fontSize: 18
          ),
        )
      ),
    );
  }
}