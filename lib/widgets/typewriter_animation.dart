import 'package:flutter/material.dart';

class TypewriterAnimatedText extends StatefulWidget {
  final String text;
  final Duration typingSpeed;
  final Duration cursorBlinkRate;
  final Duration pauseBetweenAnimations;
  final bool repeat;

  const TypewriterAnimatedText({
    Key? key,
    required this.text,
    this.typingSpeed = const Duration(milliseconds: 100),
    this.cursorBlinkRate = const Duration(milliseconds: 500),
    this.pauseBetweenAnimations = const Duration(seconds: 2),
    this.repeat = false,
  }) : super(key: key);

  @override
  _TypewriterAnimatedTextState createState() => _TypewriterAnimatedTextState();
}

class _TypewriterAnimatedTextState extends State<TypewriterAnimatedText>
    with SingleTickerProviderStateMixin {
  String _animatedText = '';
  bool _showCursor = true;
  late AnimationController _cursorController;
  bool _isAnimating = true;

  @override
  void initState() {
    super.initState();
    _setupCursorAnimation();
    _startTypingAnimation();
  }

  void _setupCursorAnimation() {
    _cursorController = AnimationController(
      vsync: this,
      duration: widget.cursorBlinkRate,
    );

    _cursorController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showCursor = false);
        _cursorController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _showCursor = true);
        _cursorController.forward();
      }
    });

    _cursorController.forward();
  }

  Future<void> _startTypingAnimation() async {
    do {
      // Type out the text
      for (int i = 0; i <= widget.text.length; i++) {
        if (!_isAnimating) return; // Check if we should stop animating
        await Future.delayed(widget.typingSpeed);
        setState(() {
          _animatedText = widget.text.substring(0, i);
        });
      }

      if (widget.repeat) {
        // Pause at the end of the animation
        await Future.delayed(widget.pauseBetweenAnimations);

        // Clear the text
        setState(() {
          _animatedText = '';
        });

        // Pause before starting the next iteration
        await Future.delayed(widget.pauseBetweenAnimations);
      }
    } while (widget.repeat && _isAnimating);
  }

  @override
  void dispose() {
    _isAnimating = false;
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_animatedText${_showCursor ? '|' : ' '}',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
