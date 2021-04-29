import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// The TabView control is a way to display a set of tabs
/// and their respective content. TabViews are useful for
/// displaying several pages (or documents) of content while
/// giving a user the capability to rearrange, open, or close
/// new tabs.
///
/// ![TabView Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/tabview/tab-introduction.png)
///
/// See also:
///   - [NavigationPanel]
class TabView extends StatelessWidget {
  /// Creates a tab view.
  ///
  /// [tabs] must have the same length as [bodies]
  const TabView({
    Key? key,
    required this.currentIndex,
    this.onChanged,
    required this.tabs,
    required this.bodies,
    this.onNewPressed,
    this.addIconData = Icons.add,
    this.shortcutsEnabled = true,
  })  : assert(tabs.length == bodies.length),
        super(key: key);

  /// The index of the tab to be displayed
  final int currentIndex;

  /// Whether another tab was requested to be displayed
  final ValueChanged<int>? onChanged;

  /// The tabs to be displayed. This must have the same
  /// length of [bodies]
  final List<Tab> tabs;

  /// The bodies of the tabs. This must have the same
  /// length of [tabs]
  final List<Widget> bodies;

  /// Called when the new button is pressed or when the
  /// shortcut `Ctrl + T` is executed.
  ///
  /// If null, the new button won't be displayed
  final void Function()? onNewPressed;

  /// The icon of the new button
  final IconData addIconData;

  /// Whenever the new button should be displayed.
  bool get showNewButton => onNewPressed != null;

  /// Whether the following shortcuts are enabled:
  ///
  /// - Ctrl + T to create a new tab
  /// - Ctrl + F4 or Ctrl + W to close the current tab
  /// - `1` to `8` to navigate through tabs
  /// - `9` to navigate to the last tab
  final bool shortcutsEnabled;

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
    assert(debugCheckHasFluentTheme(context));
    final divider = SizedBox(
      height: _kTileHeight,
      child: Divider(
        direction: Axis.vertical,
        style: DividerThemeData(
          margin: (_) => EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
    Widget tabBar = Acrylic(
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: 4.5),
          padding: EdgeInsets.only(left: 8),
          height: _kTileHeight,
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
                iconTheme: (state) {
                  return IconThemeData(
                    color: () {
                      if (state.isDisabled || state.isNone)
                        return context.theme.disabledColor;
                      else
                        return context.theme.inactiveColor;
                    }(),
                  );
                },
                style: ButtonThemeData(margin: EdgeInsets.only(left: 2)),
              ),
          ]),
        ),
        if (bodies.isNotEmpty) Expanded(child: bodies[currentIndex]),
      ]),
    );
    if (shortcutsEnabled)
      return Shortcuts(
        shortcuts: {
          /// Ctrl + F4 or Ctrl + W closes the current tab
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.f4,
          ): _TabCloseIntent(),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyW,
          ): _TabCloseIntent(),

          /// Ctrl + T creates a new tab
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyT,
          ): _OpenNewTabIntent(),

          /// Ctrl + (number from 1 to 8) navigate to that tab
          /// Ctrl + 9 navigates to the last tab
          /// TODO(bdlukaa): Ctrl + number. Currently blocked by https://github.com/bdlukaa/fluent_ui/issues/15
          ...Map.fromIterable(
            List.generate(9, (index) => index),
            key: (number) {
              final digits = [
                LogicalKeyboardKey.digit1,
                LogicalKeyboardKey.digit2,
                LogicalKeyboardKey.digit3,
                LogicalKeyboardKey.digit4,
                LogicalKeyboardKey.digit5,
                LogicalKeyboardKey.digit6,
                LogicalKeyboardKey.digit7,
                LogicalKeyboardKey.digit8,
                LogicalKeyboardKey.digit9,
              ];
              return LogicalKeySet(digits[number]);
            },
            value: (number) => _ChangeTabIntent(number),
          ),
        },
        child: Actions(
          actions: {
            _TabCloseIntent: CallbackAction<_TabCloseIntent>(onInvoke: (_) {
              tabs[currentIndex].onClosed?.call();
            }),
            _OpenNewTabIntent: CallbackAction<_OpenNewTabIntent>(onInvoke: (_) {
              onNewPressed?.call();
            }),
            _ChangeTabIntent: CallbackAction<_ChangeTabIntent>(onInvoke: (i) {
              final tab = i.tab;
              if (tab == 8) {
                onChanged?.call(tabs.length - 1);
              } else {
                if (tabs.length - 1 >= tab) onChanged?.call(tab);
              }
            }),
          },
          child: Focus(child: tabBar),
        ),
      );
    return tabBar;
  }
}

class _TabCloseIntent extends Intent {}

class _OpenNewTabIntent extends Intent {}

class _ChangeTabIntent extends Intent {
  final int tab;

  _ChangeTabIntent(this.tab);
}

const double _kTileWidth = 240.0;
const double _kTileHeight = 35.0;

class Tab {
  const Tab({
    Key? key,
    this.icon = const FlutterLogo(),
    required this.text,
    this.closeIcon = Icons.close,
    this.onClosed,
    this.semanticLabel,
  });

  /// The leading icon of the tab. [FlutterLogo] is used by default
  final Widget? icon;

  /// The text of the tab. Usually a [Text] widget
  final Widget text;

  /// The close icon of the tab. Usually an [IconButton] widget
  final IconData? closeIcon;

  /// Called when the close button is called or when the
  /// shortcut `Ctrl + T` or `Ctrl + F4` is executed
  final VoidCallback? onClosed;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;
}

class _Tab extends StatelessWidget {
  _Tab(
    this.tab, {
    Key? key,
    this.onPressed,
    required this.selected,
    this.focusNode,
  }) : super(key: key);

  final Tab tab;
  final bool selected;
  final void Function()? onPressed;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = context.theme;
    return HoverButton(
      semanticLabel: tab.semanticLabel,
      focusNode: focusNode,
      cursor: selected ? (_) => SystemMouseCursors.basic : null,
      onPressed: onPressed,
      builder: (context, state) {
        Widget child = Container(
          height: _kTileHeight,
          constraints: BoxConstraints(
            maxWidth: _kTileWidth,
            minWidth: _kTileWidth / 4,
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
              FluentTheme(
                data: style.copyWith(
                  focusTheme: FocusThemeData(
                    primaryBorder: BorderSide(
                      width: 1,
                      color: style.inactiveColor,
                    ),
                  ),
                ),
                child: IconButton(
                  icon: Icon(tab.closeIcon),
                  onPressed: tab.onClosed,
                  iconTheme: (state) {
                    return IconThemeData(
                      size: 20,
                      color: () {
                        if (state.isDisabled || state.isNone)
                          return context.theme.disabledColor;
                        else
                          return context.theme.inactiveColor;
                      }(),
                    );
                  },
                  style: ButtonThemeData(
                    decoration: (state) {
                      late Color? color;
                      if (state.isNone)
                        color = null;
                      else
                        color = ButtonThemeData.buttonColor(style, state);
                      return BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(style: BorderStyle.none),
                        color: color,
                      );
                    },
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    // iconTheme: (state) => IconThemeData(
                    //   size: 20,
                    //   color: () {
                    //     if (state.isDisabled || state.isNone)
                    //       return context.theme.disabledColor;
                    //     else
                    //       return context.theme.inactiveColor;
                    //   }(),
                    // ),
                  ),
                ),
              ),
          ]),
        );
        return Semantics(
          selected: selected,
          focusable: true,
          focused: state.isFocused,
          child: FocusBorder(child: child, focused: state.isFocused),
        );
      },
    );
  }
}
