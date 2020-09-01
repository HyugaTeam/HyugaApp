import 'package:flutter/material.dart';

class ReservationPanel extends StatefulWidget {
  @override
  _ReservationPanelState createState() => _ReservationPanelState();
}

class _ReservationPanelState extends State<ReservationPanel> {

  static DateTime chosenDate;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          // constraints: BoxConstraints(
          //   maxHeight: MediaQuery.of(context).size.height*0.8,
          //   maxWidth: 500
          // ),
          color: Colors.white,
            width: double.infinity,
            height: MediaQuery.of(context).size.height*0.6,
            child: Column(
              children: <Widget>[
                Text("Numar persoane:"),
                Container(
                  height: 50,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 12,
                    itemBuilder: (context,index) => Chip(
                      label: Text(index.toString())
                    )
                  ),
                )
              ],
            )
            // child: Stepper(
            //   //type: StepperType.horizontal,
            //   currentStep: _currentStep,
            //   onStepContinue: (){
            //     switch(_currentStep){
            //       case 0: setState(() {
                    
            //       });
            //       break;
            //     }
            //     setState(() {
            //       _currentStep++;
            //     });
            //   },
              
            //   steps: [
            //     Step(
            //       state: StepState.editing,
            //       title: Text("Alege data"),
            //       content: CalendarDatePicker(
            //         initialDate: DateTime.now(), 
            //         firstDate: DateTime.now(), 
            //         lastDate: DateTime.now().add(Duration(days: 7)), 
            //         onDateChanged: (date){
            //           setState(() {
            //             chosenDate = date;
            //           });
            //         },
            //         initialCalendarMode: DatePickerMode.day,
            //       ),
            //       //subtitle: ,
            //       //isActive: true
            //     ),
            //     Step(
            //       state: StepState.editing,
            //       title: Text("2"),
            //       content: Text("")
            //     ),
            //   ]
            // ),
          ),
    );
  }
}