import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveButton extends StatefulWidget {
  @override
  _WaveButtonState createState() => _WaveButtonState();
}

class _WaveButtonState extends State<WaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _buttonPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation(TapDownDetails details) {
    setState(() {
      _buttonPosition = details.localPosition;
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _startAnimation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: WavePainter(
            buttonPosition: _buttonPosition,
            animation: _controller,
          ),
          child: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Click me'),
            ),
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Offset buttonPosition;
  final Animation<double> animation;

  WavePainter({required this.buttonPosition, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(1 - animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height);
    final radius = maxRadius * animation.value;

    canvas.drawCircle(buttonPosition, radius, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
