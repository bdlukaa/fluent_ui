import 'package:fluent_ui/fluent_ui.dart';

/// Check if the current context has a fluent theme
///
/// If [check] is not null, an [AssertionError] is thrown if the checking fails
bool debugCheckHasFluentTheme(BuildContext context, [bool check = true]) {
  final has = context.maybeTheme != null;
  if (check)
    assert(
      has,
      'A Theme widget is necessary to draw this layout. It is implemented by default in FluentApp. '
      'To fix this, wrap a Theme widget upper in this layout or implement a FluentApp.',
    );
  return has;
}

/// Check if the current screen is 10 foot long or bigger.
bool is10footScreen(double width) {
  final foot = width * 0.0264583333 / 30.48;
  return foot >= 10;
}
