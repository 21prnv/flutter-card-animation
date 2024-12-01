import 'dart:async';

import 'package:animation_app/ui/animated_list.dart';
import 'package:animation_app/ui/animated_list_left.dart';
import 'package:animation_app/ui/expanding_tile.dart';
import 'package:animation_app/ui/fade_text_animation.dart';
import 'package:animation_app/ui/glowing_star_text.dart';
import 'package:animation_app/ui/pop_push_list.dart';
import 'package:animation_app/ui/poppushlist.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(FallingStarApp());

class FallingStarApp extends StatelessWidget {
  final List<String> items = [
    'Getting Started',
    'Basic Concepts',
    'Advanced Features',
    'Best Practices',
    'Tips and Tricks',
    'Common Pitfalls',
    'Performance Tips',
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Falling Star Animation',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Falling Star Animation'),
        ),
        body: SlideFromSidesList(
          items: items,
          fromRight: true,
          itemDelay: const Duration(milliseconds: 200),
        ),
      ),
    );
  }
}

// class Particle {
//   late Offset position;
//   late double speed;
//   late double theta;
//   late double radius;
//   late Color color;

//   Particle({required Offset startPos, Color? color}) {
//     position = startPos;
//     speed = math.Random().nextDouble() * 2.0 + 1.0;
//     theta = math.Random().nextDouble() * 2 * math.pi;
//     radius = math.Random().nextDouble() * 2.0 + 1.0;
//     this.color = color ?? Colors.blue;
//   }

//   void update() {
//     position += Offset(
//       math.cos(theta) * speed,
//       math.sin(theta) * speed,
//     );
//     radius *= 0.98;
//     speed *= 0.98;
//   }
// }

// class FallingStarAnimation extends StatefulWidget {
//   @override
//   _FallingStarAnimationState createState() => _FallingStarAnimationState();
// }

// class Star {
//   final GlobalKey key = GlobalKey();
//   final Color color;
//   late AnimationController controller;
//   late Animation<Offset> animation;
//   bool showBurst = false;
//   final double speed;
//   Offset? burstPosition;
//   List<Particle> particles = [];
//   final double delay;

//   Star({
//     required this.color,
//     required TickerProvider vsync,
//     required this.speed,
//     required BuildContext context,
//     required this.delay,
//   }) {
//     controller = AnimationController(
//       duration: Duration(
//           milliseconds:
//               (4000 ~/ speed).toInt()), // Adjust duration based on speed
//       vsync: vsync,
//     );
//   }

//   void dispose() {
//     controller.dispose();
//   }
// }

// class _FallingStarAnimationState extends State<FallingStarAnimation>
//     with TickerProviderStateMixin {
//   List<Star> stars = [];
//   final int numberOfStars = 5; // Number of stars you want
//   Offset? topCenterOffset;
//   Offset? bottomCenterOffset;
//   // List of different star colors
//   final List<Color> starColors = [
//     Colors.blue,
//     Colors.purple,
//     Colors.pink,
//     Colors.orange,
//     Colors.green,
//     Colors.cyan,
//     Colors.amber,
//     Colors.indigo,
//     Colors.teal,
//   ];

//   final List<double> starSpeeds = [
//     1.0, // Slowest
//     1.3,
//     1.6,
//     1.9,
//     2.2,
//     1.5,
//     2.8,
//     1.1,
//     1.4, // Fastest
//   ];
//   double _getScreenBottomOffset(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final topPadding =
//         MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
//     final bottomPadding = MediaQuery.of(context).padding.bottom;
//     print(screenHeight);
//     print(topPadding);
//     // Use the fixed height of the SizedBox (300 in this case)
//     return ((topPadding + 800) / screenHeight) * 2 - 1;
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Create stars with different delays
//     for (int i = 0; i < numberOfStars; i++) {
//       stars.add(Star(
//         color: starColors[i % starColors.length],
//         speed: starSpeeds[i], // Assign fixed speed to each star
//         vsync: this,
//         context: context,
//         delay: i * 2,
//       ));
//     }
//   }

//   static double getScreenTopOffset(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final topPadding =
//         MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
//     return (topPadding / screenHeight) * 2 - 1;
//   }

//   void _initializeAnimations() {
//     final bottomOffset = _getScreenBottomOffset(context);
//     final topOffset = getScreenTopOffset(context);

//     for (var star in stars) {
//       // Random horizontal position for each star
//       double randomX =
//           (math.Random().nextDouble() * 2 - 1) * 2.0; // -0.8 to 0.8

