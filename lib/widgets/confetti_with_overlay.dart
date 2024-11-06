import 'dart:math';
import 'package:flutter/material.dart';

class ButtonBurstConfettiPage extends StatefulWidget {
  @override
  _ButtonBurstConfettiPageState createState() =>
      _ButtonBurstConfettiPageState();
}

class _ButtonBurstConfettiPageState extends State<ButtonBurstConfettiPage>
    with TickerProviderStateMixin {
  late List<RealisticConfettiParticle> _particles;
  late AnimationController _animationController;
  final GlobalKey _buttonKey = GlobalKey();
  late OverlayEntry _overlayEntry;
  @override
  void initState() {
    super.initState();
    _particles = [];
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
      ..addListener(() {
        for (var particle in _particles) {
          particle.update(_animationController.value);
        }
        if (_overlayEntry != null) {
          _overlayEntry.markNeedsBuild();
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _removeOverlay();
        }
      });
  }

  void _removeOverlay() {
    _overlayEntry.remove();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _showOverlay();
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    // Offset the starting position of confetti to be above the button
    final double confettiStartY =
        buttonPosition.dy - 150; // 20 pixels above the button

    setState(() {
      _particles = List.generate(
        100,
        (index) => RealisticConfettiParticle(
          x: buttonPosition.dx + buttonSize.width / 2, // Center horizontally
          y: confettiStartY, // Slightly above the button
        ),
      );
    });
    _animationController.forward(from: 0);
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => CustomPaint(
        painter: RealisticConfettiPainter(_particles),
        size: Size.infinite,
      ),
    );

    Overlay.of(context).insert(_overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ElevatedButton(
          key: _buttonKey,
          onPressed: _startAnimation,
          child: Text('Burst Confetti!'),
        ),
      ],
    );
  }
}

class RealisticConfettiParticle {
  late double x;
  late double y;
  late Color color;
  late double size;
  late double vx;
  late double vy;
  late double angularVelocity;
  late double angle;
  late double opacity;
  final double gravity = 980;
  final double drag = 0.05;
  final double minOpacity = 0.2;

  RealisticConfettiParticle({required this.x, required this.y}) {
    reset();
  }

  void reset() {
    Random random = Random();
    color = Color((random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    size = random.nextDouble() * 8 + 2;
    double speed = random.nextDouble() * 300 + 200;
    double angle = random.nextDouble() * pi / 2 +
        pi / 4; // Upward angle between 45 and 135 degrees
    vx = speed *
        cos(angle) *
        (random.nextBool() ? 1 : -1); // Random left or right direction
    vy = -speed * sin(angle); // Upward velocity
    angularVelocity = random.nextDouble() * 10 - 5;
    this.angle = random.nextDouble() * 2 * pi;
    opacity = 1.0;
  }

  void update(double t) {
    double dt = 1 / 60; // Assuming 60 FPS

    // Update position
    x += vx * dt;
    y += vy * dt;

    // Apply gravity
    vy += gravity * dt;

    // Apply drag (air resistance)
    vx *= (1 - drag);
    vy *= (1 - drag);

    // Update rotation
    angle += angularVelocity * dt;

    // Fade out over time, but keep a minimum opacity
    opacity = max(1.0 - t * 1.5, minOpacity);
  }
}

class RealisticConfettiPainter extends CustomPainter {
  final List<RealisticConfettiParticle> particles;

  RealisticConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.angle);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.6),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
