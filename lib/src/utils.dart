import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Asserts that the given context has a [FluentTheme] ancestor.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasFluentTheme(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasFluentTheme(BuildContext context, [bool check = true]) {
  assert(() {
    if (FluentTheme.maybeOf(context) == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('A FluentTheme widget is necessary to draw this layout.'),
        ErrorHint(
          'To introduce a FluentTheme widget, you can either directly '
          'include one, or use a widget that contains FluentTheme itself, '
          'such as FluentApp',
        ),
        ...context.describeMissingAncestor(expectedAncestorType: FluentTheme),
      ]);
    }
    return true;
  }());
  return true;
}

/// Asserts that the given context has a [Localizations] ancestor that contains
/// a [FluentLocalizations] delegate.
///
/// Used by many fluent design widgets to make sure that they are
/// only used in contexts where they have access to localizations.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasFluentLocalizations(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasFluentLocalizations(BuildContext context) {
  assert(() {
    if (Localizations.of<FluentLocalizations>(context, FluentLocalizations) ==
        null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No FluentLocalizations found.'),
        ErrorDescription(
          '${context.widget.runtimeType} widgets require FluentLocalizations '
          'to be provided by a Localizations widget ancestor.',
        ),
        ErrorDescription(
          'The fluent library uses Localizations to generate messages, '
          'labels, and abbreviations.',
        ),
        ErrorHint(
          'To introduce a FluentLocalizations, either use a '
          'FluentApp at the root of your application to include them '
          'automatically, or add a Localization widget with a '
          'FluentLocalizations delegate.',
        ),
        ...context.describeMissingAncestor(
          expectedAncestorType: FluentLocalizations,
        ),
      ]);
    }
    return true;
  }());
  return true;
}

/// Asserts that the given context has a [Flyout] ancestor.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasFlyout(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasFlyout(BuildContext context) {
  assert(() {
    if (Flyout.maybeOf(context) == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No Flyout found.'),
        ErrorDescription(
          '${context.widget.runtimeType} widgets require a Flyout '
          'to be provided by a Flyout widget ancestor.',
        ),
        ErrorHint(
          'To introduce a Flyout, use the showFlyout method or related methods.',
        ),
        ...context.describeMissingAncestor(expectedAncestorType: Flyout),
      ]);
    }
    return true;
  }());
  return true;
}

/// Check if the current screen is 10 foot long or bigger.
///
/// [width] is the width of the current screen. If not provided,
/// [FlutterView.physicalSize] is used
bool is10footScreen(BuildContext context) {
  final width = View.of(context).physicalSize.width;
  return width >= 11520;
}

/// A horizontal box that is positioned near a target.
///
/// This was adapted from [positionDependentBox].
Offset horizontalPositionDependentBox({
  required Size size,
  required Size childSize,
  required Offset target,
  required bool preferLeft,
  double horizontalOffset = 0.0,
  double margin = 10.0,
}) {
  // Horizontal DIRECTION
  final fitsLeft =
      target.dx + horizontalOffset + childSize.width <= size.width - margin;
  final fitsRight = target.dx - horizontalOffset - childSize.width >= margin;
  final tooltipLeft = preferLeft
      ? fitsLeft || !fitsRight
      : !(fitsRight || !fitsLeft);
  final double x;
  if (tooltipLeft) {
    x = math.min(target.dx + horizontalOffset, size.width - margin);
  } else {
    x = math.max(target.dx - horizontalOffset - childSize.width, margin);
  }
  // Vertical DIRECTION
  final double y;
  if (size.height - margin * 2.0 < childSize.height) {
    y = (size.height - childSize.height) / 2.0;
  } else {
    final normalizedTargetY = target.dy.clamp(margin, size.height - margin);
    final edge = margin + childSize.height / 2.0;
    if (normalizedTargetY < edge) {
      y = margin;
    } else if (normalizedTargetY > size.height - edge) {
      y = size.height - margin - childSize.height;
    } else {
      y = normalizedTargetY - childSize.height / 2.0;
    }
  }
  return Offset(x, y);
}

/// Extension methods for [Decoration] objects.
extension DecorationExtension on Decoration {
  /// Gets the border radius of this decoration.
  BorderRadiusGeometry? getBorderRadius() {
    if (this is BoxDecoration) {
      return (this as BoxDecoration).borderRadius;
    } else if (this is ShapeDecoration) {
      final shape = (this as ShapeDecoration).shape;
      if (shape is RoundedRectangleBorder) {
        return shape.borderRadius;
      } else if (shape is CircleBorder) {
        return BorderRadius.circular(100);
      }
    }
    return null;
  }
}

/// Extension methods for [String] objects.
extension StringExtension on String {
  /// Results this string with the first char uppercased
  ///
  /// january -> January
  String uppercaseFirst() {
    final first = substring(0, 1);
    return first.toUpperCase() + substring(1);
  }

  /// Results this string with the first char uppercased
  ///
  /// January -> january
  String lowercaseFirst() {
    final first = substring(0, 1);
    return first.toLowerCase() + substring(1);
  }
}

/// Extension methods for [Offset] objects.
extension OffsetExtension on Offset {
  /// Clamps this offset to be within the given [min] and [max] bounds.
  Offset clamp(Offset min, Offset max) {
    return Offset(
      clampDouble(dx, min.dx, max.dx),
      clampDouble(dy, min.dy, max.dy),
    );
  }
}

/// Linearly interpolates between two [WidgetStateProperty] objects.
///
/// The [lerpFunction] is used to interpolate between the resolved values
/// for each state.
WidgetStateProperty<T?>? lerpWidgetStateProperty<T>(
  WidgetStateProperty<T?>? a,
  WidgetStateProperty<T?>? b,
  double t,
  T? Function(T?, T?, double) lerpFunction,
) {
  if (identical(a, b)) {
    return a;
  }
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return WidgetStateProperty.lerp<T?>(a, b, t, lerpFunction);
}
