import 'dart:io';

import 'package:flutter/material.dart';
import 'toast.dart';

/// Show one toast after another finished
Future<void> showSequencialToasts({
  @required List<Toast> toasts,
  @required BuildContext context,
}) async {
  assert(toasts != null);
  assert(context != null);
  for (var toast in toasts)
    await showToastWidget(
      toast: toast,
      context: context,
    );
}

/// Show a text toast. The toast is defined according to the platform.
/// See `showPlatformToast`.
///
/// `text` and `context` must not be null.
Future<void> showTextToast({
  @required String text,
  @required BuildContext context,
  TextStyle style,
  TextOverflow overflow,
  TextAlign textAlign = TextAlign.center,
  TextDirection textDirection,
  StrutStyle strutStyle,
  double textScaleFactor,
  Duration duration,
  Duration animationDuration,
  VoidCallback onDismiss,
  AlignmentGeometry alignment,
  EdgeInsets padding,
  EdgeInsets margin,
  ToastAnimationBuilder animationBuilder,
  bool usePlataform = false,
}) async {
  assert(text != null);
  assert(context != null);
  final textWidget = Text(
    text,
    style: style,
    overflow: overflow,
    softWrap: true,
    textAlign: textAlign,
    textDirection: textDirection,
    strutStyle: strutStyle,
    textScaleFactor: textScaleFactor,
  );
  if (usePlataform)
    await showPlatformToast(
      child: textWidget,
      context: context,
      duration: duration,
      animationDuration: animationDuration,
      alignment: alignment,
      padding: padding,
      margin: margin,
      animationBuilder: animationBuilder,
    );
  else
    await showStyledToast(
      child: textWidget,
      context: context,
      duration: duration,
      animationDuration: animationDuration,
      alignment: alignment,
      margin: margin,
      animationBuilder: animationBuilder,
    );
}

/// Show a toast according to the platform
///
/// If the platform is `android` or `fuchsia` (or the `child` is an AndroidToast),
/// then an `AndroidToast` will be showed, otherwise, a `StyledToast` will be showed
Future<void> showPlatformToast({
  @required Widget child,
  @required BuildContext context,
  Duration duration,
  Duration animationDuration,
  VoidCallback onDismiss,
  AlignmentGeometry alignment,
  EdgeInsets padding,
  EdgeInsets margin,
  ToastAnimationBuilder animationBuilder,
}) async {
  assert(child != null);
  assert(context != null);
  if (Platform.isAndroid || Platform.isFuchsia || child is AndroidToast) {
    await showAndroidToast(
      context: context,
      text: child,
      duration: duration,
      animationDuration: animationDuration,
      alignment: alignment,
      padding: padding,
      margin: margin,
      animationBuilder: animationBuilder,
    );
  } else {
    await showStyledToast(
      child: child,
      context: context,
      duration: duration,
      animationDuration: animationDuration,
      alignment: alignment,
      contentPadding: padding,
      margin: margin,
      animationBuilder: animationBuilder,
    );
  }
}

/// Shows multi toasts at the same time.
///
/// `toasts` and `context` must not be null.
showMultiToast({
  @required List<Toast> toasts,
  @required BuildContext context,
}) {
  assert(toasts != null);
  assert(context != null);
  for (Toast toast in toasts) showToastWidget(toast: toast, context: context);
}

/// Show an android.
///
/// `text` must not be null. It is usually a text widget.
///
/// `context` must not be null.
Future<void> showAndroidToast({
  @required Widget text,
  @required BuildContext context,
  Color backgroundColor,
  Duration duration,
  Duration animationDuration,
  VoidCallback onDismiss,
  AlignmentGeometry alignment,
  EdgeInsets padding,
  EdgeInsets margin,
  ToastAnimationBuilder animationBuilder,
}) async {
  assert(text != null);
  assert(context != null);
  await showToast(
    child: text is AndroidToast
        ? text
        : AndroidToast(
            text: text,
            backgroundColor: backgroundColor,
          ),
    context: context,
    duration: duration,
    animationDuration: animationDuration,
    alignment: alignment,
    padding: padding,
    margin: margin,
    animationBuilder: animationBuilder,
  );
}

class AndroidToast extends StatelessWidget {
  /// A toast just like android's
  const AndroidToast({
    Key key,
    @required this.text,
    this.backgroundColor,
  }) : super(key: key);

  /// The text of the toast
  final Widget text;

  /// The background color of the toast
  ///
  /// If null, the color will be based on the theme of
  final Color backgroundColor;

  Color nullColor(Brightness theme) {
    if (theme == Brightness.dark)
      return Colors.grey;
    else
      return Colors.grey[200];
  }

  /// Show the toast.
  ///
  /// `context` must not be null
  Future<void> show(
    BuildContext context, {
    Duration duration,
    Duration animationDuration,
    VoidCallback onDismiss,
    TextDirection textDirection,
    AlignmentGeometry alignment,
    EdgeInsets padding,
    EdgeInsets margin,
    ToastAnimationBuilder animationBuilder,
  }) async =>
      await showAndroidToast(
        context: context,
        text: text,
        backgroundColor: backgroundColor,
        duration: duration,
        alignment: alignment,
        padding: padding,
        animationBuilder: animationBuilder,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: backgroundColor ?? nullColor(theme),
        borderRadius: BorderRadius.circular(25),
      ),
      child: DefaultTextStyle(
        child: text,
        style: TextStyle(
          color: theme == Brightness.dark ? Colors.white : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Shows a styledToast
Future<void> showStyledToast({
  @required Widget child,
  @required BuildContext context,
  Color backgroundColor,
  EdgeInsetsGeometry contentPadding,
  EdgeInsetsGeometry margin,
  BorderRadiusGeometry borderRadius,
  Duration duration,
  Duration animationDuration,
  VoidCallback onDismiss,
  AlignmentGeometry alignment,
  ToastAnimationBuilder animationBuilder,
}) async {
  assert(child != null);
  assert(context != null);
  await showToast(
    child: child is StyledToast
        ? child
        : StyledToast(
            child: child,
            backgroundColor: backgroundColor,
            contentPadding: contentPadding,
            margin: margin,
            borderRadius: borderRadius,
          ),
    context: context,
    duration: duration,
    animationDuration: animationDuration,
    alignment: alignment,
    padding: EdgeInsets.zero,
    margin: EdgeInsets.zero,
    animationBuilder: animationBuilder,
  );
}

class StyledToast extends StatelessWidget {
  const StyledToast({
    Key key,
    this.child,
    this.contentPadding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  /// The content of the widget
  final Widget child;

  /// The content padding
  final EdgeInsetsGeometry contentPadding;

  /// The margin of the toast
  final EdgeInsetsGeometry margin;

  /// The borderRadius of the toast
  final BorderRadiusGeometry borderRadius;

  /// The color of the toast
  final Color backgroundColor;

  Future<void> show(
    BuildContext context, {
    Duration duration,
    Duration animationDuration,
    VoidCallback onDismiss,
    AlignmentGeometry alignment,
    ToastAnimationBuilder animationBuilder,
  }) async =>
      await showStyledToast(
        child: this,
        context: context,
        duration: duration,
        animationDuration: animationDuration,
        alignment: alignment,
        animationBuilder: animationBuilder,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness;
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      padding: contentPadding ?? EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (theme == Brightness.dark ? Colors.grey[200] : Colors.black45),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: DefaultTextStyle(
        child: child ?? Container(),
        style: TextStyle(
          color: theme == Brightness.dark ? Colors.black : Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
