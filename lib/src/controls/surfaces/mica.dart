import 'package:fluent_ui/fluent_ui.dart';

/// Mica is an opaque, dynamic material that incorporates theme and desktop
/// wallpaper to paint the background of long-lived windows such as apps and
/// settings. You can apply Mica to your application backdrop to delight users
/// and create visual hierarchy, aiding productivity, by increasing clarity
/// about which window is in focus. Mica is specifically designed for app
/// performance as it only samples the desktop wallpaper once to create its
/// visualization.
///
/// ![Mica Header Preview](https://docs.microsoft.com/en-us/windows/apps/design/style/images/materials/mica-header.png)
///
/// All fluent-widgets are developed to look good on a [Mica] surface, with
/// support for all transparency effects.
///
/// See also:
///
///  * [Acrylic], a type of Brush that creates a translucent texture
///  * <https://docs.microsoft.com/en-us/windows/apps/design/style/mica>
class Mica extends StatelessWidget {
  /// Creates the Mica material.
  ///
  /// [elevation] must be non-negative.
  const Mica({
    super.key,
    required this.child,
    this.elevation = 0,
    this.backgroundColor,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  }) : assert(elevation >= 0.0);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The z-coordinate relative to the parent at which to place this physical
  /// object.
  ///
  /// The value is non-negative.
  final double elevation;

  /// The color to paint the background area with.
  ///
  /// If null, [FluentThemeData.micaBackgroundColor] is used.
  final Color? backgroundColor;

  /// The border radius applied to the area.
  final BorderRadius? borderRadius;

  /// The box shape applied to the area.
  ///
  /// Defaults to [BoxShape.rectangle].
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final boxColor = backgroundColor ?? theme.micaBackgroundColor;
    final Widget result = DecoratedBox(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: borderRadius,
        shape: shape,
      ),
      child: child,
    );
    if (elevation > 0.0) {
      return PhysicalModel(
        color: boxColor,
        elevation: elevation,
        borderRadius: borderRadius,
        shape: shape,
        child: result,
      );
    }
    return result;
  }
}
