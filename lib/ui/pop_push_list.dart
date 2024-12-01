import 'package:flutter/material.dart';

class PopUpPushList extends StatefulWidget {
  final List<String> items;
  final Duration itemDelay;
  final Duration animationDuration;
  final double itemHeight;

  const PopUpPushList({
    Key? key,
    required this.items,
    this.itemDelay = const Duration(milliseconds: 800),
    this.animationDuration = const Duration(milliseconds: 600),
    this.itemHeight = 80,
  }) : super(key: key);

  @override
  State<PopUpPushList> createState() => _PopUpPushListState();
}

class _PopUpPushListState extends State<PopUpPushList>
    with TickerProviderStateMixin {
  final List<GlobalKey> _keys = [];
  final List<bool> _isVisible = [];
  late final ScrollController _scrollController;
  int _visibleCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeItems();
    _startSequentialAnimations();
  }

  void _initializeItems() {
    for (int i = 0; i < widget.items.length; i++) {
      _keys.add(GlobalKey());
      _isVisible.add(false);
    }
  }

  void _startSequentialAnimations() async {
    for (int i = 0; i < widget.items.length; i++) {
      await Future.delayed(widget.itemDelay);
      if (mounted) {
        setState(() {
          _isVisible[i] = true;
          _visibleCount++;
        });

        // Auto-scroll to show new items
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: widget.animationDuration,
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        if (!_isVisible[index]) {
          return const SizedBox.shrink();
        }

        return TweenAnimationBuilder<double>(
          key: _keys[index],
          tween: Tween(begin: 0.0, end: 1.0),
          duration: widget.animationDuration,
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
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
                  subtitle: Text(
                    'Item ${index + 1}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
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
            );
          },
        );
      },
    );
  }
}
