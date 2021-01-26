import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpinningLogo(),
          ],
        ),
      ),
    );
  }
}

class SpinningLogo extends StatefulWidget {
  @override
  _SpinningLogoState createState() => _SpinningLogoState();
}

class _SpinningLogoState extends State<SpinningLogo> with TickerProviderStateMixin{
  
  AnimationController _animationController;
  Color _animationColor;
  Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      vsync: this,
      duration: Duration(milliseconds: 1500)
    )..addListener(() {
      if(_animationController.value < 0.25 || _animationController.value > 0.75)
        setState(() {
          _animationColor = Colors.orange[600];
        });
      else
        setState(() {
            _animationColor = Colors.blueGrey;
          
        });
    })
    ..repeat();
    _animation = Tween<double>(
      begin: 0,
      end:  1
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.slowMiddle
    )); 

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          Positioned( // Spinning point
            child: RotationTransition(
              alignment: Alignment(10, 0),
              turns: _animation,
              child: Container(
                padding: EdgeInsets.only(left: 30),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: _animationColor,
                ),
              ),
            ),
            left: 45,
            top: 95,
          ),
          Positioned( // Hyuga Logo
            child: Image.asset("assets/images/hyuga-logo.png", width: 40,),
            left: 80,
            top: 80
          ),
        ],
      ),
    );
  }
}