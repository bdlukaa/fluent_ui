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
/// There must be enough space to render the tabview.
///
/// See also:
///   - [NavigationPanel]
class TabView extends StatelessWidget {
  /// Creates a tab view.
  ///
  /// [tabs] must have the same length as [bodies]
  ///
  /// [minTabWidth] and [maxTabWidth] must be non-negative
  ///
  /// [maxTabWidth] must be greater than [minTabWidth]
  const TabView({
    Key? key,
    required this.currentIndex,
    this.onChanged,
    required this.tabs,
    required this.bodies,
    this.onNewPressed,
    this.addIconData = Icons.add,
    this.shortcutsEnabled = true,
    this.onReorder,
    this.showScrollButtons = true,
    this.minTabWidth = _kMinTileWidth,
    this.maxTabWidth = _kMaxTileWidth,
  })  : assert(tabs.length == bodies.length),
        assert(minTabWidth > 0 && maxTabWidth > 0),
        assert(minTabWidth < maxTabWidth),
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

  /// Whether the following shortcuts are enabled:
  ///
  /// - Ctrl + T to create a new tab
  /// - Ctrl + F4 or Ctrl + W to close the current tab
  /// - `1` to `8` to navigate through tabs
  /// - `9` to navigate to the last tab
  final bool shortcutsEnabled;

  /// Called when the tabs are reordered. If null,
  /// reordering is disabled. It's disabled by default.
  final ReorderCallback? onReorder;

  /// The min width a tab can have. Must not be negative.
  /// Default to 100 logical pixels.
  final double minTabWidth;

  /// The max width a tab can have. Must not be negative
  /// and must be greater than [minTabWidth]. Default to
  /// 240 logical pixels
  final double maxTabWidth;

  /// Whether the buttons that scroll forward or backward
  /// should be displayed, if necessary. Defaults to true
  final bool showScrollButtons;

  /// Whenever the new button should be displayed.
  bool get showNewButton => onNewPressed != null;

