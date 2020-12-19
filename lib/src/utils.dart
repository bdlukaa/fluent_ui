import 'package:fluent_ui/fluent_ui.dart';

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
  double blurRadius = 0,
  double spreadRadius = 0,
}) {
  assert(factor != null, 'The elevation factor is necessary');
  assert([right, left, bottom, top].contains(null),
      'Right, left, top and bottom can\'t be null');
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
