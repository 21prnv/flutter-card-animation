import 'dart:math' as math;
import 'package:flutter/material.dart';

class Skyshot extends StatefulWidget {
  final Color color;
  final double width;
  final double height;

  const Skyshot(
      {super.key,
      required this.color,
      required this.width,
      required this.height});

  @override
  State<Skyshot> createState() => _SkyshotState();
}

class _SkyshotState extends State<Skyshot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Initialize particles
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(random));
    }

    _controller.addListener(() {
      if (_controller.value >= 0.8) {
        setState(() {
          // Update particle positions
          for (var particle in particles) {
            particle.update();
          }
        });
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SkyshotBurstPainter(
            progress: _controller.value,
            color: widget.color,
            particles: particles,
          ),
          size: Size(widget.width, widget.height),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double speedX;
  double speedY;
  double size;
  double opacity;

  final math.Random random;

  Particle(this.random)
      : x = 0,
        y = 0,
        speedX = (random.nextDouble() - 0.5) * 15,
        speedY = (random.nextDouble() - 0.5) * 15,
        size = random.nextDouble() * 8 + 2,
        opacity = 1.0;

  void update() {
    x += speedX;
    y += speedY;
    speedY += 0.2; // gravity
    opacity *= 0.95; // fade out
    size *= 0.97; // shrink
  }

  void reset(double startX, double startY) {
    x = startX;
    y = startY;
    speedX = (random.nextDouble() - 0.5) * 15;
    speedY = (random.nextDouble() - 0.5) * 15;
    size = random.nextDouble() * 8 + 2;
    opacity = 1.0;
  }
}

class SkyshotBurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<Particle> particles;

  SkyshotBurstPainter({
    required this.progress,
    required this.color,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the water drop
    final Paint dropPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double moveProgress = math.min(1.0, progress * 1.25);

    // Calculate the current position of the drop
    final double currentY = size.height * (1 - moveProgress);

    // Draw the water drop path
    path.moveTo(size.width / 2, currentY + size.height * 0.1);
    // ... (rest of the water drop path drawing code remains the same)

    canvas.drawPath(path, dropPaint);

    // Draw burst particles when progress is past 80%
    if (progress >= 0.8) {
      final Paint particlePaint = Paint()..style = PaintingStyle.fill;

      // Reset particles if they just started
      if (progress <= 0.81) {
        for (var particle in particles) {
          particle.reset(size.width / 2, size.height * 0.9);
        }
      }

      // Draw each particle
      for (var particle in particles) {
        particlePaint.color = color.withOpacity(particle.opacity);
        canvas.drawCircle(
          Offset(particle.x + size.width / 2, particle.y + size.height * 0.9),
          particle.size,
          particlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SkyshotBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
