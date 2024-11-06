import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class PartialShineText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final double width;

  const PartialShineText({
    Key? key,
    required this.text,
    required this.textStyle,
    required this.width,
  }) : super(key: key);

  @override
  _PartialShineTextState createState() => _PartialShineTextState();
}

class _PartialShineTextState extends State<PartialShineText> {
  Offset? _hoverPosition;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _hoverPosition = event.localPosition;
        });
      },
      onExit: (_) {
        setState(() {
          _hoverPosition = null;
        });
      },
      child: CustomPaint(
        painter: _TextPainter(
          text: widget.text,
          textStyle: widget.textStyle,
          hoverPosition: _hoverPosition,
          width: 300,
        ),
        size: Size(300, double.infinity),
      ),
    );
  }
}

class _TextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final Offset? hoverPosition;
  final double width;
  final double shineRadius = 40.0;

  _TextPainter({
    required this.text,
    required this.textStyle,
    this.hoverPosition,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    textPainter.layout(maxWidth: width);

    // Draw the base text
    textPainter.paint(canvas, Offset.zero);

    if (hoverPosition != null) {
      // Create a circular shine gradient
      final shineGradient = ui.Gradient.radial(
        hoverPosition!,
        shineRadius,
        [
          Colors.white.withOpacity(1),
          Colors.white.withOpacity(0.7),
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.0),
        ],
        [0.0, 0.25, 0.5, 0.75, 1.0],
      );

      // Apply the shine effect
      canvas.saveLayer(Offset.zero & size, Paint());
      textPainter.paint(canvas, Offset.zero);
      final shinePaint = Paint()
        ..blendMode = BlendMode.srcIn
        ..shader = shineGradient;
      canvas.drawCircle(hoverPosition!, shineRadius, shinePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
