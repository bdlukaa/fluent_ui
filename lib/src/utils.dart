import 'package:fluent_ui/fluent_ui.dart';

Color get lightElevationColor => Colors.black.withOpacity(0.1);
Color get darkElevationColor => Colors.grey[150]!.withOpacity(0.1);

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
