import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hyuga_app/widgets/clipper.dart';

class HelpWithDealPage extends StatefulWidget {
  @override
  _HelpWithDealPageState createState() => _HelpWithDealPageState();
}



class _HelpWithDealPageState extends State<HelpWithDealPage> {

  Image? _firstGIF;
  Image? _secondGIF;

  void _fetchGIFs(){
    _firstGIF = Image.network(
        "https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/gifs%2Ftutorial%2Fro%2Ffirst-slide.gif?alt=media&token=c96c3201-a34f-4783-851c-e232a2ad72ed"
        ,loadingBuilder: (context, child, loadingProgress){
          if(loadingProgress == null)
            return child;
          return CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          );
        },
      );
    _secondGIF = Image.network(
          "https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/gifs%2Ftutorial%2Fro%2Ffirst-slide.gif?alt=media&token=c96c3201-a34f-4783-851c-e232a2ad72ed"
          ,loadingBuilder: (context, child, loadingProgress){
            if(loadingProgress == null)
              return child;
            return CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            );
          },
        );
  }

  @override
  void initState() {
    super.initState();
    _firstGIF = Image.network(
      "https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/gifs%2Fhelp%2Ffirst-gif.gif?alt=media&token=6f5c5aab-f43a-4df5-a633-dfda4dd374d4"
      ,loadingBuilder: (context, child, loadingProgress){
        if(loadingProgress == null)
          return child;
        return CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
        );
      },
    );
    _secondGIF = Image.network(
      "https://firebasestorage.googleapis.com/v0/b/hyuga-app.appspot.com/o/gifs%2Fhelp%2Fsecond-gif.gif?alt=media&token=48a434ef-05b3-47dd-b380-becf5c2a3227"
      ,loadingBuilder: (context, child, loadingProgress){
        if(loadingProgress == null)
          return child;
        return CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
        );
      },
    );
  }

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
      body: ListView(
        shrinkWrap: true,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding( // Page Title
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width*0.08,
              vertical: MediaQuery.of(context).size.height*0.04
            ),
            child: Text(
              "Cum revendic o ofertă?",
              style: TextStyle(
                fontSize: 20*(1/MediaQuery.of(context).textScaleFactor),
                fontWeight: FontWeight.w700
              ),
            ),
          ),
          Container(
            //height: 200,
            child: Column(
              children: [
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.search,
                        size: 40,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Text(
                        "Caută un local în aplicație",
                        style: TextStyle(
                          fontSize: 20*(1/MediaQuery.of(context).textScaleFactor),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 270,
                  child: ClipRect(
                    clipper: MyClipper(),
                    child: _firstGIF
                  ),
                )
              ],
            ),
          ),
          Container(
            //height: 200,
            child: Column(
              children: [
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        Icons.book,
                        size: 40,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Text(
                        "Fă o rezervare",
                        style: TextStyle(
                          fontSize: 20*(1/MediaQuery.of(context).textScaleFactor),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 270,
                  child: ClipRect(
                    clipper: MyClipper(),
                    child: _secondGIF
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 30
          ),
          Container(
            height: 200,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.utensils,
                        size: 40,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: Text(
                          "Bucură-te de ofertele localului ales",
                          style: TextStyle(
                            fontSize: 20*(1/MediaQuery.of(context).textScaleFactor),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
