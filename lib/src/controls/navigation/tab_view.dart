import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

const double _kMinTileWidth = 80.0;
const double _kMaxTileWidth = 240.0;
const double _kTileHeight = 34.0;
const double _kButtonWidth = 40.0;

enum CloseButtonVisibilityMode {
  /// The close button will never be visible
  never,

  /// The close button will always be visible
  always,

  /// The close button will only be shown on hover
  onHover,
}

/// Determines how the tab sizes itself
enum TabWidthBehavior {
  /// The tab will fit its content
  sizeToContent,

  /// If not scrollable, the tabs will have the same size
  equal,

  /// If not selected, the [Tab]'s text is hidden. The tab will fit its content
  compact,
}

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
class TabView extends StatefulWidget {
  /// Creates a tab view.
  ///
  /// [tabs] must have the same length as [bodies]
  ///
  /// [maxTabWidth] must be non-negative
  const TabView({
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
    this.scrollController,
    this.minTabWidth = _kMinTileWidth,
    this.maxTabWidth = _kMaxTileWidth,
    this.closeButtonVisibility = CloseButtonVisibilityMode.always,
    this.tabWidthBehavior = TabWidthBehavior.equal,
    this.header,
    this.footer,
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
  final VoidCallback? onNewPressed;

  /// The icon of the new button
  final IconData addIconData;

  /// Whether the following shortcuts are enabled:
  ///
  /// - Ctrl + T to create a new tab
  /// - Ctrl + F4 or Ctrl + W to close the current tab
  /// - `Ctrl+1` to `Ctrl+8` to navigate through tabs
  /// - `Ctrl+9` to navigate to the last tab
  final bool shortcutsEnabled;

  /// Called when the tabs are reordered. If null,
  /// reordering is disabled. It's disabled by default.
  final ReorderCallback? onReorder;

  /// The min width a tab can have. Must not be negative.
  ///
  /// Default to 80 logical pixels
  final double minTabWidth;

  /// The max width a tab can have. Must not be negative.
  ///
  /// Defaults to 240 logical pixels
  final double maxTabWidth;

  /// Whether the buttons that scroll forward or backward
  /// should be displayed, if necessary. Defaults to true
  final bool showScrollButtons;

  /// The [ScrollPosController] used to move tabview to right and left when the
  /// tabs don't fit the available horizontal space.
  ///
  /// If null, a [ScrollPosController] is created internally.
  final ScrollPosController? scrollController;

  /// Indicate if the wheel scroll changes the tabs positions.
  ///
  /// Defaults to `false`
  final bool wheelScroll;

  /// Indicates the close button visibility mode
  final CloseButtonVisibilityMode closeButtonVisibility;

  /// Indicates how a tab will size itself
  final TabWidthBehavior tabWidthBehavior;

  /// Displayed before all the tabs and buttons.
  ///
  /// Usually a [Text]
  final Widget? header;

  /// Displayed after all the tabs and buttons.
  ///
  /// Usually a [Text]
  final Widget? footer;

  /// Whenever the new button should be displayed.
  bool get showNewButton => onNewPressed != null;

  /// Whether reordering is enabled or not. To enable it,
  /// make sure [widget.onReorder] is not null.
  bool get isReorderEnabled => onReorder != null;

  @override
  State<StatefulWidget> createState() => _TabViewState();

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
    properties.add(EnumProperty('closeButtonVisibility', closeButtonVisibility,
        defaultValue: CloseButtonVisibilityMode.always));
  }
}

class _TabViewState extends State<TabView> {
  late ScrollPosController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController ??
        ScrollPosController(
          itemCount: widget.tabs.length,
          animationDuration: const Duration(milliseconds: 100),
        );
    scrollController.itemCount = widget.tabs.length;
    scrollController.addListener(_handleScrollUpdate);
  }

