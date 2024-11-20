import 'package:fluent_ui/fluent_ui.dart';

/// The content of the flyout
///
/// See also:
///
///   * [FlyoutTarget], which the flyout is displayed attached to
///   * [FlyoutListTile], a list tile adapted to flyouts
class FlyoutContent extends StatelessWidget {
  /// Creates a flyout content
  const FlyoutContent({
    super.key,
    required this.child,
    this.color,
    this.shape,
    this.padding = const EdgeInsets.all(8.0),
    this.shadowColor = Colors.black,
    this.elevation = 8,
    this.constraints,
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

  /// The color of the shadow. Not used if [elevation] is 0
  ///
  /// Defaults to black.
  final Color shadowColor;

  /// The z-coordinate relative to the box at which to place this physical
  /// object.
  ///
  /// See also:
  ///
  ///  * [shadowColor]
  final double elevation;

  /// Additional constraints to apply to the child.
  final BoxConstraints? constraints;

  /// Whether the background will be an [Acrylic].
  final bool useAcrylic;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    final resolvedShape = shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(
            width: 0.25,
            color: theme.inactiveBackgroundColor,
          ),
        );

    return PhysicalModel(
      elevation: elevation,
      color: Colors.transparent,
      shadowColor: shadowColor,
      child: Acrylic(
        tintAlpha: !useAcrylic ? 1.0 : null,
        shape: resolvedShape,
        child: Container(
          constraints: constraints,
          decoration: ShapeDecoration(
            color: color ?? theme.menuColor.withOpacity(kMenuColorOpacity),
            shape: resolvedShape,
          ),
          padding: padding,
          child: DefaultTextStyle.merge(
            style: theme.typography.body,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A tile that is used inside of [FlyoutContent]
///
/// See also:
///
///  * [FlyoutTarget], which the flyout is displayed attached to
///  * [FlyoutContent], the content of the flyout
class FlyoutListTile extends StatelessWidget {
  /// Creates a flyout list tile.
  const FlyoutListTile({
    super.key,
    this.onPressed,
    this.tooltip,
    this.icon,
    required this.text,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.margin = const EdgeInsetsDirectional.only(bottom: 5.0),
    this.selected = false,
    this.showSelectedIndicator = true,
  });

  final VoidCallback? onPressed;

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

  final EdgeInsetsGeometry margin;

  final bool selected;

  final bool showSelectedIndicator;

  bool get isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final size = Flyout.maybeOf(context)?.size;

    return HoverButton(
      key: key,
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final theme = FluentTheme.of(context);
        final radius = BorderRadius.circular(4.0);

        if (selected) {
          states = {WidgetState.hovered};
        }

        final foregroundColor =
            ButtonThemeData.buttonForegroundColor(context, states);

        Widget content = Stack(children: [
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
              top: 4.0,
              bottom: 4.0,
              start: 10.0,
              end: 8.0,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10.0),
                  child: IconTheme.merge(
                    data: IconThemeData(size: 16.0, color: foregroundColor),
                    child: icon!,
                  ),
                ),
              Flexible(
                fit: size == null || size.isEmpty
                    ? FlexFit.loose
                    : FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10.0),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 14.0,
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
                    fontSize: 12.0,
                    color: theme.resources.controlStrokeColorDefault,
                    height: 0.7,
                  ),
                  child: trailing!,
                ),
            ]),
          ),
          if (selected && showSelectedIndicator)
            PositionedDirectional(
              top: 0,
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                width: 2.5,
                decoration: BoxDecoration(
                  color: theme.accentColor.defaultBrushFor(theme.brightness),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
        ]);

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
