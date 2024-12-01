import 'package:flutter/material.dart';

class SlideFromSidesList extends StatefulWidget {
  final List<String> items;
  final bool fromRight;
  final Duration itemDelay;
  final Duration animationDuration;
  final double itemHeight;

  const SlideFromSidesList({
    Key? key,
    required this.items,
    this.fromRight = false,
    this.itemDelay = const Duration(milliseconds: 200),
    this.animationDuration = const Duration(milliseconds: 600),
    this.itemHeight = 80,
  }) : super(key: key);

  @override
  State<SlideFromSidesList> createState() => _SlideFromSidesListState();
}

class _SlideFromSidesListState extends State<SlideFromSidesList>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _slideAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];
  final List<bool> _isVisible = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSequentialAnimations();
  }

  void _initializeAnimations() {
    for (int i = 0; i < widget.items.length; i++) {
      _isVisible.add(false);

      final controller = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );

      // Slide animation - start from left (-1.0) or right (1.0)
      final slideAnimation = Tween<double>(
        begin: widget.fromRight ? 1.0 : -1.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );

      // Fade animation
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );

      _controllers.add(controller);
      _slideAnimations.add(slideAnimation);
      _fadeAnimations.add(fadeAnimation);
    }
  }

  void _startSequentialAnimations() async {
    for (int i = 0; i < widget.items.length; i++) {
      await Future.delayed(widget.itemDelay);
      if (mounted) {
        setState(() {
          _isVisible[i] = true;
        });
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getItemColor(int index) {
    // Create a list of colors for variety
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        if (!_isVisible[index]) {
          return SizedBox(height: widget.itemHeight + 16);
        }

        final itemColor = _getItemColor(index);

        return AnimatedBuilder(
          animation: Listenable.merge([
            _slideAnimations[index],
            _fadeAnimations[index],
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _slideAnimations[index].value *
                    MediaQuery.of(context).size.width,
                0,
              ),
              child: Opacity(
                opacity: _fadeAnimations[index].value,
                child: Container(
                  height: widget.itemHeight,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (!widget.fromRight) ...[
                        Container(
                          width: 6,
                          decoration: BoxDecoration(
                            color: itemColor.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: itemColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: itemColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.items[index],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sliding from ${widget.fromRight ? 'right' : 'left'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: itemColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                widget.fromRight
                                    ? Icons.arrow_back_ios
                                    : Icons.arrow_forward_ios,
                                color: itemColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.fromRight) ...[
                        Container(
                          width: 6,
                          decoration: BoxDecoration(
                            color: itemColor.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
