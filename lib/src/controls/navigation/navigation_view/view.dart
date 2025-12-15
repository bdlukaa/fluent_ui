import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

part 'body.dart';
part 'indicators.dart';
part 'pane.dart';
part 'pane_items.dart';
part 'theme.dart';

/// The minimum height of a pane item.
const double kPaneItemMinHeight = 40;

/// The minimum width of a pane item in top display mode.
const double kPaneItemTopMinWidth = 40;

/// The minimum height of a pane item header.
const double kPaneItemHeaderMinHeight = 4;

/// A builder function for customizing the navigation content.
///
/// The [item] is the currently selected pane item, if any.
/// The [body] is the default body widget built from [PaneItem.body].
typedef NavigationContentBuilder =
    Widget Function(PaneItem? item, Widget? body);

/// A navigation control that provides top-level navigation for your app.
///
/// The [NavigationView] adapts to a variety of screen sizes and supports
/// multiple display modes: left, top, compact, and minimal. It automatically
/// switches between these modes based on the available width when using
/// [PaneDisplayMode.auto].
///
/// ![NavigationView Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/nav-view-header.png)
///
/// {@tool snippet}
/// This example shows a basic navigation view with left navigation:
///
/// ```dart
/// int selectedIndex = 0;
///
/// NavigationView(
///   appBar: NavigationAppBar(
///     title: Text('My App'),
///   ),
///   pane: NavigationPane(
///     selected: selectedIndex,
///     onChanged: (index) => setState(() => selectedIndex = index),
///     items: [
///       PaneItem(
///         icon: Icon(FluentIcons.home),
///         title: Text('Home'),
///         body: HomePage(),
///       ),
///       PaneItem(
///         icon: Icon(FluentIcons.settings),
///         title: Text('Settings'),
///         body: SettingsPage(),
///       ),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// ## Display modes
///
/// The navigation pane can be displayed in different modes using [NavigationPane.displayMode]:
///
/// * [PaneDisplayMode.auto] - Automatically adapts based on window width
/// * [PaneDisplayMode.expanded] - Expanded pane with icons and labels
/// * [PaneDisplayMode.compact] - Collapsed pane showing only icons
/// * [PaneDisplayMode.minimal] - Hidden pane with hamburger menu
/// * [PaneDisplayMode.top] - Horizontal navigation at the top
///
/// ## Adaptive behavior
///
/// When using [PaneDisplayMode.auto]:
/// * Width >= 1008px: Open mode (expanded pane)
/// * Width 641-1007px: Compact mode (icons only)
/// * Width <= 640px: Minimal mode (hamburger menu)
///
/// ## Router integration
///
/// For apps using `go_router` or similar routers, use [paneBodyBuilder] to
/// integrate with your routing system:
///
/// {@tool snippet}
/// ```dart
/// NavigationView(
///   pane: NavigationPane(
///     selected: _calculateSelectedIndex(context),
///     items: _buildPaneItems(),
///   ),
///   paneBodyBuilder: (item, body) {
///     // Return your router's body widget
///     return body ?? const SizedBox.shrink();
///   },
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [NavigationPane], the pane configuration for the navigation view
///  * [NavigationAppBar], the app bar displayed at the top
///  * [PaneItem], an item in the navigation pane
///  * [TabView], for tab-based navigation
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/navigationview>
class NavigationView extends StatefulWidget {
  /// Creates a navigation view.
  const NavigationView({
    super.key,
    this.titleBar,
    this.pane,
    this.content,
    this.clipBehavior = Clip.antiAlias,
    this.contentShape,
    this.onOpenSearch,
    this.transitionBuilder,
    this.paneBodyBuilder,
    this.onDisplayModeChanged,
  }) : assert(
         (pane != null && content == null) || (pane == null && content != null),
         'Either pane or content must be provided',
       );

  final Widget? titleBar;

  /// Can be used to override the widget that is built from
  /// the [PaneItem.body]. Only used if [pane] is provided.
  /// If nothing is selected, `body` will be null.
  ///
  /// This can be useful if you are using router-based navigation,
  /// and the body of the navigation pane is dynamically determined or
  /// affected by the current route rather than just by the currently
  /// selected pane.
  ///
  /// If this is not null then this builder will be responsible for state
  /// management of the child widget. One way to accomplish this is to
  /// use an [IndexedStack].
  final NavigationContentBuilder? paneBodyBuilder;

