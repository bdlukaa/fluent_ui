import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

part 'tab.dart';

const double _kMinTileWidth = 80.0;
const double _kMaxTileWidth = 240.0;
const double _kTileHeight = 34.0;
const double _kButtonWidth = 32.0;

/// The TabView control is a way to display a set of tabs and their respective
/// content. TabViews are useful for displaying several pages (or documents) of
/// content while giving a user the capability to rearrange, open, or close new
/// tabs.
///
/// ![TabView Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/tabview/tab-introduction.png)
///
/// There must be enough space to render the tabview.
///
/// See also:
///
///   * [NavigationView], control provides top-level navigation for your app.
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/tab-view>
class TabView extends StatefulWidget {
  /// Creates a tab view.
  ///
  /// [tabs] must have the same length as [bodies]
  ///
  /// [maxTabWidth] must be non-negative
  const TabView({
    super.key,
    required this.currentIndex,
    this.onChanged,
    required this.tabs,
    this.onNewPressed,
    this.addIconData,
    this.newTabIcon = const Icon(FluentIcons.add),
    this.addIconBuilder,
    this.shortcutsEnabled = true,
    this.onReorder,
    this.showScrollButtons = true,
    this.scrollController,
    this.minTabWidth = _kMinTileWidth,
    this.maxTabWidth = _kMaxTileWidth,
    this.closeButtonVisibility = CloseButtonVisibilityMode.always,
    this.tabWidthBehavior = TabWidthBehavior.equal,
    this.header,
    this.footer,
    this.reservedStripWidth,
    this.stripBuilder,
    this.closeDelayDuration = const Duration(seconds: 1),
  });

  /// The index of the tab to be displayed
  final int currentIndex;

  /// Whether another tab was requested to be displayed
  final ValueChanged<int>? onChanged;

  /// The tabs to be displayed.
  final List<Tab> tabs;

  /// Called when the new button is pressed or when the
  /// shortcut `Ctrl + T` is executed.
  ///
  /// If null, the new button won't be displayed
  final VoidCallback? onNewPressed;

  /// The icon of the new button
  @Deprecated(
    'Use newTabIcon instead. This was deprecated on 4.9.0 and will be removed in the next releases.',
  )
  final IconData? addIconData;

  /// The icon of the "Add new tab" button.
  ///
  /// Defaults to an [Icon] with [FluentIcons.add].
  final Icon newTabIcon;

  /// The builder for the add icon.
  ///
  /// This does not build the add button, only its icon.
  ///
  /// When null, the add icon is rendered.
  @Deprecated(
    'Use newTabIcon instead. This was deprecated on 4.9.0 and will be removed in the next releases.',
  )
  final Widget Function(Widget addIcon)? addIconBuilder;

  /// Whether the following shortcuts are enabled:
  ///
  ///   * `Ctrl + T` to create a new tab
  ///   * `Ctrl + F4` or `Ctrl + W` to close the current tab
  ///   * `Ctrl + 1` to ` Ctrl + 8` to navigate through tabs
  ///   * `Ctrl + 9` to navigate to the last tab
  ///
  /// Defaults to `true`.
  final bool shortcutsEnabled;

  /// Called when the tabs are reordered.
  ///
  /// If null, reordering is disabled. It's disabled by default.
  final ReorderCallback? onReorder;

  /// The min width a tab can have. Must not be negative.
  ///
  /// Defaults to 80 logical pixels.
  final double minTabWidth;

  /// The max width a tab can have. Must not be negative.
  ///
  /// Defaults to 240 logical pixels.
  final double maxTabWidth;

  /// Whether the buttons that scroll forward or backward
  /// should be displayed, if necessary.
  ///
  /// Defaults to `true`.
  final bool showScrollButtons;

  /// The [ScrollPosController] used to move tabview to right and left when the
  /// tabs don't fit the available horizontal space.
  ///
  /// If null, a [ScrollPosController] is created internally.
  final ScrollPosController? scrollController;

  /// Indicates the close button visibility mode.
  ///
  /// Defaults to [CloseButtonVisibilityMode.always].
  final CloseButtonVisibilityMode closeButtonVisibility;

  /// Indicates how a tab will size itself.
  ///
  /// Defaults to [TabWidthBehavior.equal].
  final TabWidthBehavior tabWidthBehavior;

  /// Displayed before all the tabs and buttons.
  ///
  /// Usually a [Text].
  final Widget? header;