//       star.animation = Tween<Offset>(
//         begin: Offset(randomX, topOffset - 2),
//         end: Offset(
//             randomX,
//             (300 / MediaQuery.of(context).size.height) * 4.5 -
//                 1), // Adjust to bottom of SizedBox
//       ).animate(CurvedAnimation(
//         parent: star.controller,
//         curve: Curves.linear,
//       ));

//       star.controller.addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           _handleStarBurst(star);
//         }
//       });

//       // Start animation with delay
//       Future.delayed(Duration(milliseconds: (star.delay * 2000).round()), () {
//         star.controller.forward();
//       });
//     }
//   }

//   void _handleStarBurst(Star star) {
//     final RenderBox? renderBox =
//         star.key.currentContext?.findRenderObject() as RenderBox?;
//     if (renderBox != null) {
//       final position = renderBox.localToGlobal(Offset.zero);
//       setState(() {
//         star.showBurst = true;
//         star.burstPosition = position +
//             Offset(renderBox.size.width / 2, renderBox.size.height / 2 - 40);
//         _initializeParticles(star);
//       });
//       _animateParticles(star);
//     }
//   }

//   void _initializeParticles(Star star) {
//     star.particles.clear();
//     if (star.burstPosition != null) {
//       for (int i = 0; i < 50; i++) {
//         star.particles.add(Particle(
//           startPos: star.burstPosition!,
//           color: star.color,
//         ));
//       }
//     }
//   }

//   void _animateParticles(Star star) {
//     if (!star.showBurst) return;

//     Future.delayed(Duration(milliseconds: 13), () {
//       setState(() {
//         for (var particle in star.particles) {
//           particle.update();
//         }
//       });

//       if (star.particles.any((p) => p.radius > 0.1)) {
//         _animateParticles(star);
//       } else {
//         setState(() {
//           star.showBurst = false;
//           star.controller.reset();
//           star.controller.forward();
//         });
//       }
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _initializeAnimations();
//   }

//   @override
//   void dispose() {
//     for (var star in stars) {
//       star.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black,
//       height: 300,
//       child: Stack(
//         children: [
//           ...stars.map((star) {
//             if (!star.showBurst) {
//               return Center(
//                 child: SlideTransition(
//                   position: star.animation,
//                   child: CustomPaint(
//                     key: star.key,
//                     size: Size(100, 100),
//                     painter: FallingStarPainter(color: star.color),
//                   ),
//                 ),
//               );
//             } else if (star.showBurst && star.burstPosition != null) {
//               return Positioned(
//                 left: 0,
//                 top: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: CustomPaint(
//                   painter: ParticleBurstPainter(star.particles),
//                 ),
//               );
//             }
//             return Container();
//           }).toList(),
//         ],
//       ),
//     );
//   }
// }

// class FallingStarPainter extends CustomPainter {
//   final Color color;

//   FallingStarPainter({this.color = Colors.blue});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 4;

//     final trailPaint = Paint()
//       ..shader = RadialGradient(
//         colors: [
//           color.withOpacity(0.8),
//           Colors.transparent,
//         ],
//       ).createShader(Rect.fromCircle(
//         center: Offset(size.width / 2, size.height / 2),
//         radius: 25,
//       ))
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 3;

//     final centerPoint = Offset(size.width / 2, size.height / 2);
//     final trailStart = centerPoint - Offset(0, 20);
//     final glowPaint = Paint()
//       ..shader = RadialGradient(
//         colors: [
//           color.withOpacity(0.8),
//           Colors.transparent,
//         ],
//       ).createShader(Rect.fromCircle(
//         center: Offset(size.width / 2, size.height / 2),
//         radius: 10,
//       ))
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);

//     canvas.drawLine(trailStart, centerPoint, trailPaint);
//     canvas.drawCircle(centerPoint, 10, glowPaint);
//     canvas.drawCircle(centerPoint, 2, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class ParticleBurstPainter extends CustomPainter {
//   final List<Particle> particles;

//   ParticleBurstPainter(this.particles);

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (var particle in particles) {
//       final paint = Paint()
//         ..shader = RadialGradient(
//           colors: [
//             particle.color.withOpacity(0.8),
//             particle.color.withOpacity(0.2),
//           ],
//         ).createShader(Rect.fromCircle(
//           center: particle.position,
//           radius: particle.radius * 3,
//         ))
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.radius * 1.5);

//       canvas.drawCircle(particle.position, particle.radius, paint);

