import 'package:flutter/material.dart';
import 'dart:math' as math;

class GradientBeamAnimation extends StatefulWidget {
  final Widget child;
  final double strokeWidth;
  final List<Color> colors;
  final Duration duration;

  const GradientBeamAnimation({
    Key? key,
    required this.child,
    this.strokeWidth = 2.0,
    this.colors = const [Colors.blue, Colors.purple, Colors.red],
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  _GradientBeamAnimationState createState() => _GradientBeamAnimationState();
}

class _GradientBeamAnimationState extends State<GradientBeamAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GradientBeamPainter(
        animation: _controller,
        strokeWidth: widget.strokeWidth,
        colors: widget.colors,
      ),
      child: widget.child,
    );
  }
}

class _GradientBeamPainter extends CustomPainter {
  final Animation<double> animation;
  final double strokeWidth;
  final List<Color> colors;

  _GradientBeamPainter({
    required this.animation,
    required this.strokeWidth,
    required this.colors,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = SweepGradient(
        colors: colors,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        tileMode: TileMode.clamp,
        transform: GradientRotation(animation.value * math.pi * 2),
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()..addRect(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GradientBeamPainter oldDelegate) =>
      animation != oldDelegate.animation;
}
