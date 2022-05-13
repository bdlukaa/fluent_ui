part of 'flyout.dart';

/// The content of the flyout.
///
/// See also:
///
///   * [Flyout], which is a light dismiss container that can show arbitrary UI
///     as its content
///   * [FlyoutListTile],
class FlyoutContent extends StatelessWidget {
  /// Creates a flyout content
  const FlyoutContent({
    Key? key,
    required this.child,
    this.color,
    this.shape,
    this.padding = const EdgeInsets.all(8.0),
    this.shadowColor = Colors.black,
    this.elevation = 8,
    this.constraints,
  }) : super(key: key);

  final Widget child;

  /// The background color of the box.
  final Color? color;

  /// The shape to fill the [color] of the box.
  final ShapeBorder? shape;

  /// Empty space to inscribe around the [child]
  final EdgeInsetsGeometry padding;

  /// The shadow color.
  final Color shadowColor;

  /// The z-coordinate relative to the box at which to place this physical
  /// object.
  final double elevation;

  /// Additional constraints to apply to the child.
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final ThemeData theme = FluentTheme.of(context);
    return PhysicalModel(
      elevation: elevation,
      color: Colors.transparent,
      shadowColor: shadowColor,
      child: Container(
        constraints: constraints,
        decoration: ShapeDecoration(
          color: color ?? theme.menuColor,
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
                side: BorderSide(
                  width: 0.25,
                  color: theme.inactiveBackgroundColor,
                ),
              ),
        ),
        padding: padding,
        child: DefaultTextStyle(
          style: theme.typography.body ?? const TextStyle(),
          child: child,
        ),
      ),
    );
  }
}

/// A tile that is used inside of [FlyoutContent]
///
/// See also:
///
///  * [Flyout]
///  * [FlyoutContent]
class FlyoutListTile extends StatelessWidget {
  /// Creates a flyout list tile.
  const FlyoutListTile({
    Key? key,
    this.onPressed,
    this.tooltip,
    this.icon,
    required this.text,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.margin = const EdgeInsets.only(bottom: 5.0),
    this.selected = false,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
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
          states = {ButtonStates.hovering};
        }

        Widget content = Container(
          decoration: BoxDecoration(
            color: ButtonThemeData.uncheckedInputColor(theme, states),
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
                  data: const IconThemeData(size: 16.0),
                  child: icon!,
                ),
              ),
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: DefaultTextStyle(
                  style: TextStyle(
                    inherit: false,
                    fontSize: 14.0,
                    letterSpacing: -0.15,
                    color: theme.inactiveColor,
                  ),
                  child: text,
                ),
              ),
            ),
            if (trailing != null)
              DefaultTextStyle(
                style: TextStyle(
                  inherit: false,
                  fontSize: 12.0,
                  color: theme.borderInputColor,
                  height: 0.7,
                ),
                child: trailing!,
              ),
          ]),
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