  /// Displayed after all the tabs and buttons.
  ///
  /// Usually a [Text] widget.
  final Widget? footer;

  /// The minimum width reserved at the end of the tab strip.
  ///
  /// This reserved space ensures a consistent drag area for window manipulation
  /// (e.g., dragging, resizing) even when many tabs are present. This is particularly
  /// crucial when `TabView` is used in a title bar.
  ///
  /// When using TabView in a title bar, this space ensures minimum drag area even
  /// when many tabs are present. This is critical for window manipulation (dragging, etc)
  /// as it guarantees a consistent drag target regardless of tab count.
  ///
  /// If `null`, no reserved width is enforced.
  final double? reservedStripWidth;

  /// The builder for the strip that contains the tabs.
  final Widget Function(BuildContext context, Widget strip)? stripBuilder;

  /// The delay duration to animate the tab after it's closed. Only applied when
  /// [tabWidthBehavior] is [TabWidthBehavior.equal].
  ///
  /// Defaults to 400 milliseconds.
  final Duration closeDelayDuration;

  /// Whenever the new button should be displayed.
  bool get showNewButton => onNewPressed != null;

  /// Whether reordering is enabled or not.
  ///
  /// To enable it, ensure [onReorder] is not null.
  bool get isReorderEnabled => onReorder != null;

  @override
  State<StatefulWidget> createState() => _TabViewState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('currentIndex', currentIndex))
      ..add(FlagProperty(
        'showNewButton',
        value: showNewButton,
        ifFalse: 'no new button',
      ))
      // ignore: deprecated_member_use_from_same_package
      ..add(IconDataProperty('addIconData', addIconData))
      ..add(DiagnosticsProperty<Widget>(
        'newTabIcon',
        newTabIcon,
        defaultValue: const Icon(FluentIcons.add),
      ))
      ..add(ObjectFlagProperty(
        'onChanged',
        onChanged,
        ifNull: 'disabled',
      ))
      ..add(ObjectFlagProperty(
        'onNewPressed',
        onNewPressed,
        ifNull: 'no new button',
      ))
      ..add(IntProperty('tabs', tabs.length))
      ..add(FlagProperty(
        'reorderEnabled',
        value: isReorderEnabled,
        ifFalse: 'reorder disabled',
      ))
      ..add(FlagProperty(
        'showScrollButtons',
        value: showScrollButtons,
        ifFalse: 'hide scroll buttons',
      ))
      ..add(EnumProperty(
        'closeButtonVisibility',
        closeButtonVisibility,
        defaultValue: CloseButtonVisibilityMode.always,
      ))
      ..add(EnumProperty(
        'tabWidthBehavior',
        tabWidthBehavior,
        defaultValue: TabWidthBehavior.equal,
      ))
      ..add(DiagnosticsProperty<Duration>(
        'closeDelayDuration',
        closeDelayDuration,
        defaultValue: const Duration(seconds: 1),
      ))
      ..add(DoubleProperty('minTabWidth', minTabWidth, defaultValue: 80.0))
      ..add(DoubleProperty('maxTabWidth', maxTabWidth, defaultValue: 240.0))
      ..add(DoubleProperty('minFooterWidth', reservedStripWidth));
  }
}

class _TabViewState extends State<TabView> {
  Timer? closeTimer;
  double? lockedTabWidth;
  double preferredTabWidth = 0.0;

