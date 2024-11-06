import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ShiningText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const ShiningText({
    Key? key,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  @override
  _ShiningTextState createState() => _ShiningTextState();
}

class _ShiningTextState extends State<ShiningText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return ui.Gradient.linear(
              Offset(bounds.width * _controller.value - bounds.width / 4, 0),
              Offset(bounds.width * _controller.value + bounds.width / 4, 0),
              [
                Colors.transparent,
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.6),
                Colors.white.withOpacity(0.2),
                Colors.transparent,
              ],
              [0, 0.25, 0.5, 0.75, 1],
            );
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            widget.text,
            style: widget.textStyle,
          ),
        );
      },
    );
  }
}
