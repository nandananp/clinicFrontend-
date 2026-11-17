import 'dart:async';
import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info }

class _ToastData {
  final String id;
  final ToastType type;
  final String title;
  final String message;
  final Duration duration;

  _ToastData({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.duration,
  });
}

/// Top-right floating toast that lives in the ROOT overlay.
/// It keeps showing even if the screen that triggered it is disposed
/// (e.g. login screen -> dashboard navigation).
///
/// Old API (still works):
///   AppToast.success(context, 'Title', message: 'text');
///   AppToast.error(context, 'Title', message: 'text');
///   AppToast.warning(context, 'Title', message: 'text');
///
/// New API ( [context] may be null ):
///   AppToast.showSuccess(null, 'text', title: 'Title');
///   AppToast.showError(null, 'text', title: 'Title');
class AppToast {
  AppToast._();

  /// Set once in app.dart. Used when context is null / not mounted.
  static GlobalKey<NavigatorState>? navigatorKey;

  static final List<_ToastData> _toasts = [];
  static final StreamController<List<_ToastData>> _toastStream =
      StreamController<List<_ToastData>>.broadcast();
  static OverlayEntry? _overlayEntry;
  static int _idCounter = 0;

  static const Color successAccent = Color(0xFF10B981);
  static const Color errorAccent = Color(0xFFEF4444);
  static const Color warningAccent = Color(0xFFF59E0B);
  static const Color infoAccent = Color(0xFF369D96);

  static const Color _heading = Color(0xFF0F2A37);
  static const Color _subtle = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  // ── Old-style API (title first, message optional) ───────────────────
  static void success(BuildContext? context, String title, {String? message}) =>
      show(
        context: context,
        type: ToastType.success,
        title: title,
        message: message ?? '',
      );

  static void error(BuildContext? context, String title, {String? message}) =>
      show(
        context: context,
        type: ToastType.error,
        title: title,
        message: message ?? '',
        duration: const Duration(milliseconds: 4500),
      );

  static void warning(BuildContext? context, String title, {String? message}) =>
      show(
        context: context,
        type: ToastType.warning,
        title: title,
        message: message ?? '',
        duration: const Duration(milliseconds: 4000),
      );

  // ── New-style API (message first, title optional) ───────────────────
  static void showSuccess(BuildContext? context, String message,
          {String? title}) =>
      show(
        context: context,
        type: ToastType.success,
        title: title ?? 'Success',
        message: message,
      );

  static void showError(BuildContext? context, String message,
          {String? title}) =>
      show(
        context: context,
        type: ToastType.error,
        title: title ?? 'Error',
        message: message,
        duration: const Duration(milliseconds: 4500),
      );

  static void showWarning(BuildContext? context, String message,
          {String? title}) =>
      show(
        context: context,
        type: ToastType.warning,
        title: title ?? 'Warning',
        message: message,
        duration: const Duration(milliseconds: 4000),
      );

  static void showInfo(BuildContext? context, String message,
          {String? title}) =>
      show(
        context: context,
        type: ToastType.info,
        title: title ?? 'Information',
        message: message,
      );

  static void show({
    BuildContext? context,
    required ToastType type,
    required String title,
    required String message,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    if (message.trim().isEmpty && title.trim().isEmpty) return;

    final overlayState = _resolveOverlay(context);
    if (overlayState == null) return;

    final toast = _ToastData(
      id: 'toast_${DateTime.now().microsecondsSinceEpoch}_${++_idCounter}',
      type: type,
      title: title,
      message: message,
      duration: duration,
    );

    if (_toasts.length >= 4) _toasts.removeAt(0);
    _toasts.add(toast);

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (ctx) => _ToastHostOverlay(
          stream: _toastStream.stream,
          initialToasts: List.from(_toasts),
          onDismissToast: _removeToast,
        ),
      );
      overlayState.insert(_overlayEntry!);
    }

    _toastStream.add(List.from(_toasts));
  }

  static void _removeToast(String id) {
    final index = _toasts.indexWhere((t) => t.id == id);
    if (index != -1) {
      _toasts.removeAt(index);
      _toastStream.add(List.from(_toasts));
    }

    if (_toasts.isEmpty) {
      Future.delayed(const Duration(milliseconds: 320), () {
        if (_toasts.isEmpty && _overlayEntry != null) {
          _overlayEntry?.remove();
          _overlayEntry = null;
        }
      });
    }
  }

  static void clearAll() {
    _toasts.clear();
    _toastStream.add([]);
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static OverlayState? _resolveOverlay(BuildContext? context) {
    if (context != null && context.mounted) {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay != null) return overlay;
    }
    return navigatorKey?.currentState?.overlay;
  }
}

class _ToastHostOverlay extends StatefulWidget {
  final Stream<List<_ToastData>> stream;
  final List<_ToastData> initialToasts;
  final void Function(String id) onDismissToast;

  const _ToastHostOverlay({
    required this.stream,
    required this.initialToasts,
    required this.onDismissToast,
  });

  @override
  State<_ToastHostOverlay> createState() => _ToastHostOverlayState();
}

class _ToastHostOverlayState extends State<_ToastHostOverlay> {
  late List<_ToastData> _active;
  StreamSubscription<List<_ToastData>>? _sub;

  @override
  void initState() {
    super.initState();
    _active = List.from(widget.initialToasts);
    _sub = widget.stream.listen((updated) {
      if (mounted) setState(() => _active = List.from(updated));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_active.isEmpty) return const SizedBox.shrink();

    final mq = MediaQuery.of(context);
    final isMobile = mq.size.width < 460;
    final width = isMobile ? mq.size.width - 32 : 390.0;

    return Positioned(
      top: mq.padding.top + 18,
      right: isMobile ? 16 : 24,
      width: width,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _active
              .map(
                (t) => KeyedSubtree(
                  key: ValueKey(t.id),
                  child: _ToastCard(
                    toast: t,
                    onDismiss: () => widget.onDismissToast(t.id),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ToastCard extends StatefulWidget {
  final _ToastData toast;
  final VoidCallback onDismiss;

  const _ToastCard({required this.toast, required this.onDismiss});

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with TickerProviderStateMixin {
  late final AnimationController _anim;
  late final AnimationController _progress;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));

    _progress = AnimationController(vsync: this, duration: widget.toast.duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _dismiss();
      });

    _anim.forward();
    _progress.forward();
  }

  void _dismiss() {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _progress.stop();
    _anim.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _progress.dispose();
    super.dispose();
  }

  Color get _accent {
    switch (widget.toast.type) {
      case ToastType.success:
        return AppToast.successAccent;
      case ToastType.error:
        return AppToast.errorAccent;
      case ToastType.warning:
        return AppToast.warningAccent;
      case ToastType.info:
        return AppToast.infoAccent;
    }
  }

  IconData get _icon {
    switch (widget.toast.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          onEnter: (_) => _progress.stop(),
          onExit: (_) {
            if (!_dismissing) _progress.forward();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppToast._border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: Container(color: _accent),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 11, 10, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_icon, color: _accent, size: 17),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.toast.title,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppToast._heading,
                                ),
                              ),
                              if (widget.toast.message.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.toast.message,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppToast._subtle,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: _dismiss,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 15,
                            color: AppToast._subtle,
                          ),
                          splashRadius: 14,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          tooltip: 'Dismiss',
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 2,
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) => Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: (1.0 - _progress.value).clamp(0.0, 1.0),
                          child: Container(
                            color: _accent.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}