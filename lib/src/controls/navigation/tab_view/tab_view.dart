import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

part 'tab.dart';

const double _kMinTileWidth = 80;
const double _kMaxTileWidth = 240;
const double _kTileHeight = 34;
const double _kButtonWidth = 32;

/// A tabbed interface for displaying multiple pages of content.
///
/// [TabView] provides a familiar tab-based navigation pattern, similar to
/// browser tabs. Users can switch between tabs, and optionally rearrange,
/// open, or close tabs.
///
/// ## Managing tabs
///
/// Use either [tabs] and [currentIndex], or a [controller], but not both. A
/// [TabViewController] owns its tabs and selection, and notifies this widget
/// when they change. Create it once in a [State.initState] method and dispose
/// it in [State.dispose]. Without a controller, the parent owns the tab list
/// and selection: [onChanged], [onNewPressed], [Tab.onClosed], and [onReorder]
/// request changes, and the parent must rebuild this widget with the result.
///
/// A close action only invokes the selected [Tab.onClosed] callback; it never
/// removes the tab automatically. The callback must remove the tab from the
/// controller or parent-managed list. A tab without [Tab.onClosed] cannot be
/// closed.
///
/// Give tabs stable, unique keys when their order or membership can change.
/// Keys preserve a tab body's state when tabs are recreated or reordered.
/// Unkeyed tabs can retain state when the same [Tab] instances are reused, but
/// reordering newly created, otherwise indistinguishable unkeyed tabs is
/// ambiguous and state can follow their previous positions instead.
///
/// ![TabView Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/tabview/tab-introduction.png)
///
/// {@tool snippet}
/// This short controller lifecycle example adds and closes tabs:
///
/// ```dart
/// class _TabViewExampleState extends State<TabViewExample> {
///   late final TabViewController controller;
///   var nextDocument = 2;
///
///   @override
///   void initState() {
///     super.initState();
///     controller = TabViewController(tabs: [_tab('Document 1')]);
///   }
///
///   Tab _tab(String title) {
///     final key = ValueKey(title);
///     return Tab(
///       key: key,
///       text: Text(title),
///       body: Center(child: Text(title)),
///       onClosed: () => controller.removeAt(
///         controller.tabs.indexWhere((tab) => tab.key == key),
///       ),
///     );
///   }
///
///   @override
///   void dispose() {
///     controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) => TabView(
///     controller: controller,
///     onNewPressed: () => controller.add(_tab('Document ${nextDocument++}')),
///   );
/// }
/// ```
/// {@end-tool}
///
/// ## Keyboard shortcuts
///
/// When [shortcutsEnabled] is true, the following shortcuts are available:
///
/// * `Ctrl + T` - Create a new tab (if [onNewPressed] is provided)
/// * `Ctrl + W` or `Ctrl + F4` - Close the current tab
/// * `Ctrl + 1-8` - Navigate to tabs 1-8
/// * `Ctrl + 9` - Navigate to the last tab
///
/// See also:
///
///  * [NavigationView], for top-level app navigation
///  * [Tab], the individual tab widget
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/tab-view>
class TabView extends StatefulWidget {
  /// Creates a tab view.
  ///
  /// [maxTabWidth] must be non-negative
  const TabView({
    List<Tab>? tabs,
    int? currentIndex,
    super.key,
    this.controller,
    this.onChanged,
    this.onNewPressed,
    this.newTabIcon = const WindowsIcon(
      WindowsIcons.add,
      fallbackIcon: FluentIcons.add,
    ),
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
  }) : tabs = tabs ?? const [],
       currentIndex = currentIndex ?? 0,
       assert(
         controller != null || tabs != null,
         'tabs must be provided when controller is null.',
       ),
       assert(
         controller == null || tabs == null,
         'Tabs must be managed by either tabs or controller, not both.',
       ),
       assert(
         controller == null || currentIndex == null,
         'currentIndex must not be provided when controller is used.',
       );

  /// The index of the tab to display when [controller] is null.
  ///
  /// Defaults to `0`. When [controller] is provided, its
  /// [TabViewController.selectedIndex] takes precedence.
  final int currentIndex;

  /// Controls the selected tab.
  ///
  /// When non-null, changing [TabViewController.selectedIndex] updates the
  /// displayed tab. User selection updates the controller before [onChanged]
  /// is called.
  final TabViewController? controller;

  /// Called when the user selects a tab.
  ///
  /// When [controller] is provided, it has already been updated with the
  /// selected index when this callback is invoked. Without a controller, use
  /// this callback to rebuild [TabView] with the new [currentIndex].
  final ValueChanged<int>? onChanged;

  /// The tabs to display when [controller] is null.
  ///
  /// This must be omitted when [controller] is provided.
  final List<Tab> tabs;

