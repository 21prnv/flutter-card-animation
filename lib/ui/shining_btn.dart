import 'package:flutter/material.dart';

class ShiningButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const ShiningButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = 200,
    this.height = 50,
  }) : super(key: key);

  @override
  _ShiningButtonState createState() => _ShiningButtonState();
}

class _ShiningButtonState extends State<ShiningButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 19, 18, 18),
            Color.fromARGB(255, 19, 18, 18),
            Color.fromARGB(255, 19, 18, 18),
            Color.fromARGB(255, 59, 59, 59),
            Color.fromARGB(255, 27, 26, 26),
            Color.fromARGB(255, 19, 18, 18),
            Color.fromARGB(255, 27, 26, 26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Add a border that will be visible behind the shine
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // Base button with shadow
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            // Button content
            Center(
              child: Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Top border shine
            Positioned(
              left: widget.width * _animation.value - widget.width,
              top: 0,
              child: Container(
                width: widget.width,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom border shine
            Positioned(
              left: widget.width * _animation.value - widget.width,
              bottom: 0,
              child: Container(
                width: widget.width,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            // Main shine effect
            Positioned(
              left: widget.width * _animation.value - 50,
              top: -35,
              child: Transform.rotate(
                angle: 2.61799,
                child: Container(
                  width: 12,
                  height: widget.height * 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0),
                      ],
                      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Clickable area
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: widget.onPressed,
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
