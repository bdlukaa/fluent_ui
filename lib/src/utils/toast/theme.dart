import 'package:flutter/material.dart';

class ToastTheme extends InheritedWidget {
  /// Child widget
  final Widget child;

  /// Padding for the text and the container edges
  final EdgeInsets padding;

  /// Alignment of animation, like size, rotate animation.
  final AlignmentGeometry alignment;

  /// Callback when toast is dismissed
  final VoidCallback onDismiss;

  /// The margin of the widget. Default to `all(10)`
  final EdgeInsets margin;

  ToastTheme({
    this.child,
    this.padding,
    this.margin,
    this.alignment,
    this.onDismiss,
  }) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static ToastTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ToastTheme>();

  /// Copy this theme with
  ToastTheme copyWith({
    Alignment alignment,
    bool dismissOtherOnShow,
    bool movingOnWindowChange,
    VoidCallback onDismiss,
    EdgeInsets padding,
    EdgeInsets margin,
  }) {
    return ToastTheme(
      alignment: alignment ?? this.alignment,
      margin: margin ?? this.margin,
      onDismiss: onDismiss ?? this.onDismiss,
      padding: padding ?? this.padding,
    );
  }
}
