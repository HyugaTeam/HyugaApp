import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hyuga_app/widgets/LocalsList.dart';
import 'package:hyuga_app/widgets/drawer.dart';

class DiscountLocalsPage extends StatefulWidget {
  @override
  _DiscountLocalsPageState createState() => _DiscountLocalsPageState();
}

class _DiscountLocalsPageState extends State<DiscountLocalsPage> {
  final ScrollController _scrollController = ScrollController();

  bool _showAppbar = true; //this is to show app bar
  ScrollController _scrollBottomBarController =
      new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  bool _show = true;
  double bottomBarHeight = 75; // set bottom bar height
  double _bottomBarOffset = 0;

  void addToFavorites(int index) {}

  void myScroll() async {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
        }
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    myScroll();
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
            body: Locals(onlyWithDiscounts: true,
          )
        )
      );
  }
}
