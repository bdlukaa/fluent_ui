import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../utils/focus.dart';

class TabView extends StatelessWidget {
  const TabView({
    Key? key,
    required this.currentIndex,
    this.onChanged,
    required this.tabs,
    required this.bodies,
    this.showNewButton = true,
    this.onNewPressed,
    this.addIconData = Icons.add,
  })  : assert(tabs.length == bodies.length),
        super(key: key);

  final int currentIndex;
  final ValueChanged<int>? onChanged;

  final List<Tab> tabs;
  final List<Widget> bodies;

  final bool showNewButton;
  final void Function()? onNewPressed;

  final IconData addIconData;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('currentIndex', currentIndex));
    properties.add(FlagProperty('showNewButton', value: showNewButton));
    properties.add(IconDataProperty('addIconData', addIconData));
    properties.add(ObjectFlagProperty(
      'onChanged',
      onChanged,
      ifNull: 'disabled',
    ));
    properties.add(ObjectFlagProperty(
      'onNewPressed',
      onNewPressed,
      ifNull: 'no new button',
    ));
    properties.add(IntProperty('tabs', tabs.length));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final divider = SizedBox(
      height: kTileHeight,
      child: Divider(
        direction: Axis.vertical,
        style: DividerStyle(
          margin: (_) => EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
    return Acrylic(
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: 4.5),
          padding: EdgeInsets.only(left: 8),
          height: kTileHeight,
          width: double.infinity,
          child: Row(children: [
            ...tabs.map((e) {
              final index = tabs.indexOf(e);
              final tab = _Tab(
                e,
                selected: index == currentIndex,
                onPressed: onChanged == null ? null : () => onChanged!(index),
              );
              late Widget child;
              if ([currentIndex - 1, currentIndex].contains(index)) {
                child = Flexible(
                  fit: FlexFit.loose,
                  child: tab,
                );
              } else {
                child = Flexible(
                  fit: FlexFit.loose,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: tab,
                    ),
                    divider,
                  ]),
                );
              }
              // TODO: reorder tab view by dragging.
              return child;
            }).toList(),
            if (showNewButton)
              IconButton(
                icon: Icon(addIconData),
                onPressed: onNewPressed,
                style: IconButtonStyle(
                  margin: EdgeInsets.only(left: 2),
                  iconStyle: (state) => IconStyle(
                    size: 16,
                    color: () {
                      if (state.isDisabled || state.isNone)
                        return context.theme.disabledColor;
                      else
                        return context.theme.inactiveColor;
                    }(),
                  ),
                ),
              ),
          ]),
        ),
        if (bodies.isNotEmpty) Expanded(child: bodies[currentIndex]),
      ]),
    );
  }
}

const double kTileWidth = 240.0;
const double kTileHeight = 35.0;

class Tab {
  const Tab({
    Key? key,
    this.icon = const FlutterLogo(),
    required this.text,
    this.closeIcon,
    this.semanticsLabel,
  });

  final Widget? icon;
  final Widget text;
  final Widget? closeIcon;

  final String? semanticsLabel;
}

class _Tab extends StatelessWidget {
  _Tab(
    this.tab, {
    Key? key,
    this.onPressed,
    required this.selected,
  }) : super(key: key);

  final Tab tab;
  final bool selected;
  final void Function()? onPressed;
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme;
    return HoverButton(
      semanticsLabel: tab.semanticsLabel,
      focusNode: focusNode,
      cursor: selected ? (_) => SystemMouseCursors.basic : null,
      onPressed: onPressed,
      builder: (context, state) {
        Widget child = Container(
          height: kTileHeight,
          constraints: BoxConstraints(
            maxWidth: kTileWidth,
            minWidth: kTileWidth / 4,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            color: selected
                ? style.scaffoldBackgroundColor
                : uncheckedInputColor(style, state),
          ),
          child: Row(children: [
            if (tab.icon != null)
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: tab.icon!,
              ),
            Expanded(child: tab.text),
            if (tab.closeIcon != null)
              Theme(
                data: style.copyWith(Style(
                  iconButtonStyle: style.iconButtonStyle?.copyWith(
                    IconButtonStyle(
                      decoration: (state) {
                        late Color? color;
                        if (state.isNone)
                          color = null;
                        else
                          color = buttonColor(style, state);
                        return BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(style: BorderStyle.none),
                          color: color,
                        );
                      },
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      iconStyle: (state) => IconStyle(
                        size: 20,
                        color: () {
                          if (state.isDisabled || state.isNone)
                            return context.theme.disabledColor;
                          else
                            return context.theme.inactiveColor;
                        }(),
                      ),
                    ),
                  ),
                )),
                child: tab.closeIcon!,
              ),
          ]),
        );
        child = FocusBorder(
          child: child,
          focused: state.isFocused,
        );
        return Semantics(
          selected: selected,
          child: child,
        );
      },
    );
  }
}
