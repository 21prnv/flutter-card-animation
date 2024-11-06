import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:animation_app/widgets/glowing_particles.dart';

class HoverRevealText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Color revealColor;
  final String secondText;
  const HoverRevealText({
    Key? key,
    required this.text,
    this.textStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    this.revealColor = Colors.blue,
    required this.secondText,
  }) : super(key: key);

  @override
  _HoverRevealTextState createState() => _HoverRevealTextState();
}

class _HoverRevealTextState extends State<HoverRevealText> {
  late List<bool> _visibleCharacters;
  late List<GlobalKey> _characterKeys;
  double _eraseWidth = 0;
  bool _isHovering = false;
  late final GlobalKey _textKey = GlobalKey();
  Offset _mousePosition = Offset.zero;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _visibleCharacters = List.filled(widget.secondText.length, true);
    _characterKeys = List.generate(
      widget.secondText.length,
      (_) => GlobalKey(),
    );
  }

  void _updateVisibleCharacters(Offset position) {
    setState(() {
      for (int i = 0; i < widget.secondText.length; i++) {
        final RenderBox? box =
            _characterKeys[i].currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final characterPosition = box.localToGlobal(Offset.zero);
          final characterWidth = box.size.width;

          if (position.dx + 20 >= characterPosition.dx + characterWidth) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 80,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() {
              _isHovering = false;
              _visibleCharacters = List.filled(widget.secondText.length, true);
              _mousePosition = Offset.zero;

              _eraseWidth = 0;
            }),
            onHover: (PointerHoverEvent event) {
              _updateVisibleCharacters(event.position);
              setState(() {
                _mousePosition = event.localPosition;
              });
              if (_isHovering) {
                final RenderBox? box =
                    _textKey.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) {
                  final textWidth = box.size.width;
                  setState(() {
                    _eraseWidth = (event.localPosition.dx).clamp(0, textWidth);
                  });
                }
              }
            },
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Text(
                  "    " + widget.text + "    ",
                  key: _textKey,
                  style: widget.textStyle,
                ),
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth - _eraseWidth,
                          color: Color.fromARGB(255, 29, 28, 32),
                          child: GlowingParticles(),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      _updateVisibleCharacters(details.globalPosition);
                    },
                    onPanEnd: (_) {
                      setState(() {
                        _visibleCharacters =
                            List.filled(widget.secondText.length, true);
                      });
                    },
                    child: Wrap(
                      children:
                          List.generate(widget.secondText.length, (index) {
                        return Opacity(
                          opacity: _visibleCharacters[index] ? 1.0 : 0.0,
                          child: Text(
                            widget.secondText[index],
                            key: _characterKeys[index],
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 71, 70, 70)),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                if (_isHovering)
                  Positioned(
                    left: _mousePosition.dx - 1, // Adjust for center of dot
                    // top: _mousePosition.dy - 5, // Adjust for center of dot
                    child: Container(
                      width: 8,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 39, 39, 39),
                          ),
                          BoxShadow(
                            color: Colors.white70,
                            spreadRadius: -7.0,
                            blurRadius: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