//       final corePaint = Paint()
//         ..color = particle.color
//         ..style = PaintingStyle.fill;

//       canvas.drawCircle(particle.position, particle.radius / 1.5, corePaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

class PremiumTextWithStars extends StatefulWidget {
  @override
  _PremiumTextWithStarsState createState() => _PremiumTextWithStarsState();
}

class _PremiumTextWithStarsState extends State<PremiumTextWithStars>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers = [];
  late List<Animation<double>> _scaleAnimations = [];
  late List<Animation<double>> _rotationAnimations = [];
  final GlobalKey _textKey = GlobalKey();
  Offset textPosition = Offset.zero;
  Size textSize = Size.zero;
  final math.Random _random = math.Random();
  // Delays in milliseconds for each star animation
  final List<int> _delays = [0, 200, 400, 600, 800];
  final List<Offset> _starPositions = [];

  late Timer _positionTimer;
  @override
  void initState() {
    super.initState();
    // Initialize each animation controller with a delay
    for (int i = 0; i < 5; i++) {
      AnimationController controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );

      _controllers.add(controller);

      // Define the scale animation (pop in/out effect)
      _scaleAnimations.add(
        Tween<double>(begin: 0.0, end: 0.7).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        )),
      );

      // Define the rotation animation
      _rotationAnimations.add(
        Tween<double>(begin: 0.0, end: 0.8).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        )),
      );

      // Start each animation with a delay
      Future.delayed(Duration(milliseconds: _delays[i]), () {
        controller.repeat(reverse: true);
      });
      _starPositions.add(_generateRandomPosition());
    }
    _positionTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      setState(() {
        for (int i = 0; i < _starPositions.length; i++) {
          _starPositions[i] = _generateRandomPosition();
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTextPosition();
    });
    Timer.periodic(Duration(seconds: 4), (Timer t) => randomPositionForStars);
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Offset _generateRandomPosition() {
    // Generate random offsets within the specified range
    double randomX = 90 + _random.nextDouble() * (240 - 90);
    double randomY = -textSize.height * _random.nextDouble() * (0.6 - 1);
    return Offset(randomX, randomY);
  }

  void _calculateTextPosition() {
    RenderBox renderBox =
        _textKey.currentContext!.findRenderObject() as RenderBox;
    setState(() {
      textPosition = renderBox.localToGlobal(Offset.zero);
      textSize = renderBox.size;
    });
  }

  int randomPositionForStars() {
    return _random.nextInt(_random.nextInt(240) + 90);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildGradientText(), // Gradient Text in the center
        _buildAnimatedStars(), // Animated stars around the text
      ],
    );
  }

  Widget _buildGradientText() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.pink,
                Colors.amber,
                Colors.cyan,
              ],
              tileMode: TileMode.mirror,
            ).createShader(
                Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height));
          },
          child: Text(
            key: _textKey,
            'Premium',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Color is overridden by the shader
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStars() {
    return Stack(
      children: [
        _buildStar(
            Colors.blue,
            20,
            Offset(-textSize.width + _random.nextInt(240) + 90,
                -textSize.height * 0.7),
            0),
        _buildStar(
            Colors.red,
            20,
            Offset(-textSize.width + _random.nextInt(240) + 90,
                -textSize.height * 0.9),
            1),
        _buildStar(
            Colors.green,
            20,
            Offset(-textSize.width + _random.nextInt(240) + 90,
                -textSize.height * 0.9),
            2),
        _buildStar(
            Colors.orange,
            20,
            Offset(-textSize.width + _random.nextInt(240) + 90,
                -textSize.height * 0.6),
            3),
        _buildStar(
            Colors.yellow,
            20,
            Offset(-textSize.width + _random.nextInt(240) + 90,
                -textSize.height * 1),
            4),
        _buildStar(
            Colors.yellow,
            20,
            Offset(-textSize.width + _random.nextInt(240) + 90,
                -textSize.height * 1),
            4),
        _buildStar(
            Colors.yellow,
            20,
            Offset(-textSize.width + _random.nextInt(240) + 90,
                -textSize.height * 1),
            4),
        _buildStar(
            Colors.yellow,
            20,
            Offset(-textSize.width + _random.nextInt(240) + 90,
                -textSize.height * 1),
            4),
        _buildStar(
            Colors.yellow,
            20,
            Offset(-textSize.width + _random.nextInt(240) + 90,
                -textSize.height * 1),
            4),
      ],
    );
  }

  Widget _buildStar(Color color, double size, Offset offset, int index) {
    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (context, child) {
        return Positioned(
          left: textPosition.dx + textSize.width / 2 + offset.dx,
          top: textPosition.dy + textSize.height / 2 + offset.dy,
          child: Transform.scale(
            scale: _scaleAnimations[index].value,
            child: Transform.rotate(
              angle: _rotationAnimations[index].value,
              child: CustomPaint(
                size: Size(size, size),
                painter: StarPainter(color),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: 300,
      ))
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, 60); // Apply blur for glow

    final Path path = Path();

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(centerX, centerY);

    final int points = 4;

    for (int i = 0; i < points * 2; i++) {
      double angle = i * math.pi / points;
      double r = (i % 2 == 0) ? radius : radius / 2;

      double x = centerX + r * math.cos(angle);
      double y = centerY + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    canvas.drawPath(path, glowPaint); // Draw the glow first
    canvas.drawPath(path, paint); // Draw the star on top of the glow
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}






// class FallingStarsAnimation extends StatefulWidget {
//   @override
//   _FallingStarsAnimationState createState() => _FallingStarsAnimationState();
// }

// class _FallingStarsAnimationState extends State<FallingStarsAnimation>
//     with TickerProviderStateMixin {
//   final int numberOfStars = 5;
//   final List<AnimationController> _controllers = [];
//   final List<Animation<Offset>> _animations = [];
//   final math.Random random = math.Random();
//   Timer? _speedTimer;
//   late AnimationController _speedController;
//   late Animation<double> _speedAnimation;
//   late AnimationController _vibrateController;
//   late Animation<Offset> _vibrateAnimation;
//   bool _isFastSpeed = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeSpeedController();
//     _initializeVibrateController();
//     _initializeAnimations();
//     _startSpeedCycleTimer();
//   }

//   void _initializeSpeedController() {
//     _speedController = AnimationController(
//       duration: Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _speedAnimation = CurvedAnimation(
//       parent: _speedController,
//       curve: Curves.easeInOut,
//     );

//     _speedController.addListener(() {
//       _updateStarsSpeeds();
//       _updateVibrationIntensity();
//     });
//   }

//   void _initializeVibrateController() {
//     _vibrateController = AnimationController(
//       duration: Duration(milliseconds: 50),
//       vsync: this,
//     );

//     _vibrateAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: Offset(0.01, 0.01),
//     ).animate(CurvedAnimation(
//       parent: _vibrateController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   void _updateVibrationIntensity() {
//     double speedValue = _speedAnimation.value;

//     // Stop vibration if speed is very low
//     if (speedValue < 0.1) {
//       _vibrateController.stop();
//       return;
//     }

//     // Calculate intensity based on current speed
//     double intensity = 0.02 * speedValue;

//     // Update vibration animation
//     _vibrateAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: Offset(intensity, intensity),
//     ).animate(CurvedAnimation(
//       parent: _vibrateController,
//       curve: Curves.easeInOut,
//     ));

//     // Update vibration speed
//     int newDuration = (100 - (50 * speedValue)).toInt();
//     if (_vibrateController.duration?.inMilliseconds != newDuration) {
//       _vibrateController.duration = Duration(milliseconds: newDuration);
//     }

//     // Only start vibrating if not already running
//     if (!_vibrateController.isAnimating && speedValue > 0.1) {
//       _vibrateController.repeat(reverse: true);
//     }
//   }

//   void _initializeAnimations() {
//     for (int i = 0; i < numberOfStars; i++) {
//       AnimationController controller = AnimationController(
//         duration: Duration(seconds: 2 + i),
//         vsync: this,
//       );

//       double fixedY = random.nextDouble() * 0.8 - 0.4;

//       Animation<Offset> animation = Tween<Offset>(
//         begin: Offset(-0.8 - (i * 0.1), fixedY),
//         end: Offset(0.8 + (i * 0.1), fixedY),
//       ).animate(CurvedAnimation(
//         parent: controller,
//         curve: Curves.linear,
//       ));

//       _controllers.add(controller);
//       _animations.add(animation);
//       controller.repeat(reverse: false);
//     }
//   }

//   void _updateStarsSpeeds() {
//     if (!mounted) return;

//     for (int i = 0; i < _controllers.length; i++) {
//       var controller = _controllers[i];
//       // Calculate the current interpolated duration
//       int normalDuration =
//           (2000 + (i * 1000)).toInt(); // Normal duration in milliseconds
//       int fastDuration = 500; // Fast duration in milliseconds

//       // Interpolate between normal and fast duration based on _speedAnimation value
//       int currentDuration = (normalDuration -
//               ((normalDuration - fastDuration) * _speedAnimation.value))
//           .toInt();

//       double currentPosition = controller.value;
//       controller.duration = Duration(milliseconds: currentDuration);

//       // Maintain the current position while changing speed
//       if (controller.isAnimating) {
//         controller.value = currentPosition;
//         controller.repeat(reverse: false);
//       }
//     }
//   }

//   void _startSpeedCycleTimer() {
//     _speedTimer = Timer.periodic(Duration(seconds: 6), (timer) {
//       if (_isFastSpeed) {
//         _slowDown();
//       } else {
//         _speedUp();
//       }
//       _isFastSpeed = !_isFastSpeed;
//     });
//   }

//   void _speedUp() {
//     _speedController.forward();
//   }

//   void _slowDown() {
//     _speedController.reverse().then((_) {
//       // Ensure vibration stops when speed is fully reversed
//       _vibrateController.stop();
//       // Reset vibration controller to zero offset
//       _vibrateController.value = 0.0;
//     });
//   }

//   @override
//   void dispose() {
//     _speedTimer?.cancel();
//     _speedController.dispose();
//     _vibrateController.dispose();
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ClipRect(
//         child: CustomPaint(
//           foregroundPainter: CornersPainter(),
//           child: Container(
//             color: Colors.black,
//             height: 80,
//             width: 130,
//             child: Stack(
//               clipBehavior: Clip.hardEdge,
//               children: [
//                 for (int i = 0; i < numberOfStars; i++)
//                   SlideTransition(
//                     position: _animations[i],
//                     child: CustomPaint(
//                       size: Size(100, 100),
//                       painter: StarPainter(i),
//                     ),
//                   ),
//                 Center(
//                   child: SlideTransition(
//                     position: _vibrateAnimation,
//                     child: ShaderMask(
//                       shaderCallback: (Rect bounds) {
//                         return LinearGradient(
//                           colors: [
//                             Colors.white,
//                             Colors.white.withOpacity(0.8),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ).createShader(bounds);
//                       },
//                       child: Text(
//                         'Animatrix',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CornersPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 2.0
//       ..style = PaintingStyle.stroke;

//     final cornerLength = 10.0;

//     // Top-left corner
//     canvas.drawLine(
//       Offset(0, cornerLength),
//       Offset(0, 0),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(0, 0),
//       Offset(cornerLength, 0),
//       paint,
//     );

//     // Top-right corner
//     canvas.drawLine(
//       Offset(size.width - cornerLength, 0),
//       Offset(size.width, 0),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(size.width, 0),
//       Offset(size.width, cornerLength),
//       paint,
//     );

//     // Bottom-left corner
//     canvas.drawLine(
//       Offset(0, size.height - cornerLength),
//       Offset(0, size.height),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(0, size.height),
//       Offset(cornerLength, size.height),
//       paint,
//     );

//     // Bottom-right corner
//     canvas.drawLine(
//       Offset(size.width - cornerLength, size.height),
//       Offset(size.width, size.height),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(size.width, size.height - cornerLength),
//       Offset(size.width, size.height),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class StarPainter extends CustomPainter {
//   final int starIndex;

//   StarPainter(this.starIndex);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color.fromARGB(255, 224, 225, 225)
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 4;

//     final trailPaint = Paint()
//       ..shader = RadialGradient(
//         colors: [
//           const Color.fromARGB(255, 94, 94, 94).withOpacity(0.8),
//           Colors.transparent,
//         ],
//       ).createShader(Rect.fromCircle(
//         center: Offset(size.width / 2, size.height / 2),
//         radius: 50,
//       ))
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 3;

//     final centerPoint = Offset(size.width / 2, size.height / 2);
//     final trailStart = centerPoint + Offset(-40 - (starIndex * 10), 0);

//     final glowPaint = Paint()
//       ..shader = RadialGradient(
//         colors: [
//           const Color.fromARGB(255, 214, 215, 215).withOpacity(0.8),
//           Colors.transparent,
//         ],
//       ).createShader(Rect.fromCircle(
//         center: Offset(size.width / 2, size.height / 2),
//         radius: 10,
//       ))
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

//     canvas.drawLine(trailStart, centerPoint, trailPaint);
//     canvas.drawCircle(centerPoint, 20, glowPaint);
//     canvas.drawCircle(centerPoint, 2, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