  void _handleScrollUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(TabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      scrollController.itemCount = widget.tabs.length;
    }
    if (widget.currentIndex != oldWidget.currentIndex) {
      scrollController.scrollToItem(widget.currentIndex, center: false);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      // only dispose the local controller
      scrollController.dispose();
    }
    super.dispose();
  }

  Widget _tabBuilder(
    BuildContext context,
    int index,
    double preferredTabWidth,
  ) {
    final Tab tab = widget.tabs[index];
    final tabWidget = _Tab(
      tab,
      key: ValueKey<int>(index),
      reorderIndex: widget.isReorderEnabled ? index : null,
      selected: index == widget.currentIndex,
      onPressed:
          widget.onChanged == null ? null : () => widget.onChanged!(index),
      animationDuration: FluentTheme.of(context).fastAnimationDuration,
      animationCurve: FluentTheme.of(context).animationCurve,
      visibilityMode: widget.closeButtonVisibility,
      tabWidthBehavior: widget.tabWidthBehavior,
    );
    final Widget child = GestureDetector(
      onTertiaryTapUp: (_) => tab.onClosed?.call(),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (widget.tabWidthBehavior == TabWidthBehavior.equal)
          Expanded(child: tabWidget)
        else
          Flexible(child: tabWidget),
        divider(index),
      ]),
    );
    final minWidth = () {
      switch (widget.tabWidthBehavior) {
        case TabWidthBehavior.sizeToContent:
          return null;
        default:
          return preferredTabWidth;
      }
    }();
    return AnimatedContainer(
      key: ValueKey<Tab>(tab),
      constraints: BoxConstraints(
        maxWidth: minWidth ?? double.infinity,
        minWidth: minWidth ?? 0.0,
      ),
      duration: FluentTheme.of(context).fastAnimationDuration,
      curve: FluentTheme.of(context).animationCurve,
      child: child,
    );
  }

  Widget _buttonTabBuilder(
    BuildContext context,
    Widget icon,
    VoidCallback? onPressed,
    String tooltip,
  ) {
    final item = SizedBox(
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
            backgroundColor: ButtonState.resolveWith((states) {
              if (states.isDisabled) return Colors.transparent;
              return ButtonThemeData.uncheckedInputColor(
                  FluentTheme.of(context), states);
            }),
            padding: ButtonState.all(
              const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ),
    );
    if (onPressed == null) return item;
    return Tooltip(
      message: tooltip,
      child: item,
    );
  }

  Widget divider(int index) {
    return SizedBox(
      height: _kTileHeight,
      child: Divider(
        direction: Axis.vertical,
        style: DividerThemeData(
          verticalMargin: const EdgeInsets.symmetric(vertical: 8),
          decoration:
              ![widget.currentIndex - 1, widget.currentIndex].contains(index)
                  ? null
                  : const BoxDecoration(color: Colors.transparent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    final TextDirection direction = Directionality.of(context);
    final ThemeData theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    final headerFooterTextStyle =
        (theme.typography.bodyLarge ?? const TextStyle());

    Widget tabBar = Column(children: [
      ScrollConfiguration(
        behavior: const _TabViewScrollBehavior(),
        child: Container(
          margin: const EdgeInsets.only(top: 4.5),
          padding: const EdgeInsets.only(left: 8),
          height: _kTileHeight,
          width: double.infinity,
          child: Row(
            children: [
              if (widget.header != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: DefaultTextStyle(
                    style: headerFooterTextStyle,
                    child: widget.header!,
                  ),
                ),
              Expanded(
                child: LayoutBuilder(builder: (context, consts) {
                  final width = consts.biggest.width;
                  assert(
                    width.isFinite,
                    'You can only create a TabView in a box with defined width',
                  );

                  final double preferredTabWidth =
                      ((width - (widget.showNewButton ? _kButtonWidth : 0)) /
                              widget.tabs.length)
                          .clamp(widget.minTabWidth, widget.maxTabWidth);

                  final Widget listView = Listener(
                    onPointerSignal: widget.wheelScroll
                        ? (PointerSignalEvent e) {
                            if (e is PointerScrollEvent) {
                              if (e.scrollDelta.dy > 0) {
                                scrollController.forward(
                                  align: false,
                                  animate: false,
                                );
                              } else {
                                scrollController.backward(
                                  align: false,
                                  animate: false,
                                );
                              }
                            }
                          }
                        : null,
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      scrollController: scrollController,
                      onReorder: (i, ii) {
                        widget.onReorder?.call(i, ii);
                      },
                      itemCount: widget.tabs.length,
                      proxyDecorator: (child, index, animation) {
                        return child;
                      },
                      itemBuilder: (context, index) {
                        return _tabBuilder(
                          context,
                          index,
                          preferredTabWidth,
                        );
                      },
                    ),
                  );

                  bool scrollable = preferredTabWidth * widget.tabs.length >
                      width - (widget.showNewButton ? _kButtonWidth : 0);

                  final bool showScrollButtons =
                      widget.showScrollButtons && scrollable;
                  final backwardButton = _buttonTabBuilder(
                    context,
                    const Icon(FluentIcons.caret_left_solid8, size: 10),
                    !scrollController.canBackward
                        ? () {
                            if (direction == TextDirection.ltr) {
                              scrollController.backward();
                            } else {
                              scrollController.forward();
                            }
                          }
                        : null,
                    localizations.scrollTabBackwardLabel,
                  );

                  final forwardButton = _buttonTabBuilder(
                    context,
                    const Icon(FluentIcons.caret_right_solid8, size: 10),
                    !scrollController.canForward
                        ? () {
                            if (direction == TextDirection.ltr) {
                              scrollController.forward();
                            } else {
                              scrollController.backward();
                            }
                          }
                        : null,
                    localizations.scrollTabForwardLabel,
                  );

                  return Row(children: [
                    if (showScrollButtons)
                      direction == TextDirection.ltr
                          ? backwardButton
                          : forwardButton,
                    if (scrollable)
                      Expanded(child: listView)
                    else
                      Flexible(child: listView),
                    if (showScrollButtons)
                      direction == TextDirection.ltr
                          ? forwardButton
                          : backwardButton,
                    if (widget.showNewButton)
                      _buttonTabBuilder(
                        context,
                        Icon(widget.addIconData, size: 16.0),
                        widget.onNewPressed!,
                        localizations.newTabLabel,
                      ),
                  ]);
                }),
              ),
              if (widget.footer != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: DefaultTextStyle(
                    style: headerFooterTextStyle,
                    child: widget.footer!,
                  ),
                ),
            ],
          ),
        ),
      ),
      if (widget.bodies.isNotEmpty)
        Expanded(child: widget.bodies[widget.currentIndex]),
    ]);
    if (widget.shortcutsEnabled) {
      void _onClosePressed() {
        widget.tabs[widget.currentIndex].onClosed?.call();
      }

      return FocusScope(
        autofocus: true,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.f4, control: true):
                _onClosePressed,
            const SingleActivator(LogicalKeyboardKey.keyW, control: true):
                _onClosePressed,
            const SingleActivator(LogicalKeyboardKey.keyT, control: true): () {
              widget.onNewPressed?.call();
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
              value: (index) {
                return () {
                  // If it's the last, move to the last tab
                  if (index == 8) {
                    widget.onChanged?.call(widget.tabs.length - 1);
                  } else {
                    if (widget.tabs.length - 1 >= index) {
                      widget.onChanged?.call(index);
                    }
                  }
                };
              },
            ),
          },
          child: tabBar,
        ),
      );
    }
    return tabBar;
  }
}

