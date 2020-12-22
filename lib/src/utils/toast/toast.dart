import 'package:flutter/material.dart';
import 'manager.dart';
import 'theme.dart';

export 'theme.dart';
export 'toasts.dart';
export 'manager.dart';

/// Default toast duration
///
/// 2.3 seconds
const _defaultDuration = Duration(milliseconds: 2300);

/// Default animation duration
/// When you use Curves.elasticOut, you can specify a longer duration to achieve beautiful effect
/// But [animDuration] * 2  <= toast [duration], conditions must be met for toast to display properly
/// so when you specify a longer animation duration, you must also specify toast duration to satisfy conditions above
const _animationDuration = Duration(milliseconds: 400);

/// Show a toast.
///
/// `child` and `context` must not be null.
///
/// If `child` is a `Toast`, then all other arguments will be discarted
Future<void> showToast({
  @required Widget child,
  @required BuildContext context,
  Duration duration,
  Duration animationDuration,
  VoidCallback onDismiss,
  AlignmentGeometry alignment,
  EdgeInsets padding,
  EdgeInsets margin,
  ToastAnimationBuilder animationBuilder,
  bool interactive = false,
}) async {
  assert(context != null);
  assert(child != null);

  if (child is Toast)
    await showToastWidget(
      toast: child,
      context: context,
      interactive: interactive,
    );
  else {
    await showToastWidget(
      context: context,
      interactive: interactive,
      toast: Toast(
        duration: duration,
        animationDuration: animationDuration,
        alignment: alignment,
        padding: padding,
        margin: margin,
        onDismiss: onDismiss,
        animationBuilder: animationBuilder,
        child: child,
      ),
    );
  }
}

/// Show a toast widget
Future<void> showToastWidget({
  @required Toast toast,
  @required BuildContext context,
  bool interactive = false,
}) async {
  assert(toast != null);
  assert(context != null);
  assert(interactive != null);

  OverlayEntry entry = OverlayEntry(
    builder: (context) => IgnorePointer(
      child: toast,
      ignoring: !(interactive ?? false),
    ),
  );
  Overlay.of(context).insert(entry);

  ToastManager.insert(entry);

  await Future.delayed(toast.duration ?? _defaultDuration, () {
    ToastManager.dismiss(entry);
    toast.onDismiss?.call();
  });
}

typedef ToastAnimationBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

class Toast extends StatefulWidget {
  /// The content of the toast. This can not be null
  final Widget child;

  /// The duration of the toast.
  final Duration duration;

  /// The duration of the animation.
  final Duration animationDuration;

  /// The alignment of the toast
  final AlignmentGeometry alignment;

  /// The padding of the toast
  final EdgeInsets padding;

  /// The margin of the toast
  final EdgeInsets margin;

  /// A callback called when the toast is dismissed.
  final VoidCallback onDismiss;

  /// Toast animation builder. Default to fade animation.
  ///
  /// It will go forward when the toast start and reverse
  /// when the toast is dismissed.
  ///
  /// A slide animation example with `animationBuilder`:
  /// ``` dart
  /// animationBuilder: (context, animation, child) {
  ///   return SlideTransition(
  ///     position: CurvedAnimation(
  ///       parent: animation,
  ///       curve: Curves.elasticInOut,
  ///     ).drive(Tween<Offset>(
  ///       begin: Offset(-3, 0),
  ///       end: Offset(0, 0),
  ///     )),
  ///     child: child,
  ///   );
  /// },
  /// ```
  final ToastAnimationBuilder animationBuilder;

  Toast({
    Key key,
    @required this.child,
    this.duration = _defaultDuration,
    this.animationDuration = _animationDuration,
    this.alignment = Alignment.center,
    this.animationBuilder,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.onDismiss,
  })  : assert(child != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ToastState();

  show(BuildContext context) => showToastWidget(
        context: context,
        toast: this,
      );
}

class _ToastState extends State<Toast> with TickerProviderStateMixin<Toast> {
  /// Animation controller
  AnimationController _animationController;

  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? _animationDuration,
    );

    // Start animation
    Future.delayed(const Duration(milliseconds: 30), () async {
      if (!mounted) return;
      setState(() => opacity = 1.0);
      try {
        await _animationController.forward().orCancel;
      } catch (e) {}
    });

    // Dismiss toast
    Future.delayed(
      // to allow reverse animation effect
      (widget.duration ?? _defaultDuration) -
          (widget.animationDuration ?? _animationDuration),
      dismissToastAnim,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget w;

    w = Opacity(
      opacity: opacity,
      child: createAnimWidget(
        Material(
          child: widget.child,
          color: Colors.transparent,
        ),
      ),
    );

    final toastTheme = ToastTheme.of(context);

    Widget container = Container(
      padding: widget.padding ?? toastTheme?.padding ?? EdgeInsets.all(10),
      margin: MediaQuery.of(context).viewPadding +
          (widget.margin ??
              toastTheme?.margin ??
              EdgeInsets.only(
                // avoid things in bottom
                bottom: 80,
                right: 10,
                left: 10,
                top: 10,
              )),
      alignment:
          widget.alignment ?? toastTheme?.alignment ?? Alignment.bottomCenter,
      child: w,
    );

    return container;
  }

  /// Create animation widget
  Widget createAnimWidget(Widget w) {
    if (widget.animationBuilder != null)
      return widget.animationBuilder(context, _animationController, w);
    return FadeTransition(
      opacity: _animationController.drive(Tween<double>(begin: 0, end: 1)),
      child: w,
    );
  }

  /// Dismiss toast with animation
  void dismissToastAnim() async {
    if (!mounted) return;
    try {
      await _animationController?.reverse()?.orCancel;
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
