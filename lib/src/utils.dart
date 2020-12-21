import 'package:fluent_ui/fluent_ui.dart';

Color get lightElevationColor => Colors.black.withOpacity(0.1);
Color get darkElevationColor => Colors.grey[130].withOpacity(0.1);

/// [[Article]](https://developer.microsoft.com/en-us/fluentui#/styles/web/elevation)
/// Get the elevation shadow.
///
/// [factor], [right], [left], [bottom], [top] can't be null. The default [color] is Black
List<BoxShadow> elevationShadow(
  int factor, {
  bool right = true,
  bool left = true,
  bool bottom = true,
  bool top = true,
  Color color = Colors.black,
  double blurRadius = 8,
  double spreadRadius = 2,
}) {
  assert(factor != null, 'The elevation factor is necessary');
  // assert([right, left, bottom, top].contains(null),
  //     'Right, left, top and bottom can\'t be null');
  return [
    if (right)
      BoxShadow(
        color: color ?? Colors.black,
        blurRadius: blurRadius ?? 0,
        spreadRadius: spreadRadius ?? 0,
        offset: Offset(1, 0),
      ),
    if (left)
      BoxShadow(
        color: color ?? Colors.black,
        blurRadius: blurRadius ?? 0,
        spreadRadius: spreadRadius ?? 0,
        offset: Offset(-1, 0),
      ),
    if (bottom)
      BoxShadow(
        color: color ?? Colors.black,
        blurRadius: blurRadius ?? 0,
        spreadRadius: spreadRadius ?? 0,
        offset: Offset(0, 1),
      ),
    if (top)
      BoxShadow(
        color: color ?? Colors.black,
        blurRadius: blurRadius ?? 0,
        spreadRadius: spreadRadius ?? 0,
        offset: Offset(0, -1),
      ),
  ];
}

void debugCheckHasFluentTheme(BuildContext context, [bool check = true]) {
  assert(check != null);
  if (check)
    assert(
      context.theme != null,
      'A Theme widget is necessary to draw this layout. It is implemented by default in FluentApp. ' +
          'To fix this, wrap a Theme widget upper in this layout or implement a FluentApp.',
    );
}