  /// Whether reordering is enabled or not. To enable it,
  /// make sure [widget.onReorder] is not null.
  bool get isReorderEnabled => onReorder != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('currentIndex', currentIndex));
    properties.add(FlagProperty(
      'showNewButton',
      value: showNewButton,
      ifFalse: 'no new button',
    ));
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
    properties.add(FlagProperty(
      'reorderEnabled',
      value: isReorderEnabled,
      ifFalse: 'reorder disabled',
    ));
    properties.add(FlagProperty(
      'showScrollButtons',
      value: showScrollButtons,
      ifFalse: 'hide scroll buttons',
    ));
  }

  Widget _tabBuilder(
    BuildContext context,
    int index,
    Widget divider,
    double preferredTabWidth,
  ) {
    final Tab tab = tabs[index];
    final Widget child = Row(mainAxisSize: MainAxisSize.min, children: [
      Flexible(
        fit: FlexFit.loose,
        child: _Tab(
          tab,
          key: ValueKey<int>(index),
          reorderIndex: isReorderEnabled ? index : null,
          selected: index == currentIndex,
          onPressed: onChanged == null ? null : () => onChanged!(index),
          animationDuration: FluentTheme.of(context).fastAnimationDuration,
          animationCurve: FluentTheme.of(context).animationCurve,
        ),
      ),
      if (![currentIndex - 1, currentIndex].contains(index)) divider,
    ]);
    return AnimatedContainer(
      key: ValueKey<Tab>(tab),
      width: preferredTabWidth,
      duration: FluentTheme.of(context).fastAnimationDuration,
      curve: FluentTheme.of(context).animationCurve,
      child: child,
    );
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
          child: LayoutBuilder(builder: (context, consts) {
            final width = consts.biggest.width;
            assert(
              width.isFinite,
              'You can only create a TabView in a RenderBox with defined width',
            );

            /// The preferred size is the width / tabs.length, but it
            /// must be in the range of [_kMinTileWidth] to `_kMaxTileWidth`
            /// 8.0 is subtracted because of the dividers and the 'new' button
            /// 8.0 is the minimum value that works. It can be greater
            final preferredTabWidth = ((width / tabs.length) - 8.0).clamp(
              minTabWidth,
              maxTabWidth,
            );

            final listView = ReorderableListView.builder(
              buildDefaultDragHandles: false,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              onReorder: onReorder!,
              itemCount: tabs.length,
              proxyDecorator: (child, index, animation) {
                return child;
              },
              itemBuilder: (context, index) {
                return _tabBuilder(
                  context,
                  index,
                  divider,
                  preferredTabWidth,
                );
              },
            );
            return Row(children: [
              if (preferredTabWidth * tabs.length >
                  width - (showNewButton ? 40.0 : 0))
                Expanded(child: listView)
              else
                SizedBox(
                  width: preferredTabWidth * tabs.length,
                  child: listView,
                ),
              if (showNewButton)
                IconButton(
                  key: ValueKey<int>(tabs.length),
                  icon: Icon(addIconData),
                  onPressed: onNewPressed,
                  iconTheme: (state) {
                    return IconThemeData(
                      color: () {
                        if (state.isDisabled || state.isNone)
                          return FluentTheme.of(context).disabledColor;
                        else
                          return FluentTheme.of(context).inactiveColor;
                      }(),
                    );
                  },
                  style: ButtonThemeData(margin: EdgeInsets.only(left: 2)),
                ),
            ]);
          }),
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
          // TODO: Ctrl + number. See https://github.com/bdlukaa/fluent_ui/issues/15
          ...Map.fromIterable(
            List<int>.generate(9, (index) => index),
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

const double _kMaxTileWidth = 240.0;
const double _kMinTileWidth = 100.0;
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

class _Tab extends StatefulWidget {
  const _Tab(
    this.tab, {
    Key? key,
    this.onPressed,
    required this.selected,
    this.focusNode,
    this.reorderIndex,
    this.animationDuration = Duration.zero,
    this.animationCurve = Curves.linear,
  }) : super(key: key);

  final Tab tab;
  final bool selected;
  final void Function()? onPressed;
  final FocusNode? focusNode;
  final int? reorderIndex;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  __TabState createState() => __TabState();
}

class __TabState extends State<_Tab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Tab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = oldWidget.animationDuration;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(debugCheckHasFluentTheme(context));
    final style = FluentTheme.of(context);
    return HoverButton(
      semanticLabel: widget.tab.semanticLabel,
      focusNode: widget.focusNode,
      cursor: widget.selected ? ButtonState.all(MouseCursor.defer) : null,
      onPressed: widget.onPressed,
      builder: (context, state) {
        final primaryBorder = FluentTheme.of(context).focusTheme.primaryBorder;
        Widget child = Container(
          height: _kTileHeight,
          constraints: BoxConstraints(
            maxWidth: _kMaxTileWidth,
            minWidth: _kMinTileWidth,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            /// Using a [FocusBorder] here would be more adequate, but it
            /// seems it disabled the reordering effect. Using this boder
            /// have the same effect, but make sure to update the code here
            /// whenever [FocusBorder] code is altered
            border: Border.all(
              style: state.isFocused ? BorderStyle.solid : BorderStyle.none,
              color: primaryBorder?.color ?? Colors.transparent,
              width: primaryBorder?.width ?? 0.0,
            ),
            borderRadius: state.isFocused
                ? BorderRadius.zero
                : BorderRadius.vertical(top: Radius.circular(4)),
            color: widget.selected
                ? style.scaffoldBackgroundColor
                : ButtonThemeData.uncheckedInputColor(style, state),
          ),
          child: () {
            final result = ClipRect(
              child: Row(children: [
                if (widget.tab.icon != null)
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: widget.tab.icon!,
                  ),
                Expanded(child: widget.tab.text),
                if (widget.tab.closeIcon != null)
                  FocusTheme(
                    data: FocusThemeData(
                      primaryBorder: BorderSide.none,
                      secondaryBorder: BorderSide.none,
                    ),
                    child: IconButton(
                      icon: Icon(widget.tab.closeIcon),
                      onPressed: widget.tab.onClosed,
                      iconTheme: (state) {
                        return IconThemeData(
                          size: 18,
                          color: () {
                            if (state.isDisabled || state.isNone)
                              return FluentTheme.of(context).disabledColor;
                            else
                              return FluentTheme.of(context).inactiveColor;
                          }(),
                        );
                      },
                      style: ButtonThemeData(
                        decoration: ButtonState.resolveWith((states) {
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
                        }),
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
              ]),
            );
            if (widget.reorderIndex != null) {
              return ReorderableDragStartListener(
                child: result,
                index: widget.reorderIndex!,
              );
            }
            return result;
          }(),
        );
        return Semantics(
          selected: widget.selected,
          focusable: true,
          focused: state.isFocused,
          child: SizeTransition(
            sizeFactor: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(
              curve: widget.animationCurve,
              parent: _controller,
            )),
            axis: Axis.horizontal,
            child: child,
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
