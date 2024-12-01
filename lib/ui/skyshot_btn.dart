import 'package:animation_app/ui/rainbow_btn.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class FallingStarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multiple Particle Bursts',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Multiple Particle Bursts'),
        ),
        body: RisingStarAnimation(),
      ),
    );
  }
}

class Particle {
  late Offset position;
  late double speed;
  late double theta;
  late double radius;
  late Color color;

  // Predefined list of colors for particles
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
  ];

  Particle({required Offset startPos}) {
    position = startPos;
    speed = math.Random().nextDouble() * 1.0 + 0.5; // Slow down particles
    theta = math.Random().nextDouble() * 2 * math.pi;
    radius = math.Random().nextDouble() * 2.0 + 1.0;

    // Randomly select a color from the list with random opacity
    color = colors[math.Random().nextInt(colors.length)]
        .withOpacity(math.Random().nextDouble());
  }

  void update() {
    position += Offset(
      math.cos(theta) * speed,
      math.sin(theta) * speed,
    );
    radius *= 0.98;
    speed *= 0.98;
  }
}

class RisingStarAnimation extends StatefulWidget {
  @override
  _RisingStarAnimationState createState() => _RisingStarAnimationState();
}

class Burst {
  List<Particle> particles = [];
  bool showBurst;
  Offset burstPosition;

  Burst({required this.burstPosition}) : showBurst = true {
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(startPos: burstPosition));
    }
  }

  void updateParticles() {
    particles.forEach((p) => p.update());
    particles.removeWhere((p) => p.radius <= 0.1);
  }
}

class _RisingStarAnimationState extends State<RisingStarAnimation> {
  List<Burst> bursts = [];
  GlobalKey buttonKey = GlobalKey();
  // Get button position
  void _startMultipleBursts() {
    RenderBox renderBox =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
    List<Offset> burstPositions = [
      Offset(buttonPosition.dx - 10, buttonPosition.dy - 100),
      Offset(buttonPosition.dx + 100, buttonPosition.dy - 100),
      Offset(buttonPosition.dx + 200, buttonPosition.dy - 80),
      Offset(buttonPosition.dx + 50, buttonPosition.dy - 150),
    ];

    // Start multiple bursts at these positions
    for (var position in burstPositions) {
      Future.delayed(Duration(milliseconds: math.Random().nextInt(1000)), () {
        setState(() {
          bursts.add(Burst(burstPosition: position));
        });
        _animateParticles();
      });
    }
  }

  void _animateParticles() {
    Future.delayed(Duration(milliseconds: 32), () {
      // Increased delay between frames (32 ms for slower animation)
      setState(() {
        bursts.forEach((burst) {
          burst.updateParticles();
        });
        bursts.removeWhere((b) => b.particles.isEmpty);
      });

      if (bursts.isNotEmpty) {
        _animateParticles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black),
        ...bursts.map((burst) {
          return CustomPaint(
            painter: ParticleBurstPainter(burst.particles),
          );
        }).toList(),
        Center(
          child: RainbowLine(
            key: buttonKey,
            onTap: () {
              _startMultipleBursts();
            },
            text: 'Tap',
          ),
        )
      ],
    );
  }
}

class ParticleBurstPainter extends CustomPainter {
  final List<Particle> particles;

  ParticleBurstPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      // Create a glow paint for each particle
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            particle.color.withOpacity(0.8), // Use particle color for glow
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: particle.position, // Center glow at particle's position
          radius: particle.radius * 5, // Glow radius larger than the particle
        ))
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, 10); // Apply blur for soft glow

      // Draw the glowing effect
      canvas.drawCircle(particle.position, particle.radius * 5, glowPaint);

      // Draw the particle itself
      paint.color = particle.color;
      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