  /// Called when the user requests a new tab by pressing the new-tab button or
  /// using the `Ctrl + T` shortcut.
  ///
  /// This callback does not add a tab automatically. Add one to [controller],
  /// or update the parent-managed [tabs] list and rebuild the [TabView]. If
  /// null, the new-tab button is not displayed and `Ctrl + T` has no effect.
  final VoidCallback? onNewPressed;

  /// The icon of the "Add new tab" button.
  ///
  /// Defaults to a [WindowsIcon] with [WindowsIcons.add].
  final Widget newTabIcon;

  /// Whether the following shortcuts are enabled:
  ///
  ///   * `Ctrl + T` to create a new tab
  ///   * `Ctrl + F4` or `Ctrl + W` to close the current tab
  ///   * `Ctrl + 1` to ` Ctrl + 8` to navigate through tabs
  ///   * `Ctrl + 9` to navigate to the last tab
  ///
  /// Defaults to `true`.
  final bool shortcutsEnabled;

  /// Called when the user requests that a tab move from `oldIndex` to
  /// `newIndex`.
  ///
  /// With a [controller], it has already moved the tab before this callback is
  /// invoked; use the callback for observation and do not move it again.
  /// Without a controller, move the item in the parent-managed [tabs] list and
  /// rebuild the [TabView]. If null, reordering is disabled unless a
  /// [controller] is provided.
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

  /// The [ScrollPosController] used to move TabView to right and left when the
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
  /// Defaults to one second.
  final Duration closeDelayDuration;

  /// Whenever the new button should be displayed.
  bool get showNewButton => onNewPressed != null;

  /// Whether reordering is enabled or not.
  ///
  /// To enable it, ensure [onReorder] is not null.
  bool get isReorderEnabled => controller != null || onReorder != null;

  List<Tab> get _effectiveTabs => controller?.tabs ?? tabs;

  int get _effectiveCurrentIndex => controller?.selectedIndex ?? currentIndex;

  @override
  State<StatefulWidget> createState() => _TabViewState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('currentIndex', _effectiveCurrentIndex))
      ..add(DiagnosticsProperty('controller', controller))
      ..add(
        FlagProperty(
          'showNewButton',
          value: showNewButton,
          ifFalse: 'no new button',
        ),
      )
      ..add(
        DiagnosticsProperty<Widget>(
          'newTabIcon',
          newTabIcon,
          defaultValue: const WindowsIcon(
            WindowsIcons.add,
            fallbackIcon: FluentIcons.add,
          ),
        ),
      )
      ..add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'))
      ..add(
        ObjectFlagProperty(
          'onNewPressed',
          onNewPressed,
          ifNull: 'no new button',
        ),
      )
      ..add(IntProperty('tabs', _effectiveTabs.length))
      ..add(
        FlagProperty(
          'reorderEnabled',
          value: isReorderEnabled,
          ifFalse: 'reorder disabled',
        ),
      )
      ..add(
        FlagProperty(
          'showScrollButtons',
          value: showScrollButtons,
          ifFalse: 'hide scroll buttons',
        ),
      )
      ..add(
        EnumProperty(
          'closeButtonVisibility',
          closeButtonVisibility,
          defaultValue: CloseButtonVisibilityMode.always,
        ),
      )
      ..add(
        EnumProperty(
          'tabWidthBehavior',
          tabWidthBehavior,
          defaultValue: TabWidthBehavior.equal,
        ),
      )
      ..add(
        DiagnosticsProperty<Duration>(
          'closeDelayDuration',
          closeDelayDuration,
          defaultValue: const Duration(seconds: 1),
        ),
      )
      ..add(DoubleProperty('minTabWidth', minTabWidth, defaultValue: 80.0))
      ..add(DoubleProperty('maxTabWidth', maxTabWidth, defaultValue: 240.0))
      ..add(DoubleProperty('reservedStripWidth', reservedStripWidth));
  }
}

class _TabViewState extends State<TabView> {
  Timer? closeTimer;
  double? lockedTabWidth;
  double preferredTabWidth = 0;

