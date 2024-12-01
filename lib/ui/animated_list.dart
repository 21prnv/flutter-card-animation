import 'package:flutter/material.dart';

class AnimatedTilesList extends StatefulWidget {
  final List<String> items;
  final Duration itemDelay;
  final Duration animationDuration;
  final double itemHeight;

  const AnimatedTilesList({
    Key? key,
    required this.items,
    this.itemDelay =
        const Duration(milliseconds: 500), // Increased delay between items
    this.animationDuration =
        const Duration(milliseconds: 800), // Longer animation duration
    this.itemHeight = 80,
  }) : super(key: key);

  @override
  State<AnimatedTilesList> createState() => _AnimatedTilesListState();
}

class _AnimatedTilesListState extends State<AnimatedTilesList>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _slideAnimations = [];
  final List<Animation<double>> _scaleAnimations = [];
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

      final slideAnimation = Tween<double>(
        begin: -1.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );

      final scaleAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );

      _controllers.add(controller);
      _slideAnimations.add(slideAnimation);
      _scaleAnimations.add(scaleAnimation);
    }
  }

  void _startSequentialAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
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
          return SizedBox(height: widget.itemHeight + 16); // Space holder
        }

        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset:
                  Offset(0, _slideAnimations[index].value * widget.itemHeight),
              child: Transform.scale(
                scale: _scaleAnimations[index].value,
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
                  child: ListTile(
                    title: Text(
                      widget.items[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
