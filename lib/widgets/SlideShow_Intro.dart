import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/services/auth_service.dart';

class SlideShowIntro extends StatefulWidget {
  @override
  _SlideShowIntroState createState() => _SlideShowIntroState();
}

class _SlideShowIntroState extends State<SlideShowIntro> {
  final int _numPages = 5;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.orange[600] : Colors.white24,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.3, 0.4, 0.6, 0.85],
              colors: [
                Color(0xFF607D8B),
                Color(0xFF616F8C),
                Color(0xFF69618C),
                Color(0xFF78618C),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    splashColor: Colors.orange[600],
                    onPressed: () => print('Start'),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 600.0,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Center(
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //         color: Colors.white,
                            //         borderRadius: BorderRadius.circular(32)),
                            //     child: Image(
                            //       image: AssetImage('assets/infinitea.jpg'),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 30.0),
                            Align(
                              widthFactor: 10,
                              child: Text(
                                'Gaseste localul perfect!',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1, 1), blurRadius: 2.0)
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 30.0,
                            ), // de ce nu face asta
                            Text(
                              'Completeaza cele 5 intrebari scurte:   + tipul de local\n+ specificul dorit\n+ numarul de persoane\n+ atmosfera\n+ distanta fata de tine',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.7,
                                shadows: [
                                  Shadow(offset: Offset(1, 1), blurRadius: 2.0)
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      //---------------------------------END OF SLIDE ONE--------------------------------------
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Center(
                            //   child: Image(
                            //     image: AssetImage('assets/infinitea.jpg'),
                            //   ),
                            // ),
                            SizedBox(height: 30.0),
                            Align(
                              widthFactor: 10,
                              child: Text(
                                'Descopera cele mai mari discounturi!',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1, 1), blurRadius: 2.0)
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'Cauta cerculetul portocaliu!           El semnalizeaza REDUCERILE!',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 19,
                                color: Colors.orange[600],
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                shadows: [
                                  Shadow(offset: Offset(2, 2), blurRadius: 5.0)
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Atunci cand vezi un cerculet portocaliu in coltul unui restaurant inseamna ca poti primi reduceri de pana la 50% sau oferte speciale!\nPentru a vedea exact discountul intra pe profilul localului!',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                shadows: [
                                  Shadow(offset: Offset(1, 1), blurRadius: 2.0)
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      //---------------------------------END OF SLIDE TWO--------------------------------------
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Center(
                            //   child: Image(
                            //     image: AssetImage('assets/infinitea.jpg'),
                            //   ),
                            // ),
                            SizedBox(height: 30.0),
                            Align(
                              widthFactor: 10,
                              child: Text(
                                'Cum primesti reducerea?     Pasul 1:',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1, 1), blurRadius: 2.0)
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 17.0),
                            Text(
                              'Cand ceri bonul informeaza un angajat al localului ca esti client Hyuga',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 20,
                                color: Colors.orange[600],
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                shadows: [
                                  Shadow(offset: Offset(2, 2), blurRadius: 3.0)
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 17.0),
                            Text(
                              'Acesta iti va scana codul unic si tu vei primi o reducere in functie de ora la care ai cerut nota de plata!\nOrele si reducerile respective se afla pe profilul localului!',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 16.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.6,
                                shadows: [
                                  Shadow(offset: Offset(1, 1), blurRadius: 2.0)
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      //---------------------------------END OF SLIDE THREE--------------------------------------
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Center(
                            //   child: Image(
                            //     image: AssetImage('assets/infinitea.jpg'),
                            //   ),
                            // ),
                            SizedBox(height: 40.0),
                            Align(
                              widthFactor: 10,
                              child: Text(
                                'Pasul 2:',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1, 1), blurRadius: 2.0)
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Pentru a ne asigura ca veti primi reducerea corecta si pentru a va proteja, angajatul localului va introduce suma pe care trebuie sa o platiti (dupa reducere) iar dumneavoastra o confirmati prin aplicatie!\nAsta este tot!',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(offset: Offset(1, 1), blurRadius: 2.0)
                                ],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      //---------------------------------END OF SLIDE FOUR--------------------------------------
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Center(
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //         color: Colors.white,
                            //         borderRadius: BorderRadius.circular(32)),
                            //     child: Image(
                            //       image: AssetImage('assets/infinitea.jpg'),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 30.0),
                            Align(
                              widthFactor: 10,
                              child: Text(
                                'BONUS!',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1, 1), blurRadius: 2.0)
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ), // de ce nu face asta
                            Text(
                              'Salveaza localurile preferate pentru a le putea accesa oricand la sectiunea "FAVORITE". Vezi unde este locatia exact prin Google Maps si comanda un Uber! Vizualizeaza menu-ul complet prin aplicatie!\nSi multe altele!',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.8,
                                shadows: [
                                  Shadow(offset: Offset(1, 1), blurRadius: 2.0)
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      //---------------------------------END OF SLIDE FIVE--------------------------------------
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                _currentPage != _numPages - 1
                    ? Expanded(
                        child: Align(
                          widthFactor: null,
                          alignment: FractionalOffset.bottomRight,
                          child: FlatButton(
                            //padding: EdgeInsets.only(right: 0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            splashColor: Colors.orange[600],
                            onPressed: () {
                              _pageController.nextPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.5,
                                    fontFamily: 'Comfortaa',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? Container(
              height: 100,
              width: double.infinity,
              color: Colors.orange[600],
              child: GestureDetector(
                onTap: () {
                  g.isNewUser = false;
                  authService.loading.add(false);
                } ,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text(
                      'Sa incepem!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontFamily: 'Comfortaa',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Text(''),
    );
  }
}

