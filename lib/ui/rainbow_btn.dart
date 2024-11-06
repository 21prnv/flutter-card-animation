import 'package:flutter/material.dart';
import 'dart:math' as math;

class RainbowLine extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;
  final double glowIntensity;
  final double glowSpread;
  final String text;
  final Function() onTap;
  const RainbowLine(
      {Key? key,
      this.width = 300.0,
      this.height = 4.0,
      this.duration = const Duration(seconds: 2),
      this.glowIntensity = 0.1,
      this.glowSpread = 10.0,
      required this.onTap,
      required this.text})
      : super(key: key);

  @override
  _RainbowLineState createState() => _RainbowLineState();
}

class _RainbowLineState extends State<RainbowLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 30,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onTap,
                child: Center(
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RainbowLinePainter(
                      progress: _controller.value,
                      height: widget.height,
                      glowIntensity: widget.glowIntensity,
                      glowSpread: widget.glowSpread,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RainbowLinePainter extends CustomPainter {
  final double progress;
  final double height;
  final double glowIntensity;
  final double glowSpread;

  RainbowLinePainter({
    required this.progress,
    required this.height,
    required this.glowIntensity,
    required this.glowSpread,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    // Center the line vertically in the available space
    final double yOffset = (size.height - height) / 2;

    // Create the base rect for the line
    final Rect baseRect = Rect.fromLTWH(0, yOffset, size.width, 1);

    // Create the larger rect for the glow effect
    final Rect glowRect = Rect.fromLTWH(
      0,
      yOffset - glowSpread,
      size.width,
      height + (glowSpread * 2),
    );

    final gradient = LinearGradient(
      colors: [
        ...colors,
        ...colors,
      ],
      stops: List.generate(14, (index) => index / 13),
      transform: GradientRotation(progress * 2 * math.pi),
    );

    // Draw multiple layers of glow with increasing blur
    for (int i = 3; i >= 0; i--) {
      final double blurSigma = (i + 1) * 4.0;
      final Paint glowPaint = Paint()
        ..shader = gradient.createShader(glowRect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma)
        ..style = PaintingStyle.fill
        ..color = Colors.white.withOpacity(glowIntensity / (i + 1));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          glowRect,
          Radius.circular((height + glowSpread) / 2),
        ),
        glowPaint,
      );
    }

    // Draw the main line
    final Paint mainPaint = Paint()
      ..shader = gradient.createShader(baseRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        baseRect,
        Radius.circular(height / 2),
      ),
      mainPaint,
    );

    // Add a final highlight layer
    final Paint highlightPaint = Paint()
      ..shader = gradient.createShader(baseRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        baseRect,
        Radius.circular(height / 2),
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(RainbowLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
