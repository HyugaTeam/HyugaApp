import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyuga_app/globals/Global_Variables.dart' as g;
import 'package:hyuga_app/services/auth_service.dart';
import 'package:hyuga_app/widgets/clipper.dart';

class SlideShowIntro extends StatefulWidget {
  @override
  _SlideShowIntroState createState() => _SlideShowIntroState();
}

class _SlideShowIntroState extends State<SlideShowIntro> with TickerProviderStateMixin{
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

  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300)
    );
    _animation = CurvedAnimation(
      parent: _animationController, 
      curve: Curves.bounceInOut
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context){
          _animationController.forward();
          return ScaleTransition(
            scale: _animation,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          splashColor: Colors.orange[600],
                          onPressed: () {
                            g.isNewUser = false;
                            authService.loading.add(false);
                          },
                          child: Text(
                            'Sari peste',
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
                            Padding( /// First Slide
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
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
                                  ),
                                  Text(
                                    'Completeaza cele 5 intrebari scurte:\n+ tipul de local\n+ specificul dorit\n+ numarul de persoane\n+ atmosfera\n+ distanta fata de tine',
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
                                  SizedBox(height: 15,),
                                  SizedBox(
                                    width: 150,
                                    height: 270,
                                    child: ClipRect(
                                      clipper: MyClipper(),
                                      child: Image.network(
                                        "https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/gifs%2Ftutorial%2Fro%2Ffirst-slide.gif?alt=media&token=c96c3201-a34f-4783-851c-e232a2ad72ed"
                                        ,loadingBuilder: (context, child, loadingProgress){
                                          if(loadingProgress == null)
                                            return child;
                                          return CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                : null,
                                          );
                                        },
                                      )
                                    ),
                                  )
                                ],
                              ),
                            ),
                            //---------------------------------END OF SLIDE ONE--------------------------------------
                            Padding( /// Second Slide
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 30.0),
                                  Align(
                                    widthFactor: 10,
                                    child: Text(
                                      'Descopera cele mai mari reduceri!',
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
                                    "Toate reducerile si ofertele speciale sunt la un click distanta.",
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
                                    "Fiecare cerculet portocaliu indica reducerea de astazi din local.\nExploreaza lista pentru a gasi OFERTA care ti se potriveste.",
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
                                  SizedBox(height: 15,),
                                  SizedBox(
                                    width: 150,
                                    height: 270,
                                    child: ClipRect(
                                      clipper: MyClipper(),
                                      child: Image.network(
                                        "https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/gifs%2Ftutorial%2Fro%2Fsecond-slide.gif?alt=media&token=cf46f90d-7d05-4e89-a0ad-f292332e238b"
                                        ,loadingBuilder: (context, child, loadingProgress){
                                          if(loadingProgress == null)
                                            return child;
                                          return CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                : null,
                                          );
                                        },
                                      )
                                    ),
                                  )
                                ],
                              ),
                            ),
                            //---------------------------------END OF SLIDE TWO--------------------------------------
                            Padding( /// Third Slide
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: 150,
                                    height: 270,
                                    child: ClipRect(
                                      clipper: MyClipper(),
                                      child: Image.network(
                                        "https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/gifs%2Ftutorial%2Fro%2Fthird-slide.gif?alt=media&token=7fbf622c-35ef-41dc-a36a-c2bdbf8be157"
                                      )
                                    ),
                                  ),
                                  SizedBox(height: 30.0),
                                  Align(
                                    widthFactor: 10,
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [ 
                                          TextSpan(
                                            text: "Cum primesti ",
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
                                          ),
                                          TextSpan(
                                            text: "reducerea",
                                            style: TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 25,
                                              color: Colors.orange[600],
                                              fontWeight: FontWeight.w800,
                                              shadows: [
                                                Shadow(
                                                    offset: Offset(1, 1), blurRadius: 2.0)
                                              ],
                                            ),
                                          ),
                                          TextSpan(
                                            text: "?\nVarianta 1:",
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
                                          ),
                                        ]
                                      )
                                    ),
                                  ),
                                  SizedBox(height: 17.0),
                                  Text(
                                    'Cand ajungi in local, scaneaza codul tau unic.',
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
                                    //'Acesta iti in functie de ora la care a fost scanat codul!\nOrele si reducerile respective se afla pe profilul localului!',
                                    "Esti in oras si vrei sa obtii oferta/reducerea unui local Hyuga?\nDupa ce un angajat iti va scana codul, te poti bucura de experienta ta pana la venirea notei de plata",
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
                            Padding( /// Fourth Slide
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 15.0),
                                  Align(
                                    widthFactor: 10,
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [ 
                                          TextSpan(
                                            text: "Cum primesti ",
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
                                          ),
                                          TextSpan(
                                            text: "reducerea",
                                            style: TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 25,
                                              color: Colors.orange[600],
                                              fontWeight: FontWeight.w800,
                                              shadows: [
                                                Shadow(
                                                    offset: Offset(1, 1), blurRadius: 2.0)
                                              ],
                                            ),
                                          ),
                                          TextSpan(
                                            text: "?\nVarianta 2:",
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
                                          ),
                                        ]
                                      )
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    height: 270,
                                    child: ClipRect(
                                      clipper: MyClipper(),
                                      child: Image.network(
                                        "https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/gifs%2Ftutorial%2Fro%2Ffourth-slide.gif?alt=media&token=16c7d364-2a8d-483e-b9bc-40ff87ac7004"
                                        ,loadingBuilder: (context, child, loadingProgress){
                                          if(loadingProgress == null)
                                            return child;
                                          return CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                : null,
                                          );
                                        },
                                      )
                                    ),
                                  ),
                                  SizedBox(height: 15.0),
                                  Text(
                                    'Fa o rezervare intr-unul din localurile partenere',
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
                                  SizedBox(height: 17,),
                                  Text(
                                    'Planifici o iesire in oras? Fa o rezervare la unul dintre localuri si beneficiaza automat de reducerile si ofertele din acel interval orar.',
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 30.0),
                                  Align(
                                    widthFactor: 10,
                                    child: Text(
                                      'Cauta un local!',
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
                                  SizedBox(
                                    width: 150,
                                    height: 270,
                                    child: ClipRect(
                                      clipper: MyClipper(),
                                      child: Image.network(
                                        "https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/gifs%2Ftutorial%2Fro%2Ffifth-slide.gif?alt=media&token=4b71d43f-3c9a-4e2c-8e8a-d1b2010be379"
                                        ,loadingBuilder: (context, child, loadingProgress){
                                          if(loadingProgress == null)
                                            return child;
                                          return CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                : null,
                                          );
                                        },
                                      )
                                    ),
                                  ),
                                  SizedBox(height: 15.0),
                                  Text(
                                    //'Salveaza localurile preferate pentru a le putea accesa oricand la sectiunea "FAVORITE". Vezi unde este locatia exact prin Google Maps si comanda un Uber! Vizualizeaza menu-ul complet prin aplicatie!\nSi multe altele!',
                                    "Cauta localul tau preferat in aplicatia Hyuga si profita de reducerile acestuia. Fa o rezervare, vezi locatia exacta, studiaza meniul sau comanda un Uber!",
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
                                        'Urmatorul',
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
        );}
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

