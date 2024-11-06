import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class HoverTextAnimation extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color hoverColor;

  const HoverTextAnimation({
    Key? key,
    required this.text,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.hoverColor = Colors.red,
  }) : super(key: key);

  @override
  _HoverTextAnimationState createState() => _HoverTextAnimationState();
}

class _HoverTextAnimationState extends State<HoverTextAnimation> {
  int _visibleCharacters = 0;
  bool _isHovering = false;
  Offset _mousePosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    // Create a TextPainter to measure the width of the text
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: TextStyle(
          fontSize: 30,
          color: widget.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    // Layout the TextPainter
    textPainter.layout();

    return MouseRegion(
      onHover: (PointerHoverEvent event) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(event.position);
        int characterIndex =
            textPainter.getPositionForOffset(localPosition).offset;

        // Ensure that the last character is properly shown
        if (characterIndex >= widget.text.length) {
          characterIndex = widget.text.length;
        }

        setState(() {
          if (characterIndex >= 0 && characterIndex <= widget.text.length) {
            // Only reveal up to the exact character being hovered
            _visibleCharacters = characterIndex;
            _mousePosition = localPosition;
            _isHovering = true;
          } else {
            _isHovering = false;
          }
        });
      },
      onExit: (PointerExitEvent event) {
        setState(() {
          _visibleCharacters = 0;
          _isHovering = false;
        });
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: textPainter.width + 100, // Use textPainter width here
            decoration: BoxDecoration(
              gradient: _isHovering
                  ? LinearGradient(
                      colors: [
                        widget.hoverColor.withOpacity(
                          (_mousePosition.dx / textPainter.width)
                              .clamp(0.0, 1.0),
                        ),
                        Colors.red.withOpacity(
                          1 -
                              (_mousePosition.dx / textPainter.width)
                                  .clamp(0.0, 1.0),
                        ),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : LinearGradient(colors: [Colors.red, Colors.red]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.text.substring(0, _visibleCharacters),
              style: TextStyle(
                fontSize: 30,
                color: widget.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_isHovering)
            Positioned(
              left: _mousePosition.dx - 10,
              top: _mousePosition.dy - 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
