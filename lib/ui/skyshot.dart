import 'dart:math' as math;
import 'package:flutter/material.dart';

class SkyshotApp extends StatefulWidget {
  @override
  _SkyshotAppState createState() => _SkyshotAppState();
}

class _SkyshotAppState extends State<SkyshotApp> {
  List<Offset> skyshotPositions = [];
  bool showSkyshots = false;
  final List<Color> skyshotColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  void triggerSkyshotsAroundButton(Offset buttonPosition) {
    setState(() {
      skyshotPositions = List.generate(5, (index) {
        double angle = (index * (2 * math.pi / 5)); // 5 particles in a circle
        double radius = 100.0; // Distance from button
        return Offset(
          buttonPosition.dx + radius * math.cos(angle),
          buttonPosition.dy + radius * math.sin(angle),
        );
      });
      showSkyshots = true;
    });

    // Stop the skyshots after 3 seconds
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        showSkyshots = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Button widget
        Center(
            child: SizedBox(
          height: 30,
          width: 90,
          child: Material(
            color: Colors.white,
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTapUp: (details) {
                final buttonPosition = details.globalPosition;

                triggerSkyshotsAroundButton(buttonPosition);
              },
              child: Center(
                child: Text(
                  "Lets go",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        )),
        // Skyshots burst around the button after click
        if (showSkyshots)
          ...List.generate(skyshotPositions.length, (index) {
            return Positioned(
              left: skyshotPositions[index].dx - 50, // Center skyshot
              top: skyshotPositions[index].dy - 500,
              child: Skyshot(
                color: skyshotColors[index],
                width: 100,
                height: 200,
                burstDelay: Duration(milliseconds: index * 400),
                burstDuration: Duration(
                    milliseconds:
                        (math.Random().nextDouble() * 2000).toInt() + 1000),
              ),
            );
          }),
      ],
    );
  }
}

class Skyshot extends StatefulWidget {
  final Color color;
  final double width;
  final double height;
  final Duration burstDelay;
  final Duration burstDuration;

  const Skyshot({
    super.key,
    required this.color,
    required this.width,
    required this.height,
    required this.burstDelay,
    required this.burstDuration,
  });

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
      duration: widget.burstDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          Future.delayed(widget.burstDelay, () {
            _controller.forward();
          });
        }
      });

    // Initialize particles with reduced size
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(random));
    }

    // Delay the start of the burst using Future.delayed
    Future.delayed(widget.burstDelay, () {
      _controller.forward();
    });

    _controller.addListener(() {
      if (_controller.value >= 0.8) {
        setState(() {
          // Update particle positions and fade out effect
          for (var particle in particles) {
            particle.update();
          }
        });
      }
    });
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
        // Slower particle movement by reducing speedX and speedY
        speedX = (random.nextDouble() - 0.5) * 7, // Reduced horizontal speed
        speedY = (random.nextDouble() - 0.5) * 7, // Reduced vertical speed
        size = random.nextDouble() * 5 + 1, // Particle size
        opacity = 1.0;

  void update() {
    x += speedX;
    y += speedY;
    speedY += 0.1; // Gravity, reduced for slower fall
    opacity *= 0.97; // Fade out gradually
    size *= 0.98; // Shrink over time
  }

  void reset(double startX, double startY) {
    x = startX;
    y = startY;
    speedX = (random.nextDouble() - 0.5) * 7; // Slower reset speed
    speedY = (random.nextDouble() - 0.5) * 7; // Slower reset speed
    size = random.nextDouble() * 5 + 1; // Reset particle size
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
    // You can continue to customize the shape if needed

    canvas.drawPath(path, dropPaint);

    // Draw burst particles when progress is past 80%
    if (progress >= 0.8) {
      final Paint particlePaint = Paint()
        ..style = PaintingStyle.fill; // Add glow effect

      // Reset particles if they just started
      if (progress <= 0.81) {
        for (var particle in particles) {
          particle.reset(size.width / 2, size.height * 0.9);
        }
      }

      // Draw each particle with fade-out, size reduction, and glow
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
