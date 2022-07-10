import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

const kThreeLineTileHeight = 60.0;
const kTwoLineTileHeight = 52.0;
const kOneLineTileHeight = 40.0;

const kDefaultContentPadding = EdgeInsetsDirectional.only(
  end: 12.0,
  top: 6.0,
  bottom: 6.0,
);

enum ListTileSelectionMode {
  none,
  single,
  multiple,
}

class ListTile extends StatelessWidget {
  const ListTile({
    Key? key,
    this.tileColor,
    this.shape,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.contentPadding = kDefaultContentPadding,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
  })  : assert(
          subtitle != null ? title != null : true,
          'To have a subtitle, there must be a title',
        ),
        selected = false,
        selectionMode = ListTileSelectionMode.none,
        onSelectionChange = null,
        super(key: key);

  const ListTile.selectable({
    Key? key,
    this.tileColor,
    this.shape,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.contentPadding = kDefaultContentPadding,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.selected = false,
    this.selectionMode = ListTileSelectionMode.single,
    this.onSelectionChange,
  })  : assert(
          subtitle != null ? title != null : true,
          'To have a subtitle, there must be a title',
        ),
        super(key: key);

  /// The color of the tile
  final ButtonState<Color>? tileColor;

  /// The shape of the tile
  final ShapeBorder? shape;

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  final bool isThreeLine;

  final EdgeInsetsGeometry contentPadding;

  final VoidCallback? onPressed;
  final bool selected;
  final ListTileSelectionMode selectionMode;
  final ValueChanged<bool>? onSelectionChange;

  final FocusNode? focusNode;
  final bool autofocus;

  bool get isTwoLine => subtitle != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'isThreeLine',
      value: isThreeLine,
      ifFalse: isTwoLine ? 'two lines' : 'one line',
    ));
    properties.add(DiagnosticsProperty('shape', shape));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
      'contentPadding',
      contentPadding,
    ));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
    final theme = FluentTheme.of(context);

    print(selectionMode);

    return HoverButton(
      onPressed: onPressed ??
          () {
            if (onSelectionChange != null) {
              switch (selectionMode) {
                case ListTileSelectionMode.multiple:
                  onSelectionChange!(!selected);
                  break;
                case ListTileSelectionMode.single:
                  if (!selected) onSelectionChange!(true);
                  break;
                default:
                  break;
              }
            }
          },
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (context, states) {
        final Color tileColor = () {
          if (this.tileColor != null) {
            return this.tileColor!.resolve(states);
          }

          return ButtonThemeData.uncheckedInputColor(
            theme,
            selected ? {ButtonStates.hovering} : states,
            transparentWhenNone: true,
            transparentWhenDisabled: true,
          );
        }();

        const placeholder = SizedBox(width: 9.0);

        final tile = Row(children: [
          if (selectionMode == ListTileSelectionMode.none)
            placeholder
          else if (selectionMode == ListTileSelectionMode.multiple)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 6.0),
              child: Checkbox(
                checked: selected,
                onChanged: (v) {
                  onSelectionChange?.call(v ?? false);
                },
              ),
            )
          else if (selectionMode == ListTileSelectionMode.single)
            TweenAnimationBuilder<double>(
              duration: theme.mediumAnimationDuration,
              tween: Tween<double>(
                begin: 0.0,
                end: selected
                    ? states.isPressing
                        ? 8.0
                        : 16.0
                    : 0.0,
              ),
              builder: (context, height, child) => Container(
                height: height,
                width: 3.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  color: selected
                      ? theme.accentColor.defaultBrushFor(theme.brightness)
                      : Colors.transparent,
                ),
                margin: const EdgeInsets.only(right: 6.0),
              ),
            )
          else
            placeholder,
          if (leading != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: leading,
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style:
                        (theme.typography.body ?? const TextStyle()).copyWith(
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.clip,
                    child: title!,
                  ),
                if (subtitle != null)
                  DefaultTextStyle(
                    style: theme.typography.caption ?? const TextStyle(),
                    overflow: TextOverflow.clip,
                    child: subtitle!,
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ]);

        return Container(
          decoration: ShapeDecoration(
            shape: shape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
            color: tileColor,
          ),
          constraints: BoxConstraints(
            minHeight: isThreeLine
                ? kThreeLineTileHeight
                : isTwoLine
                    ? kTwoLineTileHeight
                    : kOneLineTileHeight,
            minWidth: 88.0,
          ),
          padding: contentPadding,
          margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: FocusBorder(
            focused: states.isFocused,
            child: tile,
          ),
        );
      },
    );
  }
}
