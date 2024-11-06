import 'package:flutter/material.dart';

class CharacterFadeAnimation extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration characterDuration;

  const CharacterFadeAnimation({
    Key? key,
    required this.text,
    this.textStyle = const TextStyle(fontSize: 20),
    this.characterDuration = const Duration(milliseconds: 50),
  }) : super(key: key);

  @override
  _CharacterFadeAnimationState createState() => _CharacterFadeAnimationState();
}

class _CharacterFadeAnimationState extends State<CharacterFadeAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.text.length,
      (index) => AnimationController(
        vsync: this,
        duration: widget.characterDuration,
      ),
    );

    _fadeAnimations = _controllers
        .map((controller) =>
            Tween<double>(begin: 0.0, end: 1.0).animate(controller))
        .toList();

    _animateNextCharacter(0);
  }

  void _animateNextCharacter(int index) {
    if (index < _controllers.length) {
      _controllers[index].forward().then((_) {
        _animateNextCharacter(index + 1);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(widget.text.length, (index) {
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: Text(
            widget.text[index],
            style: widget.textStyle,
          ),
        );
      }),
    );
  }
}
