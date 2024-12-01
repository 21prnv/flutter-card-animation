import 'package:flutter/material.dart';

class ExpandingTilesLists extends StatefulWidget {
  final List<String> items;
  final Duration itemDelay;
  final Duration animationDuration;
  final double itemHeight;

  const ExpandingTilesLists({
    Key? key,
    required this.items,
    this.itemDelay = const Duration(milliseconds: 800),
    this.animationDuration = const Duration(milliseconds: 600),
    this.itemHeight = 80,
  }) : super(key: key);

  @override
  State<ExpandingTilesLists> createState() => _ExpandingTilesListState();
}

class _ExpandingTilesListState extends State<ExpandingTilesLists>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _slideAnimations = [];
  final List<Animation<double>> _expandAnimations = [];
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

      // Slide animation
      final slideAnimation = Tween<double>(
        begin: -1.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );

      // Expand animation with custom curve
      final expandAnimation = Tween<double>(
        begin: 0.3, // Start at 30% width
        end: 1.0, // End at 100% width
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );

      _controllers.add(controller);
      _slideAnimations.add(slideAnimation);
      _expandAnimations.add(expandAnimation);
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        if (!_isVisible[index]) {
          return SizedBox(height: widget.itemHeight + 16);
        }

        return AnimatedBuilder(
          animation: Listenable.merge([
            _slideAnimations[index],
            _expandAnimations[index],
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                _slideAnimations[index].value * widget.itemHeight,
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        (0.3 +
                            (_expandAnimations[index].value *
                                0.6)), // Animate from 30% to 90% width
                    child: Container(
                      height: widget.itemHeight,
                      margin: const EdgeInsets.symmetric(
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
                      child: ListTile(
                        title: Text(
                          widget.items[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
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
