import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class HoverableTextAnimation extends StatefulWidget {
  final String text;
  final TextStyle style;

  const HoverableTextAnimation({
    Key? key,
    required this.text,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  _HoverableTextAnimationState createState() => _HoverableTextAnimationState();
}

class _HoverableTextAnimationState extends State<HoverableTextAnimation> {
  late List<bool> _visibleCharacters;
  late List<GlobalKey> _characterKeys;

  @override
  void initState() {
    super.initState();
    _visibleCharacters = List.filled(widget.text.length, true);
    _characterKeys = List.generate(
      widget.text.length,
      (_) => GlobalKey(),
    );
  }

  void _updateVisibleCharacters(Offset position) {
    setState(() {
      for (int i = 0; i < widget.text.length; i++) {
        final RenderBox? box =
            _characterKeys[i].currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final characterPosition = box.localToGlobal(Offset.zero);
          final characterWidth = box.size.width;
          if (position.dx >= characterPosition.dx + characterWidth) {
            _visibleCharacters[i] = false;
          } else {
            _visibleCharacters[i] = true;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (PointerHoverEvent event) {
        _updateVisibleCharacters(event.position);
      },
      onExit: (_) {
        setState(() {
          _visibleCharacters = List.filled(widget.text.length, true);
        });
      },
      child: GestureDetector(
        onPanUpdate: (details) {
          _updateVisibleCharacters(details.globalPosition);
        },
        onPanEnd: (_) {
          setState(() {
            _visibleCharacters = List.filled(widget.text.length, true);
          });
        },
        child: Wrap(
          children: List.generate(widget.text.length, (index) {
            return Opacity(
              opacity: _visibleCharacters[index] ? 1.0 : 0.0,
              child: Text(
                widget.text[index],
                key: _characterKeys[index],
                style: widget.style,
              ),
            );
          }),
        ),
      ),
    );
  }
}
