import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

/// The default height of a one-line list tile.
const kOneLineTileHeight = 40.0;

/// The default padding of a list tile.
const kDefaultListTilePadding = EdgeInsetsDirectional.only(
  end: 12,
  top: 6,
  bottom: 6,
);

/// The default shape of a list tile.
const kDefaultListTileShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(4)),
);

/// The default margin of a list tile.
const kDefaultListTileMargin = EdgeInsetsDirectional.symmetric(
  horizontal: 4,
  vertical: 2,
);

/// The selection mode of a list tile.
enum ListTileSelectionMode {
  /// The list tile is not selectable.
  none,

  /// Only one item can be selected at a time.
  single,

  /// Multiple items can be selected at a time.
  multiple,
}

/// A windows-styled list tile.
///
/// ![ListViewItem inside a ListView](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/listview-grouped-example-resized-final.png)
///
/// See also:
///
///  * [ListView], a scrollable list of widgets arranged linearly.
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/item-templates-listview>
class ListTile extends StatelessWidget {
  /// A windows-styled list tile
  const ListTile({
    super.key,
    this.tileColor,
    this.shape = kDefaultListTileShape,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.cursor,
    this.contentAlignment = CrossAxisAlignment.center,
    this.contentPadding = kDefaultListTilePadding,
    this.margin = kDefaultListTileMargin,
  }) : assert(
         !(subtitle != null) || title != null,
         'To have a subtitle, there must be a title',
       ),
       selected = false,
       selectionMode = ListTileSelectionMode.none,
       onSelectionChange = null;

  /// A selectable list tile.
  const ListTile.selectable({
    super.key,
    this.tileColor,
    this.shape = kDefaultListTileShape,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.selected = false,
    this.selectionMode = ListTileSelectionMode.single,
    this.onSelectionChange,
    this.semanticLabel,
    this.cursor,
    this.contentAlignment = CrossAxisAlignment.center,
    this.contentPadding = kDefaultListTilePadding,
    this.margin = kDefaultListTileMargin,
  }) : assert(
         !(subtitle != null) || title != null,
         'To have a subtitle, there must be a title',
       );

  /// The background color of the button.
  ///
  /// If null, [ButtonThemeData.uncheckedInputColor] is used by default
  final WidgetStateColor? tileColor;

  /// The tile shape.
  ///
  /// [kDefaultListTileShape] is used by default
  final ShapeBorder shape;

  /// A widget to display before the title.
  ///
  /// Typically an [Icon] or a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget? subtitle;

  /// A widget to display after the title.
  ///
  /// Typically an [Icon] widget.
  final Widget? trailing;

  /// Called when the user taps this list tile.
  ///
  /// If null, and [onSelectionChange] is also null, the tile does not perform
  /// any action
  final VoidCallback? onPressed;

  /// Whether this tile is selected within the list.
  ///
  /// See also:
  ///
  ///  * [selectionMode], which changes how the tile behave within the list
  ///  * [onSelectionChange], which is called when the selection changes
  final bool selected;

  /// How the tile selection will behave within the list
  ///
  /// See also:
  ///
  ///  * [selected], which tells the widget whether it's selected or not
  ///  * [onSelectionChange], which is called when the selection changes
  final ListTileSelectionMode selectionMode;

  /// Called when the selection changes.
  ///
  /// If [selectionMode] is single, this is called when any unselected tile is
  /// pressed. If [selectionMode] is multiple, this is called when any tile is
  /// pressed
  ///
  /// See also:
  ///
  ///  * [selected], which tells the widget whether it's selected or not
  ///  * [selectionMode], which changes how the tile behave within the list
  final ValueChanged<bool>? onSelectionChange;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  /// Mouse Cursor to display
  ///
  /// If null, [MouseCursor.defer] is used by default
  ///
  /// See also cursors like:
  ///
  ///  * [SystemMouseCursors.click], which turns the mouse cursor to click
  final MouseCursor? cursor;

  /// How the children should be placed along the cross axis in a flex layout.
  ///
  /// Defaults to [CrossAxisAlignment.center]
  final CrossAxisAlignment contentAlignment;

  /// Padding applied to list tile content
  ///
  /// Defaults to [kDefaultListTilePadding]
  final EdgeInsetsGeometry contentPadding;