  /// The navigation pane, that can be displayed either on the
  /// left, on the top, or above the body.
  final NavigationPane? pane;

  /// The content of the pane.
  ///
  /// If [pane] is provided, this is ignored
  ///
  /// Usually a [ScaffoldPage]
  final Widget? content;

  /// {@macro flutter.rendering.ClipRectLayer.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// How the body content should be clipped
  ///
  /// The body content is not clipped on when the display mode is [PaneDisplayMode.minimal]
  final ShapeBorder? contentShape;

  /// Called when the search button is tapped.
  ///
  /// This callback is invoked when [NavigationPane.autoSuggestBoxReplacement]
  /// is tapped.
  final VoidCallback? onOpenSearch;

  /// The transition builder.
  ///
  /// It can be detect the display mode of the parent [NavigationView], if any,
  /// and change the transition accordingly. By default, if the display mode is
  /// top, [HorizontalSlidePageTransition] is used, otherwise
  /// [EntrancePageTransition] is used.
  ///
  /// ```dart
  /// transitionBuilder: (child, animation) {
  ///   return DrillInPageTransition(child: child, animation: animation);
  /// },
  /// ```
  ///
  /// See also:
  ///
  ///  * [EntrancePageTransition], used by default
  ///  * [HorizontalSlidePageTransition], used by default on top navigation
  ///  * [DrillInPageTransition], used when users navigate deeper into an app
  ///  * [SuppressPageTransition], to have no animation at all
  ///  * <https://docs.microsoft.com/en-us/windows/apps/design/motion/page-transitions>
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// Called when the display mode changes.
  ///
  /// This is called when the user clicks on the pane toggle button, or when
  /// the display mode is set to [PaneDisplayMode.auto] and the window size
  /// changes.
  ///
  /// If the display mode is set to compact, this listens to changes on the
  /// toggle button and resizes. If the pane is closed, [PaneDisplayMode.compact]
  /// is returned. If the pane is open, [PaneDisplayMode.expanded] is returned.
  ///
  /// If the display mode is set to minimal, this is called when the pane is opened
  /// or closed. If the pane is closed, [PaneDisplayMode.minimal] is returned.
  /// If the pane is open, [PaneDisplayMode.expanded] is returned.
  final ValueChanged<PaneDisplayMode>? onDisplayModeChanged;

  /// Gets the current navigation view state.
  ///
  /// This is the same as using a `GlobalKey<NavigationViewState>`
  static NavigationViewState of(BuildContext context) {
    return maybeOf(context)!;
  }

  /// Gets the closest [NavigationViewState] ancestor, if any.
  ///
  /// Use this when the state might not exist in the widget tree.
  static NavigationViewState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<NavigationViewState>();
  }

  /// Get useful info about the current navigation view.
  ///
  /// As a normal user, you will rarely need this information.
  static NavigationViewContext dataOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NavigationViewContext>()!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('titleBar', titleBar))
      ..add(DiagnosticsProperty('pane', pane))
      ..add(
        DiagnosticsProperty(
          'clipBehavior',
          clipBehavior,
          defaultValue: Clip.hardEdge,
        ),
      )
      ..add(DiagnosticsProperty('contentShape', contentShape));
  }

  @override
  State<NavigationView> createState() => NavigationViewState();
}

class NavigationViewState extends State<NavigationView> {
  /// The scroll controller used to keep the scrolling state of
  /// the list view when the display mode is switched between open
  /// and compact, and even keep it for the minimal state.
  ///
  /// It's also used to display and control the [Scrollbar] introduced
  /// by the panes.
  ScrollController? _paneScrollController;
  ScrollController get paneScrollController {
    if (widget.pane?.scrollController != null) {
      return widget.pane!.scrollController!;
    }
    _paneScrollController ??= ScrollController(
      debugLabel: '${widget.runtimeType} scroll controller',
    );
    return _paneScrollController!;
  }

  /// The key used to animate between open and compact display mode
  final _panelKey = GlobalKey();
  final _listKey = GlobalKey();
  final _secondaryListKey = GlobalKey();
  final _selectedItemKey = GlobalKey();
  final _contentKey = GlobalKey();
  final _overlayKey = GlobalKey();

  bool _minimalPaneOpen = false;

