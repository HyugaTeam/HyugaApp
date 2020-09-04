import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationPanel extends StatefulWidget {
  @override
  _ReservationPanelState createState() => _ReservationPanelState();
}

class _ReservationPanelState extends State<ReservationPanel> {

  static DateTime chosenDate;
  // int _currentStep = 0;
  int _selectedNoOfPeople = 1;
  int _selectedDay = 0;
  DateTime currentTime = DateTime.now().toLocal();

  @override
  Widget build(BuildContext context) {

    print(Platform.localeName);

    return Theme(
      data: ThemeData(
        textTheme: TextTheme(bodyText1: TextStyle(fontWeight: FontWeight.bold)),
        fontFamily: 'Comfortaa'
      ),
      child: Dialog(
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
                  SizedBox(height: 10,),
                  Text(
                    "Rezerva o masa",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(thickness: 10,),
                  SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                  Text(
                    "Cate persoane?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  SizedBox(height: 13,),
                  Container(
                    height: 50,
                    width: double.infinity,
                    child: ListView.separated(
                      controller: ScrollController(
                        initialScrollOffset: MediaQuery.of(context).size.width*0.16
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: 12,
                      separatorBuilder: (context,index)=>SizedBox(width: 10,),
                      itemBuilder: (context,index) => GestureDetector(
                        onTap: (){
                          setState(() {
                            _selectedNoOfPeople = index;
                          });
                        },
                        child: Chip(
                          backgroundColor: index == _selectedNoOfPeople ? Colors.orange[600]: Colors.grey[200],
                          labelPadding: EdgeInsets.symmetric(horizontal: 20),
                          label: Text((index+1).toString())
                        ),
                      )
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    "In ce zi?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  SizedBox(height: 13,),
                  Container(
                    height: 50,
                    width: double.infinity,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      separatorBuilder: (context,index)=>SizedBox(width: 10,),
                      itemBuilder: (context,index) => GestureDetector(
                        onTap: (){
                          setState(() {
                            _selectedDay = index;
                          });
                        },
                        child: Chip(
                          backgroundColor: index == _selectedDay ? Colors.orange[600]: Colors.grey[200],
                          labelPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('EEEE').format(currentTime.add(Duration(days: index))).substring(0,3),
                              ),
                              Text(
                                currentTime.add(Duration(days: index)).day.toString() 
                                + ' ' +
                                DateFormat('MMMM').format(currentTime.add(Duration(days: index))).substring(0,3),
                              )
                            ],
                          )
                        ),
                      )
                    ),
                  ),
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
      ),
    );
  }
}