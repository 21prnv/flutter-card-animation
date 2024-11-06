import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(FallingStarApp());

class FallingStarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Falling Star Animation',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Falling Stars Animation'),
        ),
        body: FallingStarsAnimation(),
      ),
    );
  }
}

class FallingStarsAnimation extends StatefulWidget {
  @override
  _FallingStarsAnimationState createState() => _FallingStarsAnimationState();
}

class _FallingStarsAnimationState extends State<FallingStarsAnimation>
    with TickerProviderStateMixin {
  final int numberOfStars = 5;
  final List<AnimationController> _controllers = [];
  final List<Animation<Offset>> _animations = [];
  final math.Random random = math.Random();
  Timer? _speedTimer;
  late AnimationController _speedController;
  late Animation<double> _speedAnimation;
  late AnimationController _vibrateController;
  late Animation<Offset> _vibrateAnimation;
  bool _isFastSpeed = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeedController();
    _initializeVibrateController();
    _initializeAnimations();
    _startSpeedCycleTimer();
  }

  void _initializeSpeedController() {
    _speedController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _speedAnimation = CurvedAnimation(
      parent: _speedController,
      curve: Curves.easeInOut,
    );

    _speedController.addListener(() {
      _updateStarsSpeeds();
      _updateVibrationIntensity();
    });
  }

  void _initializeVibrateController() {
    _vibrateController = AnimationController(
      duration: Duration(milliseconds: 50),
      vsync: this,
    );

    _vibrateAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.01, 0.01),
    ).animate(CurvedAnimation(
      parent: _vibrateController,
      curve: Curves.easeInOut,
    ));
  }

  void _updateVibrationIntensity() {
    double speedValue = _speedAnimation.value;

    // Stop vibration if speed is very low
    if (speedValue < 0.1) {
      _vibrateController.stop();
      return;
    }

    // Calculate intensity based on current speed
    double intensity = 0.02 * speedValue;

    // Update vibration animation
    _vibrateAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(intensity, intensity),
    ).animate(CurvedAnimation(
      parent: _vibrateController,
      curve: Curves.easeInOut,
    ));

    // Update vibration speed
    int newDuration = (100 - (50 * speedValue)).toInt();
    if (_vibrateController.duration?.inMilliseconds != newDuration) {
      _vibrateController.duration = Duration(milliseconds: newDuration);
    }

    // Only start vibrating if not already running
    if (!_vibrateController.isAnimating && speedValue > 0.1) {
      _vibrateController.repeat(reverse: true);
    }
  }

  void _initializeAnimations() {
    for (int i = 0; i < numberOfStars; i++) {
      AnimationController controller = AnimationController(
        duration: Duration(seconds: 2 + i),
        vsync: this,
      );

      double fixedY = random.nextDouble() * 0.8 - 0.4;

      Animation<Offset> animation = Tween<Offset>(
        begin: Offset(-0.8 - (i * 0.1), fixedY),
        end: Offset(0.8 + (i * 0.1), fixedY),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));

      _controllers.add(controller);
      _animations.add(animation);
      controller.repeat(reverse: false);
    }
  }

  void _updateStarsSpeeds() {
    if (!mounted) return;

    for (int i = 0; i < _controllers.length; i++) {
      var controller = _controllers[i];
      // Calculate the current interpolated duration
      int normalDuration =
          (2000 + (i * 1000)).toInt(); // Normal duration in milliseconds
      int fastDuration = 500; // Fast duration in milliseconds

      // Interpolate between normal and fast duration based on _speedAnimation value
      int currentDuration = (normalDuration -
              ((normalDuration - fastDuration) * _speedAnimation.value))
          .toInt();

      double currentPosition = controller.value;
      controller.duration = Duration(milliseconds: currentDuration);

      // Maintain the current position while changing speed
      if (controller.isAnimating) {
        controller.value = currentPosition;
        controller.repeat(reverse: false);
      }
    }
  }

  void _startSpeedCycleTimer() {
    _speedTimer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (_isFastSpeed) {
        _slowDown();
      } else {
        _speedUp();
      }
      _isFastSpeed = !_isFastSpeed;
    });
  }

  void _speedUp() {
    _speedController.forward();
  }

  void _slowDown() {
    _speedController.reverse().then((_) {
      // Ensure vibration stops when speed is fully reversed
      _vibrateController.stop();
      // Reset vibration controller to zero offset
      _vibrateController.value = 0.0;
    });
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    _speedController.dispose();
    _vibrateController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRect(
        child: CustomPaint(
          foregroundPainter: CornersPainter(),
          child: Container(
            color: Colors.black,
            height: 80,
            width: 130,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (int i = 0; i < numberOfStars; i++)
                  SlideTransition(
                    position: _animations[i],
                    child: CustomPaint(
                      size: Size(100, 100),
                      painter: StarPainter(i),
                    ),
                  ),
                Center(
                  child: SlideTransition(
                    position: _vibrateAnimation,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Animatrix',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final cornerLength = 10.0;

    // Top-left corner
    canvas.drawLine(
      Offset(0, cornerLength),
      Offset(0, 0),
      paint,
    );
    canvas.drawLine(
      Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  final int starIndex;

  StarPainter(this.starIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 224, 225, 225)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final trailPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color.fromARGB(255, 94, 94, 94).withOpacity(0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: 50,
      ))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final centerPoint = Offset(size.width / 2, size.height / 2);
    final trailStart = centerPoint + Offset(-40 - (starIndex * 10), 0);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color.fromARGB(255, 214, 215, 215).withOpacity(0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: 10,
      ))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawLine(trailStart, centerPoint, trailPaint);
    canvas.drawCircle(centerPoint, 20, glowPaint);
    canvas.drawCircle(centerPoint, 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