  /// Whether the minimal pane is open.
  ///
  /// Always false if the current display mode is not minimal.
  bool get isMinimalPaneOpen => _minimalPaneOpen;
  set isMinimalPaneOpen(bool open) {
    if (_displayMode == PaneDisplayMode.minimal) {
      if (_minimalPaneOpen != open) {
        setState(() => _minimalPaneOpen = open);
        widget.onDisplayModeChanged?.call(
          open ? PaneDisplayMode.expanded : PaneDisplayMode.minimal,
        );
      }
    } else {
      if (_minimalPaneOpen) {
        setState(() => _minimalPaneOpen = false);
      }
    }
  }

  late bool _compactOverlayOpen;

  /// Whether the compact pane is open.
  ///
  /// Always false if the current display mode is not open nor compact
  bool get compactOverlayOpen {
    if ([
      PaneDisplayMode.expanded,
      PaneDisplayMode.compact,
    ].contains(_displayMode)) {
      return _compactOverlayOpen;
    }
    _compactOverlayOpen = false;
    return false;
  }

  set compactOverlayOpen(bool value) {
    if (value == _compactOverlayOpen) return;
    if ([
      PaneDisplayMode.expanded,
      PaneDisplayMode.compact,
    ].contains(_displayMode)) {
      setState(() {
        _compactOverlayOpen = value;
        _isTransitioning = true;
      });
      PageStorage.of(context).writeState(
        context,
        _compactOverlayOpen,
        identifier: 'compactOverlayOpen',
      );
      return;
    }
    _compactOverlayOpen = false;
  }

  int _previousItemIndex = -1;

