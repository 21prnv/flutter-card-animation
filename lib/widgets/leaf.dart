import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:svg_flutter/svg.dart';

class FallingLeavesScreen extends StatefulWidget {
  @override
  _FallingLeavesScreenState createState() => _FallingLeavesScreenState();
}

class _FallingLeavesScreenState extends State<FallingLeavesScreen> {
  final List<String> leafImages = [
    'assets/leaf1.svg',
    'assets/leaf2.svg',
    'assets/leaf3.svg',
    'assets/leaf4.svg',
    // Add more leaf image paths as needed
  ];

  final int minLeaves = 5;
  final int maxLeaves = 15;
  late List<FallingLeaf> leaves;

  @override
  void initState() {
    super.initState();
    _createLeaves();
  }

  void _createLeaves() {
    final random = math.Random();
    final leafCount = minLeaves + random.nextInt(maxLeaves - minLeaves + 1);

    leaves = List.generate(leafCount, (_) {
      return FallingLeaf(
        image: leafImages[random.nextInt(leafImages.length)],
        startPosition: Offset(
          random.nextDouble() * 400, // Adjust based on screen width
          -100 - random.nextDouble() * 500, // Start above the screen
        ),
        endPosition: Offset(
          random.nextDouble() * 400, // Adjust based on screen width
          900 + random.nextDouble() * 100, // End below the screen
        ),
        size: 30 + random.nextDouble() * 30, // Random size between 30 and 60
        duration: Duration(seconds: 5 + random.nextInt(6)), // 5 to 10 seconds
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: leaves,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _createLeaves();
          });
        },
        child: Icon(Icons.replay),
      ),
    );
  }
}

class FallingLeaf extends StatefulWidget {
  final String image;
  final Offset startPosition;
  final Offset endPosition;
  final double size;
  final Duration duration;

  FallingLeaf({
    required this.image,
    required this.startPosition,
    required this.endPosition,
    required this.size,
    required this.duration,
  });

  @override
  _FallingLeafState createState() => _FallingLeafState();
}

class _FallingLeafState extends State<FallingLeaf>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = Offset.lerp(
        widget.startPosition, widget.endPosition, _animation.value)!;

    return Positioned(
      left: currentPosition.dx,
      top: currentPosition.dy,
      child: Transform.rotate(
        angle: math.sin(_animation.value * 6 * math.pi) * 0.2,
        child: SvgPicture.asset(
          widget.image,
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}