class Tab {
  /// Creates a tab.
  const Tab({
    this.key,
    this.icon = const FlutterLogo(),
    required this.text,
    this.closeIcon = FluentIcons.chrome_close,
    this.onClosed,
    this.semanticLabel,
  });

  final Key? key;

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
    this.reorderIndex,
    this.animationDuration = Duration.zero,
    this.animationCurve = Curves.linear,
    required this.visibilityMode,
    required this.tabWidthBehavior,
  }) : super(key: key);

  final Tab tab;
  final bool selected;
  final VoidCallback? onPressed;
  final int? reorderIndex;
  final Duration animationDuration;
  final Curve animationCurve;
  final CloseButtonVisibilityMode visibilityMode;
  final TabWidthBehavior tabWidthBehavior;

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
    final localizations = FluentLocalizations.of(context);

    // The text of the tab, if a [Text] widget is used
    final String? text = () {
      if (widget.tab.text is Text) {
        return (widget.tab.text as Text).data ??
            (widget.tab.text as Text).textSpan?.toPlainText();
      }
    }();
    return HoverButton(
      key: widget.tab.key,
      semanticLabel: widget.tab.semanticLabel ?? text,
      onPressed: widget.onPressed,
      builder: (context, states) {
        final primaryBorder = FluentTheme.of(context).focusTheme.primaryBorder;
        Widget child = Container(
          height: _kTileHeight,
          constraints: widget.tabWidthBehavior == TabWidthBehavior.sizeToContent
              ? null
              : const BoxConstraints(maxWidth: _kMaxTileWidth),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(
            /// Using a [FocusBorder] here would be more adequate, but it
            /// seems it disabled the reordering effect. Using this boder
            /// have the same effect, but make sure to update the code here
            /// whenever [FocusBorder] code is altered
            border: Border.all(
              style: states.isFocused ? BorderStyle.solid : BorderStyle.none,
              color: primaryBorder?.color ?? Colors.transparent,
              width: primaryBorder?.width ?? 0.0,
            ),
            borderRadius: states.isFocused
                ? BorderRadius.zero
                : const BorderRadius.vertical(top: Radius.circular(4)),
            color: widget.selected
                ? null
                : ButtonThemeData.uncheckedInputColor(theme, states),
          ),
          child: () {
            final result = ClipRect(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.tab.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget.tab.icon!,
                    ),
                  if (widget.tabWidthBehavior != TabWidthBehavior.compact ||
                      (widget.tabWidthBehavior == TabWidthBehavior.compact &&
                          widget.selected))
                    Flexible(
                      fit: widget.tabWidthBehavior == TabWidthBehavior.equal
                          ? FlexFit.tight
                          : FlexFit.loose,
                      child: DefaultTextStyle(
                        style: (theme.typography.body ?? const TextStyle())
                            .copyWith(
                          fontSize: 12.0,
                          fontWeight: widget.selected ? FontWeight.w600 : null,
                        ),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        child: widget.tab.text,
                      ),
                    ),
                  if (widget.tab.closeIcon != null &&
                      (widget.visibilityMode ==
                              CloseButtonVisibilityMode.always ||
                          (widget.visibilityMode ==
                                  CloseButtonVisibilityMode.onHover &&
                              states.isHovering)))
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: FocusTheme(
                        data: const FocusThemeData(
                          primaryBorder: BorderSide.none,
                          secondaryBorder: BorderSide.none,
                        ),
                        child: Tooltip(
                          message: localizations.closeTabLabel,
                          child: IconButton(
                            icon: Icon(widget.tab.closeIcon),
                            onPressed: widget.tab.onClosed,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
            if (widget.reorderIndex != null) {
              return ReorderableDragStartListener(
                index: widget.reorderIndex!,
                child: result,
              );
            }
            return result;
          }(),
        );
        if (text != null) {
          child = Tooltip(
            message: text,
            style: const TooltipThemeData(preferBelow: true),
            child: child,
          );
        }
        if (widget.selected) {
          child = CustomPaint(
            willChange: false,
            painter: _TabPainter(theme.brightness.isDark
                ? const Color(0xFF282828)
                : const Color(0xFFf9f9f9)),
            child: child,
          );
        }
        return Semantics(
          selected: widget.selected,
          focusable: true,
          focused: states.isFocused,
          child: SmallIconButton(child: child),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _TabPainter extends CustomPainter {
  final Color color;

  const _TabPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const radius = 6.0;
    path
      ..moveTo(-radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width + radius,
        size.height,
      );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TabPainter oldDelegate) => color != oldDelegate.color;

  @override
  bool shouldRebuildSemantics(_TabPainter oldDelegate) => false;
}

class _TabViewScrollBehavior extends ScrollBehavior {
  const _TabViewScrollBehavior();

  @override
  Widget buildScrollbar(context, child, details) {
    return child;
  }
}
