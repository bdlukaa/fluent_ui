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
    if (Localizations.of<FluentLocalizations>(context, FluentLocalizations) == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No FluentLocalizations found.'),
        ErrorDescription(
          '${context.widget.runtimeType} widgets require FluentLocalizations '
          'to be provided by a Localizations widget ancestor.'
        ),
        ErrorDescription(
          'The material library uses Localizations to generate messages, '
          'labels, and abbreviations.'
        ),
        ErrorHint(
          'To introduce a FluentLocalizations, either use a '
          'FluentApp at the root of your application to include them '
          'automatically, or add a Localization widget with a '
          'FluentLocalizations delegate.'
        ),
        ...context.describeMissingAncestor(expectedAncestorType: FluentLocalizations)
      ]);
    }
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
