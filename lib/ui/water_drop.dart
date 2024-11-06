import 'package:flutter/material.dart';

class WaterDrop extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final bool shouldAnimate;

  const WaterDrop({
    super.key,
    this.width = 100,
    this.height = 140,
    this.color = Colors.blue,
    this.shouldAnimate = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: WaterDropPainter(color: color),
    );
  }
}

class WaterDropPainter extends CustomPainter {
  final Color color;

  WaterDropPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.7),
          color,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    // Moving starting point down slightly to create rounder top
    path.moveTo(size.width * 0.5, size.height * 0.1);

    // Right curve with more pronounced bulge at top
    path.cubicTo(
        size.width * 0.9,
        size.height * 0.2, // First control point - moved out for rounder head
        size.width * 0.8,
        size.height * 0.6, // Second control point
        size.width * 0.5,
        size.height // End point
        );

    // Left curve mirroring the right side
    path.cubicTo(
        size.width * 0.2,
        size.height * 0.6, // First control point
        size.width * 0.1,
        size.height * 0.2, // Second control point - moved out for rounder head
        size.width * 0.5,
        size.height * 0.1 // End point
        );

    path.close();

    // Add shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4, true);

    // Draw the main drop
    canvas.drawPath(path, paint);

    // Add larger shine effect for more dimension
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final shinePath = Path();
    // Adjusted shine to follow the rounder head shape
    shinePath.moveTo(size.width * 0.3, size.height * 0.15);
    shinePath.quadraticBezierTo(size.width * 0.45, size.height * 0.25,
        size.width * 0.35, size.height * 0.35);

    canvas.drawPath(shinePath, shinePaint);

    // Add additional highlight at the top for more roundness
    final topHighlight = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15),
        size.width * 0.2, topHighlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
