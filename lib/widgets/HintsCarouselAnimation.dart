import 'package:flutter/material.dart';

class HintsCarousel extends StatefulWidget {
  @override
  _HintsCarouselState createState() => _HintsCarouselState();
}

class _HintsCarouselState extends State<HintsCarousel> with TickerProviderStateMixin{

  Animation<Offset> _animation;
  AnimationController _controller;
  List<String> _text = ["Breath in","Breath out"];
  int index = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    )..addListener(() {
      //print(_controller.value);
      // if(_controller.value < 0.1)
      //   ok = 
      //if(_controller.repeat())
      if(_controller.value > 0.9){
        //print(_controller.value);
        setState(() {
          index = 1-index;
        });
        _controller.reset();
        _controller.forward();
      }
      
    });
    //..repeat();
    _animation = Tween<Offset>(
      begin: Offset(-10,0),
      end: Offset(10,0)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.slowMiddle
    )); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return Container(
      height: 100,
      width: 100,
      child: SlideTransition(
        position: _animation,
        child: Text(
          _text[index],
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic
          ),
        ),
      ),
    );
  }
}