  late ScrollPosController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController ??
        ScrollPosController(
          itemCount: widget.tabs.length,
          animationDuration: const Duration(milliseconds: 100),
        );
    scrollController
      ..itemCount = widget.tabs.length
      ..addListener(_handleScrollUpdate);
  }

  void _handleScrollUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(TabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != scrollController.itemCount) {
      scrollController.itemCount = widget.tabs.length;
    }
    if (widget.currentIndex != oldWidget.currentIndex &&
        scrollController.hasClients) {
      scrollController.scrollToItem(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      // only dispose the local controller
      scrollController.dispose();
    }
    closeTimer?.cancel();
    super.dispose();
  }

  void close(int index) {
    final tab = widget.tabs[index];
    final closable = tab.onClosed != null;

    void createTimer() {
      closeTimer = Timer(widget.closeDelayDuration, () {
        closeTimer!.cancel();
        closeTimer = null;
        lockedTabWidth = null;

        if (mounted) setState(() {});
      });
    }

    if (closable) {
      widget.tabs[index].onClosed!();

      closeTimer?.cancel();

      var tabWidth = preferredTabWidth;

      final tabBox =
          tab._tabKey.currentContext?.findRenderObject() as RenderBox?;
      if (tabBox != null && tabBox.hasSize) {
        tabWidth = tabBox.size.width;

        // consider the divider thickness when calculating the tab width
        final thickness = DividerTheme.of(context).thickness ?? 0;
        tabWidth += (thickness * (widget.tabs.length - 1)) - thickness * 2;
      }

      setState(() => lockedTabWidth = tabWidth);
      createTimer();
    }
  }

  Widget _tabBuilder(
    BuildContext context,
    int index,
    double preferredTabWidth,
  ) {
    final tab = widget.tabs[index];
    final tabWidget = TabData(
      key: ValueKey<int>(index),
      reorderIndex: widget.isReorderEnabled ? index : null,
      selected: index == widget.currentIndex,
      onPressed:
          widget.onChanged == null ? null : () => widget.onChanged!(index),
      onClose: widget.tabs[index].onClosed == null ? null : () => close(index),
      animationDuration: FluentTheme.of(context).fastAnimationDuration,
      animationCurve: FluentTheme.of(context).animationCurve,
      visibilityMode: widget.closeButtonVisibility,
      tabWidthBehavior: widget.tabWidthBehavior,
      child: tab,
    );
    final Widget child = GestureDetector(
      onTertiaryTapUp: (_) => close(index),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          fit: widget.tabWidthBehavior == TabWidthBehavior.equal
              ? FlexFit.tight
              : FlexFit.loose,
          child: tabWidget,
        ),
        divider(index),
      ]),
    );
    final minWidth = () {
      switch (widget.tabWidthBehavior) {
        case TabWidthBehavior.sizeToContent:
        case TabWidthBehavior.compact:
          return null;
        default:
          return lockedTabWidth ?? preferredTabWidth;
      }
    }();
    if (minWidth == null) {
      return KeyedSubtree(
        key: ValueKey<Tab>(tab),
        child: child,
      );
    }
    return AnimatedContainer(
      key: ValueKey<Tab>(tab),
      constraints: BoxConstraints(maxWidth: minWidth, minWidth: minWidth),
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
      height: 28.0,
      child: IconButton(
        icon: Center(child: icon),
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.isDisabled) {
              return FluentTheme.of(context)
                  .resources
                  .accentTextFillColorDisabled;
            } else {
              return FluentTheme.of(context).inactiveColor;
            }
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.isDisabled || states.isNone) return Colors.transparent;
            return ButtonThemeData.uncheckedInputColor(
              FluentTheme.of(context),
              states,
            );
          }),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
    );
    if (onPressed == null) return item;
    return Tooltip(message: tooltip, child: item);
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

    final direction = Directionality.of(context);
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    final headerFooterTextStyle =
        theme.typography.bodyLarge ?? const TextStyle();

    Widget tabBar = Column(children: [
      ScrollConfiguration(
        behavior: const _TabViewScrollBehavior(),
        child: Container(
          margin: const EdgeInsetsDirectional.only(top: 4.5),
          padding: const EdgeInsetsDirectional.only(start: 8),
          height: _kTileHeight,
          width: double.infinity,
          child: Row(children: [
            if (widget.header != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: DefaultTextStyle.merge(
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

                preferredTabWidth = ((width -
                            (widget.showNewButton ? _kButtonWidth : 0) -
                            (widget.reservedStripWidth ?? 0)) /
                        widget.tabs.length)
                    .clamp(widget.minTabWidth, widget.maxTabWidth);

                final Widget listView = Listener(
                  onPointerSignal: (PointerSignalEvent e) {
                    if (e is PointerScrollEvent &&
                        scrollController.hasClients) {
                      GestureBinding.instance.pointerSignalResolver.register(e,
                          (PointerSignalEvent event) {
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
                      });
                    }
                  },
                  child: Localizations.override(
                    context: context,
                    delegates: const [
                      GlobalMaterialLocalizations.delegate,
                    ],
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
                        return _tabBuilder(context, index, preferredTabWidth);
                      },
                      dragStartBehavior: DragStartBehavior.down,
                    ),
                  ),
                );

                /// Whether the tab bar is scrollable
                var scrollable = preferredTabWidth * widget.tabs.length >
                    width - (widget.showNewButton ? _kButtonWidth : 0);

                final showScrollButtons = widget.showScrollButtons &&
                    scrollable &&
                    scrollController.hasClients;

                Widget backwardButton() {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 8.0,
                      end: 3.0,
                      bottom: 3.0,
                    ),
                    child: _buttonTabBuilder(
                      context,
                      const Icon(FluentIcons.caret_left_solid8, size: 8),
                      scrollController.canBackward
                          ? () {
                              if (direction == TextDirection.ltr) {
                                scrollController.backward(align: false);
                              } else {
                                scrollController.forward(align: false);
                              }
                            }
                          : null,
                      localizations.scrollTabBackwardLabel,
                    ),
                  );
                }

                Widget forwardButton() {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 3.0,
                      end: 8.0,
                      bottom: 3.0,
                    ),
                    child: _buttonTabBuilder(
                      context,
                      const Icon(FluentIcons.caret_right_solid8, size: 8),
                      scrollController.canForward
                          ? () {
                              if (direction == TextDirection.ltr) {
                                scrollController.forward(align: false);
                              } else {
                                scrollController.backward(align: false);
                              }
                            }
                          : null,
                      localizations.scrollTabForwardLabel,
                    ),
                  );
                }

                final strip = Row(children: [
                  // scroll buttons if needed
                  if (showScrollButtons)
                    direction == TextDirection.ltr
                        ? backwardButton()
                        : forwardButton(),
                  // tabs area (flexible/expanded)
                  if (scrollable)
                    Expanded(child: listView)
                  else
                    Flexible(child: listView),
                  // scroll buttons if needed
                  if (showScrollButtons)
                    direction == TextDirection.ltr
                        ? forwardButton()
                        : backwardButton(),
                  // new tab button
                  if (widget.showNewButton)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 3.0,
                        bottom: 3.0,
                      ),
                      child: _buttonTabBuilder(
                        context,
                        () {
                          Widget icon;
                          // ignore: deprecated_member_use_from_same_package
                          if (widget.addIconData != null) {
                            // ignore: deprecated_member_use_from_same_package
                            icon = Icon(widget.addIconData, size: 12.0);
                          } else {
                            icon = widget.newTabIcon;
                          }
                          icon = IconTheme.merge(
                            data: const IconThemeData(size: 12.0),
                            child: icon,
                          );

                          // ignore: deprecated_member_use_from_same_package
                          return widget.addIconBuilder?.call(icon) ?? icon;
                        }(),
                        widget.onNewPressed!,
                        localizations.newTabLabel,
                      ),
                    ),
                  // reserved strip width
                  if (widget.reservedStripWidth != null)
                    SizedBox(width: widget.reservedStripWidth),
                ]);

                if (widget.stripBuilder != null) {
                  return widget.stripBuilder!(context, strip);
                }

                return strip;
              }),
            ),
            if (widget.footer != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12.0),
                child: DefaultTextStyle.merge(
                  style: headerFooterTextStyle,
                  child: widget.footer!,
                ),
              ),
          ]),
        ),
      ),
      if (widget.tabs.isNotEmpty)
        Expanded(
          child: Focus(
            autofocus: true,
            child: _TabBody(
              index: widget.currentIndex,
              tabs: widget.tabs,
            ),
          ),
        ),
    ]);
    if (widget.shortcutsEnabled) {
      void onClosePressed() {
        close(widget.currentIndex);
      }

      // For more info, refer to [SingleActivator] docs
      var ctrl = true;
      var meta = false;
      if (!kIsWeb &&
          [TargetPlatform.iOS, TargetPlatform.macOS]
              .contains(defaultTargetPlatform)) {
        ctrl = false;
        meta = true;
      }

      return FocusScope(
        autofocus: true,
        child: CallbackShortcuts(
          bindings: {
            SingleActivator(
              LogicalKeyboardKey.f4,
              control: ctrl,
              meta: meta,
            ): onClosePressed,
            SingleActivator(
              LogicalKeyboardKey.keyW,
              control: ctrl,
              meta: meta,
            ): onClosePressed,
            SingleActivator(
              LogicalKeyboardKey.keyT,
              control: ctrl,
              meta: meta,
            ): () => widget.onNewPressed?.call(),
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
                return SingleActivator(digits[i], control: ctrl, meta: meta);
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
