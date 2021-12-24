import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:scroll_pos/scroll_pos.dart';

const double _kMaxTileWidth = 240.0;
const double _kMinTileWidth = 100.0;
const double _kTileHeight = 35.0;
const double _kButtonWidth = 40.0;

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
  TabView({
    Key? key,
    required this.currentIndex,
    this.onChanged,
    required this.tabs,
    required this.bodies,
    this.onNewPressed,
    this.addIconData = FluentIcons.add,
    this.shortcutsEnabled = true,
    this.onReorder,
    this.showScrollButtons = true,
    this.wheelScroll = false,
    ScrollPosController? scrollPosController,
    this.minTabWidth = _kMinTileWidth,
    this.maxTabWidth = _kMaxTileWidth,
  })  : assert(tabs.length == bodies.length),
        assert(minTabWidth > 0 && maxTabWidth > 0),
        assert(minTabWidth < maxTabWidth),
        super(key: key) {
    this.scrollPosController = scrollPosController ??
        ScrollPosController(
          itemCount: tabs.length,
          animationDuration: const Duration(milliseconds: 100),
        );
  }

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

  /// The controller used for move tabview to right and left when the
  /// larger of all items is bigger than screen width.
  late final ScrollPosController scrollPosController;

  /// Indicate if the wheel scroll change the tabs positions.
  final bool wheelScroll;

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
    final Widget child = GestureDetector(
      onTertiaryTapUp: (_) => tabs[index].onClosed?.call(),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
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
      ]),
    );
    return AnimatedContainer(
      key: ValueKey<Tab>(tab),
      width: preferredTabWidth,
      duration: FluentTheme.of(context).fastAnimationDuration,
      curve: FluentTheme.of(context).animationCurve,
      child: child,
    );
  }

  Widget _buttonTabBuilder(
    BuildContext context,
    Icon icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: _kButtonWidth,
      height: _kTileHeight - 10,
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
          style: ButtonStyle(
            foregroundColor: ButtonState.resolveWith((states) {
              if (states.isDisabled || states.isNone) {
                return FluentTheme.of(context).disabledColor;
              } else {
                return FluentTheme.of(context).inactiveColor;
              }
            }),
            padding: ButtonState.all(
              const EdgeInsets.symmetric(
                horizontal: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    const divider = SizedBox(
      height: _kTileHeight,
      child: Divider(
        direction: Axis.vertical,
        style: DividerThemeData(
          verticalMargin: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
    Widget tabBar = Acrylic(
      child: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 4.5),
          padding: const EdgeInsets.only(left: 8),
          height: _kTileHeight,
          width: double.infinity,
          child: LayoutBuilder(builder: (context, consts) {
            final width = consts.biggest.width;
            assert(
              width.isFinite,
              'You can only create a TabView in a RenderBox with defined width',
            );

            final preferredTabWidth =
                ((width - (showNewButton ? _kButtonWidth : 0)) / tabs.length)
                    .clamp(
              minTabWidth,
              maxTabWidth,
            );

            final listView = Listener(
              onPointerSignal: wheelScroll
                  ? (PointerSignalEvent e) {
                      if (e is PointerScrollEvent) {
                        if (e.scrollDelta.dy > 0) {
                          scrollPosController.forward(
                              align: false, animate: false);
                        } else {
                          scrollPosController.backward(
                              align: false, animate: false);
                        }
                      }
                    }
                  : null,
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                scrollController: scrollPosController,
                onReorder: (i, ii) {
                  onReorder?.call(i, ii);
                },
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
              ),
            );

            bool scrollable = preferredTabWidth * tabs.length >
                width - (showNewButton ? _kButtonWidth : 0);

            return Row(children: [
              if (showScrollButtons && scrollable)
                _buttonTabBuilder(
                  context,
                  const Icon(FluentIcons.caret_left_solid8, size: 10),
                  () {
                    scrollPosController.backward();
                  },
                ),
              if (scrollable)
                Expanded(child: listView)
              else
                SizedBox(
                  width: preferredTabWidth * tabs.length,
                  child: listView,
                ),
              if (showScrollButtons && scrollable)
                _buttonTabBuilder(
                  context,
                  const Icon(FluentIcons.caret_right_solid8, size: 10),
                  () {
                    scrollPosController.forward();
                  },
                ),
              if (showNewButton)
                _buttonTabBuilder(
                  context,
                  Icon(addIconData, size: 16.0),
                  onNewPressed!,
                ),
            ]);
          }),
        ),
        if (bodies.isNotEmpty) Expanded(child: bodies[currentIndex]),
      ]),
    );
    if (shortcutsEnabled) {
      void _onClosePressed() {
        tabs[currentIndex].onClosed?.call();
      }

      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.f4, control: true):
              _onClosePressed,
          const SingleActivator(LogicalKeyboardKey.keyW, control: true):
              _onClosePressed,
          const SingleActivator(LogicalKeyboardKey.keyT, control: true): () {
            onNewPressed?.call();
          },
          ...Map.fromIterable(
            List<int>.generate(9, (index) => index),
            key: (i) {
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
              return SingleActivator(digits[i], control: true);
            },
            value: (tab) {
              return () {
                // If it's the last, move to the last tab
                if (tab == 8) {
                  onChanged?.call(tabs.length - 1);
                } else {
                  if (tabs.length - 1 >= tab) onChanged?.call(tab);
                }
              };
            },
          ),
        },
        child: tabBar,
      );
    }
    return tabBar;
  }
}

class Tab {
  const Tab({
    Key? key,
    this.icon = const FlutterLogo(),
    required this.text,
    this.closeIcon = FluentIcons.close,
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
    final ThemeData theme = FluentTheme.of(context);
    return HoverButton(
      semanticLabel: widget.tab.semanticLabel,
      focusNode: widget.focusNode,
      onPressed: widget.onPressed,
      builder: (context, state) {
        final primaryBorder = FluentTheme.of(context).focusTheme.primaryBorder;
        Widget child = Container(
          height: _kTileHeight,
          constraints: const BoxConstraints(
            maxWidth: _kMaxTileWidth,
            minWidth: _kMinTileWidth,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
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
                : const BorderRadius.vertical(top: Radius.circular(4)),
            color: widget.selected
                ? theme.scaffoldBackgroundColor
                : ButtonThemeData.uncheckedInputColor(theme, state),
          ),
          child: () {
            final result = ClipRect(
              child: Row(children: [
                if (widget.tab.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: widget.tab.icon!,
                  ),
                Expanded(
                  child: DefaultTextStyle(
                    style: theme.typography.body ?? const TextStyle(),
                    child: widget.tab.text,
                  ),
                ),
                if (widget.tab.closeIcon != null)
                  FocusTheme(
                    data: const FocusThemeData(
                      primaryBorder: BorderSide.none,
                      secondaryBorder: BorderSide.none,
                    ),
                    child: IconButton(
                      icon: Icon(widget.tab.closeIcon, size: 12.0),
                      onPressed: widget.tab.onClosed,
                      style: ButtonStyle(
                        shape: ButtonState.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        )),
                        padding: ButtonState.all(
                          const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                        ),
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
          child: child,
          // child: SizeTransition(
          //   sizeFactor: Tween<double>(
          //     begin: 0.8,
          //     end: 1.0,
          //   ).animate(CurvedAnimation(
          //     curve: widget.animationCurve,
          //     parent: _controller,
          //   )),
          //   axis: Axis.horizontal,
          //   child: child,
          // ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