  /// Padding applied between this tile's [FocusBorder] and outer decoration.
  ///
  /// Defaults to [kDefaultListTileMargin].
  final EdgeInsetsGeometry? margin;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ShapeBorder>(
          'shape',
          shape,
          defaultValue: kDefaultListTileShape,
        ),
      )
      ..add(
        FlagProperty(
          'selected',
          value: selected,
          ifFalse: 'unselected',
          defaultValue: false,
        ),
      )
      ..add(
        EnumProperty(
          'selectionMode',
          selectionMode,
          defaultValue: ListTileSelectionMode.none,
        ),
      )
      ..add(
        FlagProperty(
          'enabled',
          value: onPressed != null || onSelectionChange != null,
          defaultValue: false,
          ifFalse: 'disabled',
        ),
      )
      ..add(
        EnumProperty<CrossAxisAlignment>(
          'contentAlignment',
          contentAlignment,
          defaultValue: CrossAxisAlignment.center,
        ),
      )
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          'contentPadding',
          contentPadding,
          defaultValue: kDefaultListTilePadding,
        ),
      )
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry?>(
          'margin',
          margin,
          defaultValue: kDefaultListTileMargin,
        ),
      );
  }

  void _onSelectionChange() {
    switch (selectionMode) {
      case ListTileSelectionMode.multiple:
        onSelectionChange!(!selected);
      case ListTileSelectionMode.single:
        if (!selected) onSelectionChange!(true);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
    final theme = FluentTheme.of(context);

    return HoverButton(
      onPressed:
          onPressed ?? (onSelectionChange != null ? _onSelectionChange : null),
      focusNode: focusNode,
      autofocus: autofocus,
      cursor: cursor,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final tileColor = () {
          if (this.tileColor != null) {
            return this.tileColor!.resolve(states);
          }

          return ButtonThemeData.uncheckedInputColor(
            theme,
            selected ? {...states, WidgetState.hovered} : states,
            transparentWhenNone: true,
            transparentWhenDisabled: true,
          );
        }();

        const placeholder = SizedBox(width: 12);

        final tile = Row(
          crossAxisAlignment: contentAlignment,
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: leading,
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    DefaultTextStyle.merge(
                      style: (theme.typography.body ?? const TextStyle())
                          .copyWith(fontSize: 16),
                      child: title!,
                    ),
                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: theme.typography.caption ?? const TextStyle(),
                      child: subtitle!,
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        );

        return Semantics(
          container: true,
          selected: selectionMode == ListTileSelectionMode.none
              ? null
              : selected,
          child: FocusBorder(
            focused: states.isFocused,
            renderOutside: false,
            child: Container(
              decoration: ShapeDecoration(shape: shape, color: tileColor),
              constraints: const BoxConstraints(
                minHeight: kOneLineTileHeight,
                minWidth: 88,
              ),
              margin: margin,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tileHeight = constraints.minHeight;
                  return Row(
                    children: [
                      if (selectionMode == ListTileSelectionMode.none)
                        placeholder
                      else if (selectionMode == ListTileSelectionMode.multiple)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 6,
                            end: 12,
                          ),
                          child: IgnorePointer(
                            child: ExcludeFocus(
                              child: Checkbox(
                                checked: selected,
                                onChanged: (v) {
                                  onSelectionChange?.call(v ?? false);
                                },
                              ),
                            ),
                          ),
                        )
                      else if (selectionMode == ListTileSelectionMode.single)
                        SizedBox(
                          height: tileHeight,
                          child: TweenAnimationBuilder<double>(
                            duration: theme.mediumAnimationDuration,
                            curve: theme.animationCurve,
                            tween: Tween<double>(
                              begin: 0,
                              end: selected
                                  ? states.isPressed
                                        ? tileHeight * 0.3
                                        : tileHeight
                                  : 0.0,
                            ),
                            builder: (context, height, child) => Center(
                              child: Padding(
                                padding: EdgeInsetsDirectional.symmetric(
                                  vertical: contentPadding.vertical,
                                ),
                                child: Container(
                                  height: height * 0.7,
                                  width: 3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: selected
                                        ? theme.accentColor.defaultBrushFor(
                                            theme.brightness,
                                          )
                                        : Colors.transparent,
                                  ),
                                  margin: const EdgeInsetsDirectional.only(
                                    end: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        placeholder,
                      Expanded(
                        child: Padding(padding: contentPadding, child: tile),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
