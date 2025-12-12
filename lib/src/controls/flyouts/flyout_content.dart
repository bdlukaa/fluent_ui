import 'package:fluent_ui/fluent_ui.dart';

/// Eyeballed value from Windows Home 11.
const kFlyoutMinConstraints = BoxConstraints(minWidth: 118);

/// The content of the flyout
///
/// See also:
///
///   * [FlyoutTarget], which the flyout is displayed attached to
///   * [FlyoutListTile], a list tile adapted to flyouts
class FlyoutContent extends StatelessWidget {
  /// Creates a flyout content
  const FlyoutContent({
    required this.child,
    super.key,
    this.color,
    this.shape,
    this.padding = const EdgeInsetsDirectional.all(8),
    this.shadowColor = Colors.black,
    this.elevation = 8.0,
    this.constraints = kFlyoutMinConstraints,
    this.useAcrylic = true,
  });

  /// The content of the flyout
  final Widget child;

  /// The background color of the box.
  ///
  /// If null, [FluentThemeData.menuColor] is used by default
  final Color? color;

  /// The shape to fill the [color] of the box.
  final ShapeBorder? shape;

  /// Empty space to inscribe around the [child]
  ///
  /// Defaults to 8.0 on each side
  final EdgeInsetsGeometry padding;

  /// The color of the shadow. Not used if [elevation] is 0.0.
  ///
  /// Defaults to black.
  final Color shadowColor;

  /// The z-coordinate relative to the box at which to place this physical
  /// object.
  ///
  /// See also:
  ///
  ///  * [shadowColor], the color of the elevation shadow.
  final double elevation;

  /// Constraints to apply to the child.
  ///
  /// Defaults to [kFlyoutMinConstraints].
  final BoxConstraints constraints;

  /// Whether the background will be an [Acrylic].
  final bool useAcrylic;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
    final theme = FluentTheme.of(context);
    final textDirection = Directionality.of(context);

    final resolvedShape =
        shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: theme.resources.surfaceStrokeColorFlyout),
        );

    final resolvedBorderRadius = () {
      if (resolvedShape is RoundedRectangleBorder) {
        return resolvedShape.borderRadius;
      } else if (resolvedShape is ContinuousRectangleBorder) {
        return resolvedShape.borderRadius;
      } else if (resolvedShape is BeveledRectangleBorder) {
        return resolvedShape.borderRadius;
      } else {
        return null;
      }
    }();

    final content = Acrylic(
      tintAlpha: !useAcrylic ? 1.0 : null,
      shape: resolvedShape,
      child: Container(
        constraints: constraints,
        decoration: ShapeDecoration(
          color: color ?? theme.menuColor.withValues(alpha: kMenuColorOpacity),
          shape: resolvedShape,
        ),
        padding: padding,
        child: DefaultTextStyle.merge(
          style: theme.typography.body,
          child: child,
        ),
      ),
    );

    if (elevation > 0.0) {
      return PhysicalModel(
        elevation: elevation,
        color: Colors.transparent,
        borderRadius: resolvedBorderRadius?.resolve(textDirection),
        shadowColor: shadowColor,
        child: content,
      );
    }

    return content;
  }
}

/// A tile that is used inside of [FlyoutContent].
///
/// See also:
///
///  * [FlyoutTarget], which the flyout is displayed attached to
///  * [FlyoutContent], the content of the flyout
class FlyoutListTile extends StatelessWidget {
  /// Creates a flyout list tile.
  const FlyoutListTile({
    required this.text,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.tooltip,
    this.icon,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.margin = const EdgeInsetsDirectional.only(bottom: 5),
    this.selected = false,
    this.showSelectedIndicator = true,
  });

  /// Called when the tile is tapped or otherwise activated.
  final VoidCallback? onPressed;

  /// Called when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// The tile tooltip text
  final String? tooltip;

  /// The leading widget.
  ///
  /// Usually an [Icon]
  final Widget? icon;

  /// The title widget.
  ///
  /// Usually a [Text]
  final Widget text;

  /// The leading widget.
  final Widget? trailing;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  /// The margin around the tile.
  final EdgeInsetsGeometry margin;

  /// Whether this tile is currently selected.
  final bool selected;

  /// Whether to show the selection indicator when [selected] is true.
  final bool showSelectedIndicator;

  /// Whether this tile is enabled.
  bool get isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    return HoverButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final theme = FluentTheme.of(context);
        final radius = BorderRadius.circular(4);

        if (selected) {
          states = {WidgetState.hovered};
        }

        final foregroundColor = ButtonThemeData.buttonForegroundColor(
          context,
          states,
        );

        Widget content = Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ButtonThemeData.uncheckedInputColor(
                  theme,
                  states,
                  transparentWhenNone: true,
                ),
                borderRadius: radius,
              ),
              padding: const EdgeInsetsDirectional.only(
                top: 4,
                bottom: 4,
                start: 10,
                end: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: IconTheme.merge(
                        data: IconThemeData(size: 16, color: foregroundColor),
                        child: icon!,
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.15,
                          color: foregroundColor,
                        ),
                        child: text,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.resources.controlStrokeColorDefault,
                        height: 0.7,
                      ),
                      child: trailing!,
                    ),
                ],
              ),
            ),
            if (selected && showSelectedIndicator)
              PositionedDirectional(
                top: 0,
                bottom: 0,
                child: Container(
                  margin: const EdgeInsetsDirectional.symmetric(vertical: 6),
                  width: 2.5,
                  decoration: BoxDecoration(
                    color: theme.accentColor.defaultBrushFor(theme.brightness),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
          ],
        );

        if (tooltip != null) {
          content = Tooltip(message: tooltip, child: content);
        }

        return Padding(
          padding: margin,
          child: FocusBorder(
            focused: states.isFocused,
            renderOutside: true,
            style: FocusThemeData(borderRadius: radius),
            child: content,
          ),
        );
      },
    );
  }
}
