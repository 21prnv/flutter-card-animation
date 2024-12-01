import 'package:flutter/material.dart';
import 'dart:math';

class GlowingStarsPainter extends CustomPainter {
  final List<Offset> starPositions;
  final double glowFactor;

  GlowingStarsPainter({required this.starPositions, required this.glowFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * glowFactor);

    // Draw stars
    for (var position in starPositions) {
      canvas.drawCircle(position, 5 + 5 * glowFactor, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class GlowingStarsText extends StatefulWidget {
  @override
  _GlowingStarsTextState createState() => _GlowingStarsTextState();
}

class _GlowingStarsTextState extends State<GlowingStarsText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Offset> _starPositions = [];

  @override
  void initState() {
    super.initState();

    // Generate random star positions above the text
    _starPositions = List.generate(5, (index) {
      return Offset(
          Random().nextDouble() * 200, Random().nextDouble() * 100 - 50);
    });

    // Animation controller for glowing effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing stars
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(200, 100),
                  painter: GlowingStarsPainter(
                    starPositions: _starPositions,
                    glowFactor: _animation.value,
                  ),
                );
              },
            ),
            // Text with a simple fade in and out animation
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: Text(
                      'Glowing Stars!',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
