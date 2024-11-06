import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class HoverTooltip extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Duration animationDuration;
  final double avatarRadius;
  final ImageProvider? avatarImage;
  final List<Color> borderColors;
  final double tooltipMaxWidth;
  final double tooltipMinWidth;
  final TextStyle titleStyle;
  final TextStyle? subtitleStyle;
  final Color tooltipBackgroundColor;
  final double tooltipBorderRadius;
  final double borderWidth;
  final double maxRotationAngle;
  final bool animatedBorder;

  const HoverTooltip({
    super.key,
    required this.title,
    this.subtitle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.avatarRadius = 30,
    this.avatarImage,
    this.borderColors = const [Colors.white, Colors.purple, Colors.red],
    this.tooltipMaxWidth = 0.8,
    this.tooltipMinWidth = 40,
    this.titleStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 16,
    ),
    this.subtitleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 10,
    ),
    this.tooltipBackgroundColor = Colors.black,
    this.tooltipBorderRadius = 10,
    this.borderWidth = 2,
    this.maxRotationAngle = 20,
    this.animatedBorder = false,
  });

  @override
  State<HoverTooltip> createState() => _HoverTooltipState();
}

class _HoverTooltipState extends State<HoverTooltip>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _tooltipAnimationController;
  late AnimationController _borderAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _tooltipAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.animatedBorder) {
      _borderAnimationController.repeat();
    }

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _tooltipAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1),
    ).animate(
      CurvedAnimation(
        parent: _tooltipAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _tooltipAnimationController.dispose();
    _borderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _buildAvatar(),
        _buildTooltip(),
      ],
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      child: MouseRegion(
        onEnter: (_) => _handleHoverEnter(),
        onExit: (_) => _handleHoverExit(),
        onHover: (event) => _handleHover(event),
        child: CircleAvatar(
          radius: widget.avatarRadius,
          backgroundImage: widget.avatarImage,
        ),
      ),
    );
  }

  Widget _buildTooltip() {
    return Positioned(
      bottom: widget.avatarRadius / 2,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _rotationAngle),
            duration: widget.animationDuration,
            builder: (context, value, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateZ(value * (math.pi / 180)),
                child: CustomPaint(
                  foregroundPainter: widget.animatedBorder
                      ? _GradientBorderPainter(
                          animation: widget.animatedBorder
                              ? _borderAnimationController
                              : null,
                          strokeWidth: widget.borderWidth,
                          colors: widget.borderColors,
                          borderRadius: widget.tooltipBorderRadius,
                        )
                      : null,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width *
                          widget.tooltipMaxWidth,
                      minWidth: widget.tooltipMinWidth,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.tooltipBackgroundColor,
                      borderRadius:
                          BorderRadius.circular(widget.tooltipBorderRadius),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          style: widget.titleStyle,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            widget.subtitle!,
                            style: widget.subtitleStyle,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleHoverEnter() {
    setState(() => _isHovered = true);
    _tooltipAnimationController.forward();
  }

  void _handleHoverExit() {
    setState(() {
      _isHovered = false;
      _rotationAngle = 0.0;
    });
    _tooltipAnimationController.reverse();
  }

  void _handleHover(PointerHoverEvent event) {
    if (_isHovered) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset localPosition = box.globalToLocal(event.position);
      setState(() {
        _rotationAngle = ((localPosition.dx / box.size.width) * 2 - 1) *
            widget.maxRotationAngle;
      });
    }
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Animation<double>? animation;
  final double strokeWidth;
  final List<Color> colors;
  final double borderRadius;

  _GradientBorderPainter({
    this.animation,
    required this.strokeWidth,
    required this.colors,
    required this.borderRadius,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: colors,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        tileMode: TileMode.clamp,
        transform: animation != null
            ? GradientRotation(animation!.value * math.pi * 2)
            : null,
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      animation != oldDelegate.animation;
}
