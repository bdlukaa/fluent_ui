import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class ListCell extends StatelessWidget {
  const ListCell({
    Key key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.style,
  })  : _otherCell = null,
        super(key: key);

  ListCell.checkbox({
    Key key,
    Widget opposite,
    CheckboxStyle checkboxStyle,
    ListCellStyle cellStyle,
    @required bool checked,
    @required ValueChanged<bool> onChanged,
    String semanticsLabel,
  })  : _otherCell = CheckboxListCell(
          checked: checked,
          onChanged: onChanged,
          cellStyle: cellStyle,
          checkboxStyle: checkboxStyle,
          opposite: opposite,
          semanticsLabel: semanticsLabel,
        ),
        onLongPress = null,
        onPressed = null,
        leading = null,
        trailing = null,
        title = null,
        subtitle = null,
        style = null,
        super(key: key);

  ListCell.toggle({
    Key key,
    Widget opposite,
    ToggleSwitchStyle toggleStyle,
    ListCellStyle cellStyle,
    @required bool checked,
    @required ValueChanged<bool> onChanged,
    String semanticsLabel,
  })  : _otherCell = ToggleListCell(
          checked: checked,
          onChanged: onChanged,
          cellStyle: cellStyle,
          toggleStyle: toggleStyle,
          opposite: opposite,
          semanticsLabel: semanticsLabel,
        ),
        onLongPress = null,
        onPressed = null,
        leading = null,
        trailing = null,
        title = null,
        subtitle = null,
        style = null,
        super(key: key);

  final Widget _otherCell;

  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;

  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  final ListCellStyle style;

  @override
  Widget build(BuildContext context) {
    if (_otherCell != null) return _otherCell;
    debugCheckHasFluentTheme(context);
    final style = context.theme.listCellStyle.copyWith(this.style);
    return HoverButton(
      cursor: style.cursor,
      onPressed: onPressed,
      onLongPress: onLongPress,
      builder: (context, state) => Container(
        padding: style.padding,
        color: style.backgroundColor(state),
        child: Row(
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: leading,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    DefaultTextStyle(
                      child: title,
                      style: style.titleStyle(state),
                    ),
                  if (subtitle != null)
                    DefaultTextStyle(
                      child: title,
                      style: style.subtitleStyle(state),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}

enum ListCellPositioning { left, right }

class CheckboxListCell extends StatelessWidget {
  const CheckboxListCell({
    Key key,
    this.title,
    this.subtitle,
    this.opposite,
    this.cellStyle,
    this.checkboxStyle,
    @required this.onChanged,
    @required this.checked,
    this.semanticsLabel,
  })  : assert(checked != null),
        assert(onChanged != null),
        super(key: key);

  final Widget title;
  final Widget subtitle;
  final Widget opposite;
  final ListCellStyle cellStyle;
  final CheckboxStyle checkboxStyle;

  final bool checked;
  final ValueChanged<bool> onChanged;

  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.listCellStyle.copyWith(cellStyle);
    return ListCell(
      title: title,
      subtitle: subtitle,
      onPressed: onChanged == null ? null : () => onChanged(!checked),
      leading: style.buttonsPositioning == ListCellPositioning.left
          ? _buildCheckbox(context)
          : null,
      trailing: style.buttonsPositioning == ListCellPositioning.right
          ? _buildCheckbox(context)
          : null,
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Checkbox(
      checked: checked,
      onChanged: onChanged,
      style: checkboxStyle,
      semanticsLabel: semanticsLabel,
    );
  }
}

class ToggleListCell extends StatelessWidget {
  const ToggleListCell({
    Key key,
    this.title,
    this.subtitle,
    this.opposite,
    this.cellStyle,
    this.toggleStyle,
    @required this.onChanged,
    @required this.checked,
    this.semanticsLabel,
  })  : assert(checked != null),
        assert(onChanged != null),
        super(key: key);

  final Widget title;
  final Widget subtitle;
  final Widget opposite;
  final ListCellStyle cellStyle;
  final ToggleSwitchStyle toggleStyle;

  final bool checked;
  final ValueChanged<bool> onChanged;

  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.listCellStyle.copyWith(cellStyle);
    return ListCell(
      title: title,
      subtitle: subtitle,
      onPressed: onChanged == null ? null : () => onChanged(!checked),
      leading: style.buttonsPositioning == ListCellPositioning.left
          ? _buildToggle(context)
          : null,
      trailing: style.buttonsPositioning == ListCellPositioning.right
          ? _buildToggle(context)
          : null,
    );
  }

  Widget _buildToggle(BuildContext context) {
    return ToggleSwitch(
      checked: checked,
      onChanged: onChanged,
      style: toggleStyle,
      semanticsLabel: semanticsLabel,
    );
  }
}

class ListCellStyle {
  /// The cursor of the cell
  final ButtonState<MouseCursor> cursor;

  /// The color of the cell
  final ButtonState<Color> backgroundColor;

  /// The title style
  final ButtonState<TextStyle> titleStyle;

  /// The subtitle style
  final ButtonState<TextStyle> subtitleStyle;

  /// The padding applied to the cell. Margin is not enabled by default
  final EdgeInsetsGeometry padding;

  /// The positioning of [Checkbox] and [Toggle] in
  /// [CheckboxListTile] and [ToggleListTile]
  final ListCellPositioning buttonsPositioning;

  ListCellStyle({
    this.cursor,
    this.backgroundColor,
    this.titleStyle,
    this.subtitleStyle,
    this.padding,
    this.buttonsPositioning,
  });

  /// The default theme for [ListCellStyle]
  static ListCellStyle defaultTheme([Brightness brightness]) {
    final def = ListCellStyle(
      cursor: buttonCursor,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      buttonsPositioning: ListCellPositioning.right,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(ListCellStyle(
        // backgroundColor: (state) => lightButtonBackgroundColor(
        //   state,
        //   disabledColor: Colors.transparent,
        // ),
        titleStyle: (_) => TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        subtitleStyle: (_) => TextStyle(color: Colors.grey),
      ));
    else
      return def.copyWith(ListCellStyle(
        // backgroundColor: (state) => darkButtonBackgroundColor(
        //   state,
        //   disabledColor: Colors.transparent,
        // ),
        titleStyle: (_) => TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        subtitleStyle: (_) => TextStyle(color: Colors.grey[50]),
      ));
  }

  /// Replace [this] with another [ListCellStyle]
  ListCellStyle copyWith(ListCellStyle style) {
    if (style == null) return this;
    return ListCellStyle(
      cursor: style?.cursor ?? cursor,
      backgroundColor: style?.backgroundColor ?? backgroundColor,
      titleStyle: style?.titleStyle ?? titleStyle,
      subtitleStyle: style?.subtitleStyle ?? subtitleStyle,
      padding: style?.padding ?? padding,
      buttonsPositioning: style?.buttonsPositioning ?? buttonsPositioning,
    );
  }
}
