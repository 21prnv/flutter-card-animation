import 'package:flutter/material.dart';

class GradientText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final List<Color> colors;
  final Duration duration;
  const GradientText(
      {super.key,
      this.text = "Animatrix is crazy",
      this.fontSize = 20,
      this.fontWeight = FontWeight.bold,
      this.duration = const Duration(seconds: 2),
      this.colors = const [Colors.blue, Colors.green, Colors.red]});

  @override
  State<GradientText> createState() => _GradientTextState();
}

class _GradientTextState extends State<GradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
                    colors: widget.colors,
                    stops: [0.0, 0.5, 1.0],
                    tileMode: TileMode.mirror,
                    transform: GradientRotation(_controller.value * 2 * 3.14))
                .createShader(bounds);
          },
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
            ),
          ),
        );
      },
    );
  }
}
