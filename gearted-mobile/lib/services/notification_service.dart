import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common/animations.dart';

/// Enhanced notification service for real-time alerts
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  OverlayEntry? _currentOverlay;

  /// Show a toast notification with animation
  void showToast({
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    _removeCurrentOverlay();

    final context = _navigatorKey.currentContext;
    if (context == null) return;

    _currentOverlay = OverlayEntry(
      builder: (context) => NotificationToast(
        message: message,
        type: type,
        duration: duration,
        onTap: onTap,
        onDismiss: _removeCurrentOverlay,
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  /// Show a bottom notification with action buttons
  void showBottomNotification({
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationBottomSheet(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      ),
    );
  }

  /// Show a floating notification for new messages
  void showFloatingNotification({
    required String title,
    required String message,
    String? avatar,
    VoidCallback? onTap,
  }) {
    _removeCurrentOverlay();

    final context = _navigatorKey.currentContext;
    if (context == null) return;

    _currentOverlay = OverlayEntry(
      builder: (context) => FloatingNotification(
        title: title,
        message: message,
        avatar: avatar,
        onTap: onTap,
        onDismiss: _removeCurrentOverlay,
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
    HapticFeedback.lightImpact();
  }

  /// Show success feedback
  void showSuccess(String message) {
    showToast(
      message: message,
      type: NotificationType.success,
      duration: const Duration(seconds: 2),
    );
    HapticFeedback.heavyImpact();
  }

  /// Show error feedback
  void showError(String message) {
    showToast(
      message: message,
      type: NotificationType.error,
      duration: const Duration(seconds: 4),
    );
    HapticFeedback.heavyImpact();
  }

  /// Show warning feedback
  void showWarning(String message) {
    showToast(
      message: message,
      type: NotificationType.warning,
      duration: const Duration(seconds: 3),
    );
    HapticFeedback.mediumImpact();
  }

  /// Show info feedback
  void showInfo(String message) {
    showToast(
      message: message,
      type: NotificationType.info,
      duration: const Duration(seconds: 2),
    );
    HapticFeedback.lightImpact();
  }

  void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Simulate new message notification
  void simulateNewMessage({
    required String senderName,
    required String message,
    required String listingTitle,
    VoidCallback? onTap,
  }) {
    showFloatingNotification(
      title: 'Nouveau message de $senderName',
      message: 'À propos de "$listingTitle": $message',
      avatar: senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U',
      onTap: onTap,
    );
  }

  /// Simulate sale notification
  void simulateSaleNotification({
    required String listingTitle,
    required double amount,
    VoidCallback? onTap,
  }) {
    showBottomNotification(
      title: '🎉 Félicitations !',
      message:
          'Votre annonce "$listingTitle" a été vendue pour ${amount.toStringAsFixed(0)}€',
      actionLabel: 'Voir les détails',
      onAction: onTap,
      duration: const Duration(seconds: 5),
    );
  }

  /// Simulate offer notification
  void simulateOfferNotification({
    required String buyerName,
    required double offerAmount,
    required String listingTitle,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
  }) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OfferNotificationSheet(
        buyerName: buyerName,
        offerAmount: offerAmount,
        listingTitle: listingTitle,
        onAccept: onAccept,
        onDecline: onDecline,
      ),
    );
  }
}

enum NotificationType { success, error, warning, info }

/// Toast notification widget
class NotificationToast extends StatefulWidget {
  final String message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const NotificationToast({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<NotificationToast> createState() => _NotificationToastState();
}

class _NotificationToastState extends State<NotificationToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData icon;
    Color iconColor = Colors.white;

    switch (widget.type) {
      case NotificationType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case NotificationType.info:
        backgroundColor = const Color(0xFF4A5D23); // Army green
        icon = Icons.info;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!();
                }
                _dismiss();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Icon(
                        Icons.close,
                        color: iconColor.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating notification for messages
class FloatingNotification extends StatefulWidget {
  final String title;
  final String message;
  final String? avatar;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const FloatingNotification({
    super.key,
    required this.title,
    required this.message,
    this.avatar,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<FloatingNotification> createState() => _FloatingNotificationState();
}

class _FloatingNotificationState extends State<FloatingNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 16,
      left: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!();
                }
                _dismiss();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4A5D23),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A5D23).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A5D23),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.avatar ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A5D23).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.message,
                        color: Color(0xFF4A5D23),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet notification
class NotificationBottomSheet extends StatefulWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration? duration;

  const NotificationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.duration,
  });

  @override
  State<NotificationBottomSheet> createState() =>
      _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<NotificationBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _controller.forward();

    // Auto dismiss if duration is provided
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideInAnimationWidget(
      direction: SlideDirection.bottom,
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF4A5D23),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.message,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.actionLabel != null && widget.onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAction!();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5D23),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.actionLabel!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fermer',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Offer notification sheet
class OfferNotificationSheet extends StatelessWidget {
  final String buyerName;
  final double offerAmount;
  final String listingTitle;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const OfferNotificationSheet({
    super.key,
    required this.buyerName,
    required this.offerAmount,
    required this.listingTitle,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return SlideInAnimationWidget(
      direction: SlideDirection.bottom,
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF4A5D23),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💰 Nouvelle Offre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '$buyerName a fait une offre de ${offerAmount.toStringAsFixed(0)}€',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pour: "$listingTitle"',
              style: const TextStyle(
                color: Color(0xFF4A5D23),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (onDecline != null) onDecline!();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Refuser',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (onAccept != null) onAccept!();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Accepter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Décider plus tard',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
