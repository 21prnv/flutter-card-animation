import 'package:flutter/material.dart';
import 'dart:async';

class TypingTextEffect extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration typingSpeed;

  const TypingTextEffect({
    Key? key,
    required this.text,
    this.textStyle = const TextStyle(fontSize: 20),
    this.typingSpeed = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  _TypingTextEffectState createState() => _TypingTextEffectState();
}

class _TypingTextEffectState extends State<TypingTextEffect> {
  String _displayedText = '';
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.textStyle,
    );
  }
}
