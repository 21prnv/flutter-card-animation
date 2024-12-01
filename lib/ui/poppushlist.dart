import 'package:flutter/material.dart';

class ExpandingTilesList extends StatefulWidget {
  final List<String> items;
  final Duration itemDelay;
  final Duration slideAnimationDuration;
  final Duration expandAnimationDuration;
  final double itemHeight;

  const ExpandingTilesList({
    Key? key,
    required this.items,
    this.itemDelay = const Duration(milliseconds: 800),
    this.slideAnimationDuration = const Duration(milliseconds: 500),
    this.expandAnimationDuration = const Duration(milliseconds: 400),
    this.itemHeight = 80,
  }) : super(key: key);

  @override
  State<ExpandingTilesList> createState() => _ExpandingTilesListState();
}

class _ExpandingTilesListState extends State<ExpandingTilesList>
    with TickerProviderStateMixin {
  final List<AnimationController> _slideControllers = [];
  final List<AnimationController> _expandControllers = [];
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

      // Slide animation controller and animation
      final slideController = AnimationController(
        duration: widget.slideAnimationDuration,
        vsync: this,
      );
      final slideAnimation = Tween<double>(
        begin: -1.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: slideController,
          curve: Curves.easeOutCubic,
        ),
      );

      // Expand animation controller and animation
      final expandController = AnimationController(
        duration: widget.expandAnimationDuration,
        vsync: this,
      );
      final expandAnimation = Tween<double>(
        begin: 0.5, // Start at 50% width
        end: 1.0, // End at 100% width
      ).animate(
        CurvedAnimation(
          parent: expandController,
          curve: Curves.easeOutBack,
        ),
      );

      _slideControllers.add(slideController);
      _expandControllers.add(expandController);
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

        // Start slide animation
        await _slideControllers[i].forward();

        // Start expand animation after slide
        await _expandControllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _slideControllers) {
      controller.dispose();
    }
    for (var controller in _expandControllers) {
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
                        trailing: const Icon(Icons.arrow_forward_ios),
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
