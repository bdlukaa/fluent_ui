import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';

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
    if (context.maybeTheme == null)
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('A FluentTheme widget is necessary to draw this layout.'),
        ErrorHint(
          'To introduce a FluentTheme widget, you can either directly '
          'include one, or use a widget that contains FluentTheme itself, '
          'such as FluentApp',
        ),
        ...context.describeMissingAncestor(expectedAncestorType: FluentTheme),
      ]);
    return true;
  }());
  return true;
}

/// Check if the current screen is 10 foot long or bigger.
///
/// [width] is the width of the current screen. If not provided,
/// [SingletonFlutterWindow.physicalSize] is used
bool is10footScreen([double? width]) {
  width ??= ui.window.physicalSize.width;
  return width >= 11520;
}
