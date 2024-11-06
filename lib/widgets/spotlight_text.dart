import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SpotlightText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final double shineRadius;
  final double width;
  const SpotlightText(
      {super.key,
      required this.text,
      required this.textStyle,
      required this.shineRadius,
      required this.width});

  @override
  State<SpotlightText> createState() => _SpotlightTextState();
}

class _SpotlightTextState extends State<SpotlightText> {
  Offset? hoverPosition;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        onHover: (event) {
          setState(() {
            hoverPosition = event.localPosition;
          });
        },
        onExit: (event) {
          setState(() {
            hoverPosition = null;
          });
        },
        child: CustomPaint(
          painter: _TextPainter(
              text: widget.text,
              textStyle: widget.textStyle,
              hoverPosition: hoverPosition,
              width: widget.width,
              shineRadius: widget.shineRadius),
          size: const Size(400, double.infinity),
        ),
      ),
    );
  }
}

class _TextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final Offset? hoverPosition;
  final double width;
  final double shineRadius;
  _TextPainter(
      {required this.text,
      required this.textStyle,
      this.hoverPosition,
      required this.width,
      required this.shineRadius});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: null);

    textPainter.layout(maxWidth: width);

    textPainter.paint(canvas, Offset.zero);

    if (hoverPosition != null) {
      final shineGradient = ui.Gradient.radial(hoverPosition!, shineRadius, [
        Colors.white.withOpacity(1),
        Colors.white.withOpacity(0.7),
        Colors.white.withOpacity(0.5),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0),
      ], [
        0.0,
        0.25,
        0.5,
        0.75,
        1.0
      ]);

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
