import 'package:fluent_ui/fluent_ui.dart';

/// An opaque Mica foundation surface.
///
/// This widget is the cross-platform Flutter representation and fallback for
/// WinUI Mica. Native WinUI Mica uses an OS system-backdrop controller to
/// incorporate desktop wallpaper and active/inactive window state; a pure
/// Flutter widget cannot sample that wallpaper. This implementation therefore
/// paints the theme-resolved opaque Mica color without a backdrop blur.
///
/// Mica is intended for long-lived app foundation surfaces. Use [Acrylic] for
/// transient or supporting surfaces that need to reveal Flutter content behind
/// them.
///
/// ![Mica Header Preview](https://learn.microsoft.com/en-us/windows/apps/design/style/images/materials/mica-header.png)
///
/// {@tool snippet}
/// This example shows a mica background:
///
/// ```dart
/// Mica(
///   child: Column(
///     children: [
///       Text('Content on Mica'),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Acrylic], a translucent material with blur effect
///  * <https://learn.microsoft.com/en-us/windows/apps/design/style/mica>
class Mica extends StatelessWidget {
  /// Creates the Mica material.
  ///
  /// [elevation] must be non-negative.
  const Mica({
    required this.child,
    super.key,
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

  /// The opaque color to paint the background area with.
  ///
  /// If null, [FluentThemeData.micaBackgroundColor] is used. This is a
  /// Flutter fallback color, not a wallpaper sample.
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
