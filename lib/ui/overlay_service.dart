// overlay_service.dart
import 'package:flutter/material.dart';

class OverlayService {
  static final OverlayService _instance = OverlayService._internal();
  factory OverlayService() => _instance;
  OverlayService._internal();

  final Map<String, OverlayState> _overlayStates = {};

  void registerOverlay(String key, OverlayState overlayState) {
    _overlayStates[key] = overlayState;
  }

  void unregisterOverlay(String key) {
    _overlayStates.remove(key);
  }

  OverlayState? get _currentOverlay =>
      _overlayStates.isNotEmpty ? _overlayStates.values.last : null;

  void showNotification({
    String? message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.blueAccent,
    Color textColor = Colors.white,
    double? top,
    VoidCallback? onTap,
  }) {
    final overlay = _currentOverlay;

    if (overlay == null) {
      debugPrint(
          'No overlay state registered. Ensure you have added an OverlayStateWidget in your widget tree.');
      return;
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message ?? "This is a notification",
        backgroundColor: backgroundColor,
        textColor: textColor,
        top: top,
        onTap: onTap,
        onClose: (entry) => entry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    if (duration != Duration.zero) {
      Future.delayed(duration, () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    }
  }
}

// Separate widget for notification UI
class _NotificationWidget extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final double? top;
  final VoidCallback? onTap;
  final Function(OverlayEntry) onClose;

  const _NotificationWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    this.top,
    this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ?? 50,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.info, color: textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: textColor),
                  ),
                ),
                // IconButton(
                //   icon: Icon(Icons.close, color: textColor),
                //   onPressed: () => onClose(overlayEntry),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OverlayStateWidget extends StatefulWidget {
  final Widget child;
  final String? overlayKey;

  const OverlayStateWidget({
    Key? key,
    required this.child,
    this.overlayKey,
  }) : super(key: key);

  @override
  State<OverlayStateWidget> createState() => _OverlayStateWidgetState();
}

class _OverlayStateWidgetState extends State<OverlayStateWidget> {
  late String overlayKey;

  @override
  void initState() {
    super.initState();
    overlayKey = widget.overlayKey ?? 'default_overlay';
  }

  @override
  void dispose() {
    OverlayService().unregisterOverlay(overlayKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final overlay = Overlay.of(context, rootOverlay: true);
          if (overlay != null) {
            OverlayService().registerOverlay(overlayKey, overlay);
          }
        });
        return widget.child;
      },
    );
  }
}
