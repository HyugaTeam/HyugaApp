import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hyuga_app/widgets/LocalsList.dart';
import 'package:hyuga_app/widgets/drawer.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final ScrollController _scrollController = ScrollController();

  ScrollController _scrollBottomBarController =
      new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75; // set bottom bar height

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        drawer: ProfileDrawer(),
        backgroundColor: Theme.of(context).backgroundColor,
        body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  centerTitle: true,
                  title: Text(
                    'hyuga',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 25
                    ),
                  ),
                  backgroundColor: Colors.blueGrey,
                  pinned: false,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ];
            },
            body: Locals()));
  }
}