  /// Updates the previous item index.
  ///
  /// Use -1 to clear the previous item index.
  void _updatePreviousItemIndex(int index) {
    if (index != _previousItemIndex) {
      _previousItemIndex = index;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _compactOverlayOpen =
        PageStorage.of(
              context,
            ).readState(context, identifier: 'compactOverlayOpen')
            as bool? ??
        false;
  }

  @override
  void didUpdateWidget(NavigationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pane?.scrollController != oldWidget.pane?.scrollController) {
      if (widget.pane?.scrollController != null) {
        _paneScrollController?.dispose();
        _paneScrollController = null;
      }
    }

    if (oldWidget.pane?.selected != widget.pane?.selected) {
      _updatePreviousItemIndex(oldWidget.pane?.selected ?? -1);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ensureSelectedItemVisible();
      });
    }
  }

  @override
  void dispose() {
    // If the controller was created locally, dispose it
    if (widget.pane?.scrollController == null) {
      paneScrollController.dispose();
    }
    super.dispose();
  }

  /// Ensures the selected item is visible in the pane.
  void ensureSelectedItemVisible() {
    final item = _selectedItemKey.currentContext;
    if (item != null) {
      final atEnd =
          (widget.pane!.effectiveItems.length / 2) < widget.pane!.selected!;

      Scrollable.ensureVisible(
        item,
        alignmentPolicy: atEnd
            ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
            : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
  }

  /// Toggles the current compact mode
  void toggleCompactOpenMode() {
    compactOverlayOpen = !compactOverlayOpen;
    widget.onDisplayModeChanged?.call(
      compactOverlayOpen ? PaneDisplayMode.expanded : PaneDisplayMode.compact,
    );
  }

  bool get isTogglePaneButtonVisible {
    if (widget.pane != null && widget.pane!.toggleable) {
      return compactOverlayOpen ||
          isMinimalPaneOpen ||
          _displayMode == PaneDisplayMode.compact;
    }
    return false;
  }

  /// Whether the navigation pane is currently transitioning
  ///
  /// This is useful to prevent the user from interacting with the pane and to
  /// hide any other pane item features while the pane is animating, such as
  /// the `infoBadge`
  ///
  /// This is always false when display mode is top
  bool _isTransitioning = false;

  void _animationEndCallback([bool notify = true]) {
    _isTransitioning = false;
    if (mounted && notify) setState(() {});
  }

  PaneDisplayMode _displayMode = PaneDisplayMode.auto;

  /// The current display mode.
  ///
  /// If the pane display mode is automatic, it will adapt to the available
  /// space.
  PaneDisplayMode get displayMode => _displayMode;

  /// The layout adapts based on available width:
  /// - Width >= 1008px: Open mode (expanded pane)
  /// - Width 641-1007px: Compact mode (icons only)
  /// - Width <= 640px: Minimal mode (hamburger menu)
  void _resolveDisplayMode(BoxConstraints constraints) {
    final paneDisplayMode = widget.pane?.displayMode ?? PaneDisplayMode.auto;

    if (paneDisplayMode == PaneDisplayMode.auto) {
      var width = constraints.biggest.width;
      if (width.isInfinite) width = MediaQuery.widthOf(context);

      PaneDisplayMode autoDisplayMode;
      if (width <= 640) {
        autoDisplayMode = PaneDisplayMode.minimal;
      } else if (width >= 1008) {
        autoDisplayMode = PaneDisplayMode.expanded;
      } else {
        autoDisplayMode = PaneDisplayMode.compact;
      }

      if (autoDisplayMode != _displayMode) {
        widget.onDisplayModeChanged?.call(autoDisplayMode);
      }

      _displayMode = autoDisplayMode;
    } else {
      _displayMode = paneDisplayMode;
    }
  }

  /// Builds the navigation view with adaptive layout based on display mode.
  ///
  /// This method handles:
  /// - Automatic display mode switching when using [PaneDisplayMode.auto]
  /// - Different layouts for each display mode (top, open, compact, minimal)
  /// - Overlay management for compact and minimal modes
  /// - Content clipping and shaping
  /// - Animation coordination between pane transitions
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasDirectionality(context));
    assert(
      widget.content != null || widget.pane != null,
      'Either pane or content must be provided',
    );

    final theme = NavigationPaneTheme.of(context);
    final fluentTheme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    final direction = Directionality.of(context);

    Widget? paneNavigationButton() {
      final minimalLeading =
          PaneItem(
            title: Text(
              !isMinimalPaneOpen
                  ? localizations.openNavigationTooltip
                  : localizations.closeNavigationTooltip,
            ),
            icon: Icon(theme.paneNavigationButtonIcon),
            body: const SizedBox.shrink(),
          ).build(
            context: context,
            selected: false,
            onPressed: () async {
              isMinimalPaneOpen = !isMinimalPaneOpen;
              _isTransitioning = true;
            },
            displayMode: PaneDisplayMode.compact,
            itemIndex: -1,
          );
      return minimalLeading;
    }

    return LayoutBuilder(
      builder: (context, consts) {
        _resolveDisplayMode(consts);

        late Widget paneResult;
        if (widget.pane != null) {
          final pane = widget.pane!;
          final body = _NavigationBody(
            itemKey: ValueKey(pane.selected ?? -1),
            transitionBuilder: widget.transitionBuilder,
            paneBodyBuilder: widget.paneBodyBuilder,
            animationCurve: theme.animationCurve,
            animationDuration: theme.animationDuration,
          );

          if (pane.customPane != null) {
            paneResult = Builder(
              builder: (context) {
                return _NavigationViewPaneScrollConfiguration(
                  controller: paneScrollController,
                  hasTitleBar: widget.titleBar != null,
                  child: pane.customPane!.build(
                    context,
                    NavigationPaneWidgetData(
                      titleBar: widget.titleBar,
                      content: ClipRect(child: body),
                      listKey: _listKey,
                      paneKey: _panelKey,
                      scrollController: paneScrollController,
                      pane: pane,
                    ),
                  ),
                );
              },
            );
          } else {
            final contentShape =
                widget.contentShape ??
                RoundedRectangleBorder(
                  side: BorderSide(
                    color: FluentTheme.of(
                      context,
                    ).resources.cardStrokeColorDefault,
                  ),
                  borderRadius: _displayMode == PaneDisplayMode.top
                      ? BorderRadius.zero
                      : const BorderRadiusDirectional.only(
                          topStart: Radius.circular(8),
                        ).resolve(direction),
                );

            final Widget content = ClipRect(
              key: _contentKey,
              child: _displayMode == PaneDisplayMode.minimal
                  ? body
                  : DecoratedBox(
                      position: DecorationPosition.foreground,
                      decoration: ShapeDecoration(shape: contentShape),
                      child: ClipPath(
                        clipBehavior: widget.clipBehavior,
                        clipper: ShapeBorderClipper(shape: contentShape),
                        child: body,
                      ),
                    ),
            );
            if (_displayMode != PaneDisplayMode.expanded) {
              PageStorage.of(
                context,
              ).writeState(context, false, identifier: 'openModeOpen');
            }
            switch (_displayMode) {
              case PaneDisplayMode.top:
                _isTransitioning = false;
                paneResult = Column(
                  children: [
                    ?widget.titleBar,
                    _NavigationViewPaneScrollConfiguration(
                      controller: paneScrollController,
                      hasTitleBar: widget.titleBar != null,
                      child: _TopNavigationPane(pane: pane),
                    ),
                    Expanded(child: content),
                  ],
                );
              case PaneDisplayMode.compact:
                paneResult = _buildCompactView(
                  context: context,
                  pane: pane,
                  content: content,
                  constraints: consts,
                );
              case PaneDisplayMode.expanded:
                paneResult = Column(
                  children: [
                    ?widget.titleBar,
                    Expanded(
                      child: Row(
                        children: [
                          _NavigationViewPaneScrollConfiguration(
                            controller: paneScrollController,
                            hasTitleBar: widget.titleBar != null,
                            child: _OpenNavigationPane(
                              theme: theme,
                              pane: pane,
                              initiallyOpen:
                                  PageStorage.of(context).readState(
                                        context,
                                        identifier: 'openModeOpen',
                                      )
                                      as bool? ??
                                  mounted,
                              onAnimationEnd: _animationEndCallback,
                            ),
                          ),
                          Expanded(child: content),
                        ],
                      ),
                    ),
                  ],
                );
              case PaneDisplayMode.minimal:
                final openSize =
                    pane.size?.openPaneWidth ?? kOpenNavigationPaneWidth;

                paneResult = Stack(
                  children: [
                    PositionedDirectional(
                      top: 0,
                      start: 0,
                      end: 0,
                      height: 38,
                      child: ColoredBox(
                        color: fluentTheme.scaffoldBackgroundColor,
                      ),
                    ),
                    PositionedDirectional(
                      top: 38,
                      start: 0,
                      end: 0,
                      bottom: 0,
                      child: content,
                    ),
                    if (isMinimalPaneOpen)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () => isMinimalPaneOpen = false,
                          child: AbsorbPointer(
                            child: Semantics(
                              label: localizations.modalBarrierDismissLabel,
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                    AnimatedPositionedDirectional(
                      key: _overlayKey,
                      duration: theme.animationDuration ?? Duration.zero,
                      curve: theme.animationCurve ?? Curves.linear,
                      start: isMinimalPaneOpen ? 0.0 : -openSize,
                      width: openSize,
                      height: MediaQuery.heightOf(context),
                      onEnd: () {
                        _isTransitioning = false;
                        if (mounted) setState(() {});
                      },
                      child: _NavigationViewPaneScrollConfiguration(
                        controller: paneScrollController,
                        hasTitleBar: widget.titleBar != null,
                        child: Mica(
                          backgroundColor: theme.overlayBackgroundColor,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF6c6c6c),
                                width: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsetsDirectional.symmetric(
                              vertical: 1,
                            ),
                            padding: const EdgeInsetsDirectional.only(top: 38),
                            child: _OpenNavigationPane(
                              theme: theme,
                              pane: pane,
                              onItemSelected: () {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted &&
                                      _displayMode == PaneDisplayMode.minimal) {
                                    isMinimalPaneOpen = false;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    ?widget.titleBar,
                  ],
                );
              default:
                paneResult = content;
            }
          }
        } else if (widget.content != null) {
          paneResult = Column(
            children: [
              ?widget.titleBar,
              Expanded(child: widget.content!),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }

        return Mica(
          backgroundColor: theme.backgroundColor,
          child: NavigationViewContext(
            displayMode: _compactOverlayOpen
                ? PaneDisplayMode.expanded
                : _displayMode,
            isMinimalPaneOpen: isMinimalPaneOpen,
            isCompactOverlayOpen: _compactOverlayOpen,
            pane: widget.pane,
            previousItemIndex: _previousItemIndex,
            isTransitioning: _isTransitioning,
            isTogglePaneButtonVisible: isTogglePaneButtonVisible,
            child: paneResult,
          ),
        );
      },
    );
  }

  /// Builds the compact view.
  ///
  /// The compact view has these possible layouts:
  ///
  ///  * The compact view
  ///  * The compact view with an overlay, if there isn't enough space
  ///  * The compact view that opens without an overlay, if there is enough space
  Widget _buildCompactView({
    required final BuildContext context,
    required final NavigationPane pane,
    required final Widget content,
    required final BoxConstraints constraints,
  }) {
    final theme = NavigationPaneTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    // Ensure the overlay state is correct
    _compactOverlayOpen =
        PageStorage.of(
              context,
            ).readState(context, identifier: 'compactOverlayOpen')
            as bool? ??
        _compactOverlayOpen;

    final openSize = pane.size?.openPaneWidth ?? kOpenNavigationPaneWidth;

    final noOverlayRequired = constraints.maxWidth / 2.5 > openSize;
    final openedWithoutOverlay =
        _compactOverlayOpen && constraints.maxWidth / 2.5 > openSize;

    if (noOverlayRequired) {
      return Column(
        children: [
          ?widget.titleBar,
          Expanded(
            child: Row(
              children: [
                _NavigationViewPaneScrollConfiguration(
                  controller: paneScrollController,
                  hasTitleBar: widget.titleBar != null,
                  child: () {
                    if (openedWithoutOverlay) {
                      return Mica(
                        key: _overlayKey,
                        backgroundColor: theme.backgroundColor,
                        child: Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                            vertical: 1,
                          ),
                          child: _OpenNavigationPane(
                            theme: theme,
                            pane: pane,
                            // TODO(bdlukaa): Pane Toggle Button Position
                            // onToggle: pane.toggleable
                            //     ? toggleCompactOpenMode
                            //     : null,
                            initiallyOpen: true,
                            onAnimationEnd: _animationEndCallback,
                          ),
                        ),
                      );
                    } else {
                      return KeyedSubtree(
                        key: _overlayKey,
                        child: _CompactNavigationPane(
                          pane: pane,
                          onToggle: null,
                          // onToggle: pane.toggleable
                          //     ? toggleCompactOpenMode
                          //     : null,
                          onOpenSearch: widget.onOpenSearch,
                          onAnimationEnd: _animationEndCallback,
                        ),
                      );
                    }
                  }(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: 38,
              start: pane.size?.compactWidth ?? kCompactNavigationPaneWidth,
            ),
            child: content,
          ),
          if (_compactOverlayOpen && !openedWithoutOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: toggleCompactOpenMode,
                child: AbsorbPointer(
                  child: Semantics(
                    label: localizations.modalBarrierDismissLabel,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          _NavigationViewPaneScrollConfiguration(
            controller: paneScrollController,
            hasTitleBar: widget.titleBar != null,
            child: () {
              if (_compactOverlayOpen) {
                return ClipRect(
                  child: Mica(
                    key: _overlayKey,
                    backgroundColor: theme.overlayBackgroundColor,
                    elevation: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF6c6c6c),
                          width: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsetsDirectional.symmetric(
                        vertical: 1,
                      ),
                      padding: const EdgeInsetsDirectional.only(top: 38),
                      child: _OpenNavigationPane(
                        theme: theme,
                        pane: pane,
                        onToggle: toggleCompactOpenMode,
                        onItemSelected: toggleCompactOpenMode,
                        onAnimationEnd: _animationEndCallback,
                      ),
                    ),
                  ),
                );
              } else {
                return Mica(
                  key: _overlayKey,
                  backgroundColor: theme.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(top: 38),
                    child: _CompactNavigationPane(
                      pane: pane,
                      onToggle: toggleCompactOpenMode,
                      onOpenSearch: widget.onOpenSearch,
                      onAnimationEnd: _animationEndCallback,
                    ),
                  ),
                );
              }
            }(),
          ),
          ?widget.titleBar,
        ],
      );
    }
  }
}

class _NavigationViewPaneScrollConfiguration extends StatelessWidget {
  const _NavigationViewPaneScrollConfiguration({
    required this.controller,
    required this.hasTitleBar,
    required this.child,
  });

  final ScrollController controller;
  final bool hasTitleBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: controller,
      child: ScrollConfiguration(
        behavior: const NavigationViewScrollBehavior(),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: hasTitleBar,
          child: RepaintBoundary(child: child),
        ),
      ),
    );
  }
}

/// The [ScrollBehavior] used on [NavigationView]
///
/// It generates a [Scrollbar] using the global scroll controller provided by
/// [NavigationView]
class NavigationViewScrollBehavior extends FluentScrollBehavior {
  /// Creates a navigation view scroll behavior.
  const NavigationViewScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: false,
      interactive: true,
      child: child,
    );
  }
}