  late ScrollPosController scrollController;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleControllerChanged);
    scrollController = widget.scrollController ?? _createScrollController();
    _syncScrollControllerItemCount();
  }

  @override
  void didUpdateWidget(TabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }
    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) scrollController.dispose();
      scrollController = widget.scrollController ?? _createScrollController();
      scrollController.animationDuration = FluentTheme.of(
        context,
      ).fastAnimationDuration;
    }
    _syncScrollControllerItemCount();
    if (widget._effectiveCurrentIndex != oldWidget._effectiveCurrentIndex) {
      _scrollToCurrentIndex();
    }
  }

  ScrollPosController _createScrollController() {
    return ScrollPosController(
      itemCount: widget._effectiveTabs.length,
      animationDuration: const Duration(milliseconds: 100),
    );
  }

  void _syncScrollControllerItemCount() {
    if (scrollController.itemCount != widget._effectiveTabs.length) {
      scrollController.itemCount = widget._effectiveTabs.length;
    }
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    _syncScrollControllerItemCount();
    _scrollToCurrentIndex();
    setState(() {});
  }

  void _scrollToCurrentIndex() {
    if (scrollController.hasClients && widget._effectiveTabs.isNotEmpty) {
      scrollController.scrollToItem(widget._effectiveCurrentIndex);
    }
  }

  void _select(int index) {
    widget.controller?.select(index);
    widget.onChanged?.call(index);
  }

  void _reorder(int oldIndex, int newIndex) {
    widget.controller?.move(oldIndex, newIndex);
    widget.onReorder?.call(oldIndex, newIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = FluentTheme.of(context);
    scrollController.animationDuration = theme.fastAnimationDuration;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        FlagProperty(
          'isClosePending',
          value: closeTimer?.isActive ?? false,
          ifTrue: 'close pending',
        ),
      )
      ..add(DoubleProperty('lockedTabWidth', lockedTabWidth))
      ..add(DoubleProperty('preferredTabWidth', preferredTabWidth))
      ..add(DiagnosticsProperty('scrollController', scrollController));
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    if (widget.scrollController == null) {
      // only dispose the local controller
      scrollController.dispose();
    }
    closeTimer?.cancel();
    super.dispose();
  }

  void close(int index) {
    final tab = widget._effectiveTabs[index];
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
      widget._effectiveTabs[index].onClosed!();

      closeTimer?.cancel();

      var tabWidth = preferredTabWidth;

      final tabBox =
          tab._tabKey.currentContext?.findRenderObject() as RenderBox?;
      if (tabBox != null && tabBox.hasSize) {
        tabWidth = tabBox.size.width;

        // consider the divider thickness when calculating the tab width
        final thickness = DividerTheme.of(context).thickness ?? 0;
        tabWidth +=
            (thickness * (widget._effectiveTabs.length - 1)) - thickness * 2;
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
    final tab = widget._effectiveTabs[index];
    final tabWidget = TabData(
      key: ValueKey<int>(index),
      reorderIndex: widget.isReorderEnabled ? index : null,
      selected: index == widget._effectiveCurrentIndex,
      onPressed: widget.controller == null && widget.onChanged == null
          ? null
          : () => _select(index),
      onClose: widget._effectiveTabs[index].onClosed == null
          ? null
          : () => close(index),
      animationDuration: FluentTheme.of(context).fastAnimationDuration,
      animationCurve: FluentTheme.of(context).animationCurve,
      visibilityMode: widget.closeButtonVisibility,
      tabWidthBehavior: widget.tabWidthBehavior,
      child: tab,
    );
    final Widget child = GestureDetector(
      onTertiaryTapUp: (_) => close(index),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: widget.tabWidthBehavior == TabWidthBehavior.equal
                ? FlexFit.tight
                : FlexFit.loose,
            child: tabWidget,
          ),
          divider(index),
        ],
      ),
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
      return KeyedSubtree(key: ValueKey<Tab>(tab), child: child);
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
      height: 28,
      child: IconButton(
        icon: Center(child: icon),
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.isDisabled) {
              return FluentTheme.of(
                context,
              ).resources.accentTextFillColorDisabled;
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
          padding: const WidgetStatePropertyAll(EdgeInsetsDirectional.zero),
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
          verticalMargin: const EdgeInsetsDirectional.symmetric(vertical: 8),
          decoration:
              ![
                widget._effectiveCurrentIndex - 1,
                widget._effectiveCurrentIndex,
              ].contains(index)
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

    final Widget tabBar = Column(
      children: [
        ScrollConfiguration(
          behavior: const _TabViewScrollBehavior(),
          child: Container(
            margin: const EdgeInsetsDirectional.only(top: 4.5),
            padding: const EdgeInsetsDirectional.only(start: 8),
            height: _kTileHeight,
            width: double.infinity,
            child: Row(
              children: [
                if (widget.header != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: DefaultTextStyle.merge(
                      style: headerFooterTextStyle,
                      child: widget.header!,
                    ),
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, consts) {
                      final width = consts.biggest.width;
                      assert(
                        width.isFinite,
                        'You can only create a TabView in a box with defined width',
                      );

                      preferredTabWidth = widget._effectiveTabs.isEmpty
                          ? 0
                          : clampDouble(
                              (width -
                                      (widget.showNewButton
                                          ? _kButtonWidth
                                          : 0) -
                                      (widget.reservedStripWidth ?? 0)) /
                                  widget._effectiveTabs.length,
                              widget.minTabWidth,
                              widget.maxTabWidth,
                            );

                      final Widget listView = Listener(
                        onPointerSignal: (e) {
                          if (e is PointerScrollEvent &&
                              scrollController.hasClients) {
                            GestureBinding.instance.pointerSignalResolver
                                .register(e, (event) {
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
                        child: ReorderableList(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          controller: scrollController,
                          onReorderItem: _reorder,
                          itemCount: widget._effectiveTabs.length,
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
                          dragStartBehavior: DragStartBehavior.down,
                        ),
                      );

                      /// Whether the tab bar is scrollable
                      final scrollable =
                          preferredTabWidth * widget._effectiveTabs.length >
                          width - (widget.showNewButton ? _kButtonWidth : 0);

                      final showScrollButtons =
                          widget.showScrollButtons &&
                          scrollable &&
                          scrollController.hasClients;

                      Widget backwardButton() {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 8,
                            end: 3,
                            bottom: 3,
                          ),
                          child: _buttonTabBuilder(
                            context,
                            const WindowsIcon(
                              WindowsIcons.caret_left_solid8,
                              fallbackIcon: FluentIcons.caret_left_solid8,
                              size: 8,
                            ),
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
                            start: 3,
                            end: 8,
                            bottom: 3,
                          ),
                          child: _buttonTabBuilder(
                            context,
                            const WindowsIcon(
                              WindowsIcons.caret_right_solid8,
                              fallbackIcon: FluentIcons.caret_right_solid8,
                              size: 8,
                            ),
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

                      final strip = Row(
                        children: [
                          // scroll buttons if needed
                          if (showScrollButtons)
                            if (direction == TextDirection.ltr)
                              backwardButton()
                            else
                              forwardButton(),
                          // tabs area (flexible/expanded)
                          if (scrollable)
                            Expanded(child: listView)
                          else
                            Flexible(child: listView),
                          // scroll buttons if needed
                          if (showScrollButtons)
                            if (direction == TextDirection.ltr)
                              forwardButton()
                            else
                              backwardButton(),
                          // new tab button
                          if (widget.showNewButton)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 3,
                                bottom: 3,
                              ),
                              child: _buttonTabBuilder(
                                context,
                                IconTheme.merge(
                                  data: const IconThemeData(size: 12),
                                  child: widget.newTabIcon,
                                ),
                                widget.onNewPressed,
                                localizations.newTabLabel,
                              ),
                            ),
                          // reserved strip width
                          if (widget.reservedStripWidth != null)
                            SizedBox(width: widget.reservedStripWidth),
                        ],
                      );

                      if (widget.stripBuilder != null) {
                        return widget.stripBuilder!(context, strip);
                      }

                      return strip;
                    },
                  ),
                ),
                if (widget.footer != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 12),
                    child: DefaultTextStyle.merge(
                      style: headerFooterTextStyle,
                      child: widget.footer!,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget._effectiveTabs.isNotEmpty)
          Expanded(
            child: Focus(
              autofocus: true,
              child: _TabBody(
                index: widget._effectiveCurrentIndex,
                tabs: widget._effectiveTabs,
              ),
            ),
          ),
      ],
    );
    if (widget.shortcutsEnabled) {
      void onClosePressed() {
        if (widget._effectiveTabs.isNotEmpty) {
          close(widget._effectiveCurrentIndex);
        }
      }

      // For more info, refer to [SingleActivator] docs
      var ctrl = true;
      var meta = false;
      if (!kIsWeb &&
          [
            TargetPlatform.iOS,
            TargetPlatform.macOS,
          ].contains(defaultTargetPlatform)) {
        ctrl = false;
        meta = true;
      }

      return FocusScope(
        autofocus: true,
        child: CallbackShortcuts(
          bindings: {
            SingleActivator(LogicalKeyboardKey.f4, control: ctrl, meta: meta):
                onClosePressed,
            SingleActivator(LogicalKeyboardKey.keyW, control: ctrl, meta: meta):
                onClosePressed,
            SingleActivator(
              LogicalKeyboardKey.keyT,
              control: ctrl,
              meta: meta,
            ): () =>
                widget.onNewPressed?.call(),
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
                return SingleActivator(
                  digits[i as int],
                  control: ctrl,
                  meta: meta,
                );
              },
              value: (i) {
                final index = i as int;
                return () {
                  // If it's the last, move to the last tab
                  if (widget._effectiveTabs.isEmpty) return;
                  if (index == 8) {
                    _select(widget._effectiveTabs.length - 1);
                  } else if (widget._effectiveTabs.length - 1 >= index) {
                    _select(index);
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
