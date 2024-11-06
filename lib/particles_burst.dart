import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBurstAnimation extends StatefulWidget {
  @override
  _ParticleBurstAnimationState createState() => _ParticleBurstAnimationState();
}

class Particle {
  double x;
  double y;
  double dx;
  double dy;
  double size;
  double opacity;
  Color color;
  static const gravity = 0.15; // Gravity constant
  static const drag = 0.98; // Air resistance

  Particle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.size,
    required this.opacity,
    required this.color,
  });

  void update() {
    // Apply gravity
    dy += gravity;

    // Apply air resistance
    dx *= drag;
    dy *= drag;

    // Update position
    x += dx;
    y += dy;

    // Fade out faster as particle falls
    opacity *= 0.96;
  }
}

class _ParticleBurstAnimationState extends State<ParticleBurstAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  List<Particle> particles = [];
  bool isParticleBurst = false;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..addListener(() {
        if (_controller.value > 0.5 && !isParticleBurst) {
          _createParticles();
          isParticleBurst = true;
        }
        if (_controller.value < 0.5) {
          isParticleBurst = false;
        }
        setState(() {});
      });

    _circleAnimation = Tween<double>(
      begin: 300.0,
      end: 100.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  Color _generateRandomColor() {
    final List<Color> colors = [
      Colors.blue[400]!,
      Colors.purple[400]!,
      Colors.cyan[400]!,
      Colors.pink[400]!,
      Colors.green[400]!,
      Colors.yellow[400]!,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _createParticles() {
    particles.clear();
    for (int i = 0; i < 50; i++) {
      double angle = random.nextDouble() * 2 * pi;
      // Increased initial velocity for more dramatic burst
      double speed = 5 + random.nextDouble() * 7;
      particles.add(
        Particle(
          x: _circleAnimation.value,
          y: _circleAnimation.value,
          dx: cos(angle) * speed,
          dy: sin(angle) * speed - 2, // Initial upward boost
          size: 2 + random.nextDouble() * 3,
          opacity: 1.0,
          color: _generateRandomColor(),
        ),
      );
    }
  }

  void _updateParticles(Size size) {
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update();

      // Remove particles that are no longer visible
      if (particles[i].opacity < 0.1 ||
          particles[i].y > size.height ||
          particles[i].x < 0 ||
          particles[i].x > size.width) {
        particles.removeAt(i);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 400,
            height: 400,
            child: LayoutBuilder(
              builder: (context, constraints) {
                _updateParticles(
                    Size(constraints.maxWidth, constraints.maxHeight));
                return CustomPaint(
                  painter: ParticlePainter(
                    circleY: _circleAnimation.value,
                    particles: particles,
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              particles.clear();
              _controller.reset();
              _controller.forward();
            },
            child: Text('Launch Circle'),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double circleY;
  final List<Particle> particles;

  ParticlePainter({
    required this.circleY,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw main circle
    if (circleY > 150) {
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      // Add glow to main circle
      paint.maskFilter = MaskFilter.blur(BlurStyle.outer, 10);
      canvas.drawCircle(
        Offset(size.width / 2, circleY),
        20,
        paint,
      );

      // Draw solid circle
      paint.maskFilter = null;
      canvas.drawCircle(
        Offset(size.width / 2, circleY),
        20,
        paint,
      );
    }

    // Draw particles
    for (var particle in particles) {
      // Draw particle glow
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, 3);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 2,
        glowPaint,
      );

      // Draw particle core
      final corePaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
