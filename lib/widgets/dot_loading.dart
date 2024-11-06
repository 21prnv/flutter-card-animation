import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class CircleDrop extends StatefulWidget {
  @override
  _CircleDropState createState() => _CircleDropState();
}

class _CircleDropState extends State<CircleDrop> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  List<double> _ballPositionsY = [];
  final double _groundLevel = 500.0;
  final int _ballCount = 5; // Number of balls
  final double _ballRadius = 25.0;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_ballCount, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 3),
      );
    });

    _animations = List.generate(_ballCount, (index) {
      GravitySimulation gravitySimulation = GravitySimulation(
        9.81, // Gravity force
        0.0, // Start position (top)
        _groundLevel, // Ground level (bottom)
        0.0, // Initial velocity
      );

      // Each animation should use its corresponding controller
      _controllers[index].animateWith(gravitySimulation);

      // Listener to update the ball's Y-position
      _controllers[index].addListener(() {
        setState(() {
          _ballPositionsY[index] =
              gravitySimulation.x(_controllers[index].value);
        });
      });

      // Return an empty animation as we are driving it manually
      return AlwaysStoppedAnimation<double>(0.0);
    });

    // Initialize Y positions of balls
    _ballPositionsY = List.filled(_ballCount, 0.0);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiple Balls Drop with Gravity'),
      ),
      body: Stack(
        children: [
          for (int i = 0; i < _ballCount; i++)
            Positioned(
              top: _ballPositionsY[i],
              left: MediaQuery.of(context).size.width /
                      (_ballCount + 1) *
                      (i + 1) -
                  _ballRadius,
              child: CircleAvatar(
                radius: _ballRadius,
                backgroundColor: Colors.blueAccent,
              ),
            ),
          // Ground level indicator
          Positioned(
            top: _groundLevel + _ballRadius,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
