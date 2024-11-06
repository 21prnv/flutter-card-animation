import 'dart:math';
import 'package:flutter/material.dart';

class GlowingParticles extends StatefulWidget {
  final int numberOfParticles;
  final Color particleColor;

  const GlowingParticles({
    Key? key,
    this.numberOfParticles = 50,
    this.particleColor = Colors.white,
  }) : super(key: key);

  @override
  _GlowingParticlesState createState() => _GlowingParticlesState();
}

class _GlowingParticlesState extends State<GlowingParticles>
    with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    particles = List.generate(widget.numberOfParticles, (index) => Particle());
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            particles.forEach((particle) =>
                particle.move(constraints.maxWidth, constraints.maxHeight));
            return CustomPaint(
              painter: ParticlePainter(particles, widget.particleColor),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            );
          },
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double speed;
  late double theta;

  Particle() {
    restart();
  }

  void restart() {
    Random random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    speed = 0.001 + random.nextDouble() * 0.002;
    theta = random.nextDouble() * 2 * pi;
  }

  void move(double width, double height) {
    x += speed * cos(theta);
    y += speed * sin(theta);

    if (x < 0 || x > 1 || y < 0 || y > 1) {
      restart();
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color particleColor;

  ParticlePainter(this.particles, this.particleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = particleColor
      ..style = PaintingStyle.fill;

    particles.forEach((particle) {
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        1,
        paint..color = particleColor.withOpacity(0.8),
      );

      // Add glow effect
      final glowPaint = Paint()
        ..color = particleColor.withOpacity(0.1)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        2,
        glowPaint,
      );
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
