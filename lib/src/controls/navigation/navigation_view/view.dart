import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

part 'body.dart';
part 'indicators.dart';
part 'pane.dart';
part 'pane_items.dart';
part 'style.dart';

/// The default size used by the app top bar.
///
/// Value eyeballed from Windows 10 v10.0.19041.928
const double _kDefaultAppBarHeight = 50;

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
/// * [PaneDisplayMode.open] - Expanded pane with icons and labels
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
    this.appBar,
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

  /// The app bar of the app.
  final NavigationAppBar? appBar;

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
  /// is returned. If the pane is open, [PaneDisplayMode.open] is returned.
  ///
  /// If the display mode is set to minimal, this is called when the pane is opened
  /// or closed. If the pane is closed, [PaneDisplayMode.minimal] is returned.
  /// If the pane is open, [PaneDisplayMode.open] is returned.
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
  static InheritedNavigationView dataOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedNavigationView>()!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('appBar', appBar))
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
  late ScrollController paneScrollController;

  /// The key used to animate between open and compact display mode
  final _panelKey = GlobalKey();
  final _listKey = GlobalKey();
  final _contentKey = GlobalKey();
  final _overlayKey = GlobalKey();

  bool _minimalPaneOpen = false;

  /// Whether the minimal pane is open.
  ///
  /// Always false if the current display mode is not minimal.
  bool get minimalPaneOpen => _minimalPaneOpen;
  set minimalPaneOpen(bool open) {
    if (displayMode == PaneDisplayMode.minimal) {
      if (_minimalPaneOpen != open) {
        setState(() => _minimalPaneOpen = open);
        widget.onDisplayModeChanged?.call(
          open ? PaneDisplayMode.open : PaneDisplayMode.minimal,
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
    if ([PaneDisplayMode.open, PaneDisplayMode.compact].contains(displayMode)) {
      return _compactOverlayOpen;
    }
    _compactOverlayOpen = false;

    return false;
  }

  set compactOverlayOpen(bool value) {
    if (value == _compactOverlayOpen) return;
    if ([PaneDisplayMode.open, PaneDisplayMode.compact].contains(displayMode)) {
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

  int _previousItemIndex = 0;

  PaneDisplayMode? _autoDisplayMode;

  /// Gets the current display mode. If it's automatic, it'll adapt to the other
  /// display modes according to the current available space.
  PaneDisplayMode get displayMode {
    if (widget.pane?.displayMode == PaneDisplayMode.auto) {
      return _autoDisplayMode ?? PaneDisplayMode.minimal;
    }

    return widget.pane?.displayMode ?? PaneDisplayMode.minimal;
  }

  @override
  void initState() {
    super.initState();
    paneScrollController =
        widget.pane?.scrollController ??
        ScrollController(debugLabel: '${widget.runtimeType} scroll controller');

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
    if (widget.pane?.scrollController != paneScrollController) {
      paneScrollController =
          widget.pane?.scrollController ?? paneScrollController;
    }

    if (oldWidget.pane?.selected != widget.pane?.selected) {
      _previousItemIndex = oldWidget.pane?.selected ?? -1;

      final item = widget.pane?.selected == null
          ? null
          : widget.pane?.selectedItem.itemKey.currentContext;

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
  }

  @override
  void dispose() {
    // If the controller was created locally, dispose it
    if (widget.pane?.scrollController == null) {
      paneScrollController.dispose();
    }
    super.dispose();
  }

  /// Toggles the current compact mode
  void toggleCompactOpenMode() {
    compactOverlayOpen = !compactOverlayOpen;
    widget.onDisplayModeChanged?.call(
      compactOverlayOpen ? PaneDisplayMode.open : PaneDisplayMode.compact,
    );
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

  EdgeInsets get appBarPadding => EdgeInsetsDirectional.only(
    top: widget.appBar?.finalHeight(context) ?? 0.0,
  ).resolve(Directionality.of(context));

  PaneDisplayMode _resolveDisplayMode(
    BoxConstraints constraints,
    Size mediaQuerySize,
  ) {
    var displayMode = widget.pane?.displayMode ?? PaneDisplayMode.auto;

    if (displayMode == PaneDisplayMode.auto) {
      var width = constraints.biggest.width;
      if (width.isInfinite) width = mediaQuerySize.width;

      PaneDisplayMode autoDisplayMode;
      if (width <= 640) {
        autoDisplayMode = PaneDisplayMode.minimal;
      } else if (width >= 1008) {
        autoDisplayMode = PaneDisplayMode.open;
      } else {
        autoDisplayMode = PaneDisplayMode.compact;
      }

      if (autoDisplayMode != _autoDisplayMode) {
        widget.onDisplayModeChanged?.call(autoDisplayMode);
      }

      displayMode = _autoDisplayMode = autoDisplayMode;
    }
    assert(displayMode != PaneDisplayMode.auto);
    return displayMode;
  }

  /// Builds the navigation view with adaptive layout based on display mode.
  ///
  /// This method handles:
  /// - Automatic display mode switching when using [PaneDisplayMode.auto]
  /// - Different layouts for each display mode (top, open, compact, minimal)
  /// - Overlay management for compact and minimal modes
  /// - Content clipping and shaping
  /// - Animation coordination between pane transitions
  ///
  /// The layout adapts based on available width:
  /// - Width >= 1008px: Open mode (expanded pane)
  /// - Width 641-1007px: Compact mode (icons only)
  /// - Width <= 640px: Minimal mode (hamburger menu)
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
    final mediaQuerySize = MediaQuery.sizeOf(context);
    final direction = Directionality.of(context);

    Widget? paneNavigationButton() {
      final minimalLeading =
          PaneItem(
            title: Text(
              !minimalPaneOpen
                  ? localizations.openNavigationTooltip
                  : localizations.closeNavigationTooltip,
            ),
            icon: Icon(theme.paneNavigationButtonIcon),
            body: const SizedBox.shrink(),
          ).build(context, false, () async {
            minimalPaneOpen = !minimalPaneOpen;
            _isTransitioning = true;
          }, displayMode: PaneDisplayMode.compact);
      return minimalLeading;
    }

    return LayoutBuilder(
      builder: (context, consts) {
        final displayMode = _resolveDisplayMode(consts, mediaQuerySize);

        Widget appBar;
        if (widget.appBar != null) {
          appBar = _NavigationAppBar(
            appBar: widget.appBar!,
            additionalLeading: () {
              if (widget.pane != null) {
                return displayMode == PaneDisplayMode.minimal
                    ? paneNavigationButton()
                    : null;
              }
            }(),
          );
        } else {
          appBar = LayoutBuilder(
            builder: (context, constraints) =>
                SizedBox(width: constraints.maxWidth, height: 0),
          );
        }

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
                  hasAppBar: widget.appBar != null,
                  child: pane.customPane!.build(
                    context,
                    NavigationPaneWidgetData(
                      appBar: appBar,
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
                  borderRadius: displayMode == PaneDisplayMode.top
                      ? BorderRadius.zero
                      : const BorderRadiusDirectional.only(
                          topStart: Radius.circular(8),
                        ).resolve(direction),
                );

            final Widget content = ClipRect(
              key: _contentKey,
              child: displayMode == PaneDisplayMode.minimal
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
            if (displayMode != PaneDisplayMode.open) {
              PageStorage.of(
                context,
              ).writeState(context, false, identifier: 'openModeOpen');
            }
            switch (displayMode) {
              case PaneDisplayMode.top:
                _isTransitioning = false;
                paneResult = Column(
                  children: [
                    appBar,
                    _NavigationViewPaneScrollConfiguration(
                      controller: paneScrollController,
                      hasAppBar: widget.appBar != null,
                      child: _TopNavigationPane(
                        pane: pane,
                        listKey: _listKey,
                        appBar: widget.appBar,
                      ),
                    ),
                    Expanded(child: content),
                  ],
                );
              case PaneDisplayMode.compact:
                paneResult = _buildCompactView(
                  context: context,
                  pane: pane,
                  appBar: appBar,
                  content: content,
                  constraints: consts,
                );
              case PaneDisplayMode.open:
                paneResult = Column(
                  children: [
                    appBar,
                    Expanded(
                      child: Row(
                        children: [
                          _NavigationViewPaneScrollConfiguration(
                            controller: paneScrollController,
                            hasAppBar: widget.appBar != null,
                            child: _OpenNavigationPane(
                              theme: theme,
                              pane: pane,
                              paneKey: _panelKey,
                              listKey: _listKey,
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
                      height: widget.appBar?.finalHeight(context) ?? 0.0,
                      child: ColoredBox(
                        color: fluentTheme.scaffoldBackgroundColor,
                      ),
                    ),
                    PositionedDirectional(
                      top: widget.appBar?.finalHeight(context) ?? 0.0,
                      start: 0,
                      end: 0,
                      bottom: 0,
                      child: content,
                    ),
                    if (minimalPaneOpen)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () => minimalPaneOpen = false,
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
                      start: minimalPaneOpen ? 0.0 : -openSize,
                      width: openSize,
                      height: mediaQuerySize.height,
                      onEnd: () {
                        _isTransitioning = false;
                        if (mounted) setState(() {});
                      },
                      child: _NavigationViewPaneScrollConfiguration(
                        controller: paneScrollController,
                        hasAppBar: widget.appBar != null,
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
                            padding: appBarPadding,
                            child: _OpenNavigationPane(
                              theme: theme,
                              pane: pane,
                              paneKey: _panelKey,
                              listKey: _listKey,
                              onItemSelected: () {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted &&
                                      displayMode == PaneDisplayMode.minimal) {
                                    minimalPaneOpen = false;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    appBar,
                  ],
                );
              default:
                paneResult = content;
            }
          }
        } else if (widget.content != null) {
          paneResult = Column(
            children: [
              appBar,
              Expanded(child: widget.content!),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }

        return Mica(
          backgroundColor: theme.backgroundColor,
          child: InheritedNavigationView(
            displayMode: _compactOverlayOpen
                ? PaneDisplayMode.open
                : displayMode,
            minimalPaneOpen: minimalPaneOpen,
            pane: widget.pane,
            previousItemIndex: _previousItemIndex,
            isTransitioning: _isTransitioning,
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
    required final Widget appBar,
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
          appBar,
          Expanded(
            child: Row(
              children: [
                _NavigationViewPaneScrollConfiguration(
                  controller: paneScrollController,
                  hasAppBar: widget.appBar != null,
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
                            paneKey: _panelKey,
                            listKey: _listKey,
                            onToggle: pane.toggleable
                                ? toggleCompactOpenMode
                                : null,
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
                          paneKey: _panelKey,
                          listKey: _listKey,
                          onToggle: pane.toggleable
                              ? toggleCompactOpenMode
                              : null,
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
              top: appBarPadding.top,
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
            hasAppBar: widget.appBar != null,
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
                      padding: appBarPadding,
                      child: _OpenNavigationPane(
                        theme: theme,
                        pane: pane,
                        paneKey: _panelKey,
                        listKey: _listKey,
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
                    padding: EdgeInsetsDirectional.only(top: appBarPadding.top),
                    child: _CompactNavigationPane(
                      pane: pane,
                      paneKey: _panelKey,
                      listKey: _listKey,
                      onToggle: toggleCompactOpenMode,
                      onOpenSearch: widget.onOpenSearch,
                      onAnimationEnd: _animationEndCallback,
                    ),
                  ),
                );
              }
            }(),
          ),
          appBar,
        ],
      );
    }
  }
}

class _NavigationViewPaneScrollConfiguration extends StatelessWidget {
  const _NavigationViewPaneScrollConfiguration({
    required this.controller,
    required this.hasAppBar,
    required this.child,
  });

  final ScrollController controller;
  final bool hasAppBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: controller,
      child: ScrollConfiguration(
        behavior: const NavigationViewScrollBehavior(),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: hasAppBar,
          child: RepaintBoundary(child: child),
        ),
      ),
    );
  }
}

/// Data passed to [NavigationAppBarLayoutBuilder] for custom layouts.
class NavigationAppBarData {
  /// Creates navigation app bar data.
  const NavigationAppBarData({
    required this.leading,
    required this.title,
    required this.actions,
    required this.displayMode,
    required this.additionalLeading,
  });

  /// The leading widget (typically a back button).
  final Widget leading;

  /// The title widget.
  final Widget title;

  /// The actions widget.
  final Widget? actions;

  /// The current display mode of the navigation pane.
  final PaneDisplayMode displayMode;

  /// Additional leading widget (e.g., hamburger menu in minimal mode).
  final Widget? additionalLeading;
}

/// A builder function for creating custom app bar layouts.
///
/// Use this when you need complete control over the app bar layout.
///
/// Example:
/// ```dart
/// NavigationAppBar(
///   title: Text('My App'),
///   layoutBuilder: (context, data) {
///     return Row(
///       children: [
///         data.leading,
///         Expanded(child: data.title),
///         if (data.actions != null) data.actions!,
///       ],
///     );
///   },
/// )
/// ```
typedef NavigationAppBarLayoutBuilder =
    Widget Function(BuildContext context, NavigationAppBarData data);

/// The bar displayed at the top of the app. It can adapt itself to
/// all the display modes.
///
/// The app bar can be customized using the standard properties ([leading],
/// [title], [actions]), or fully customized using [layoutBuilder] for
/// complete control over the layout.
///
/// See also:
///
///   * [NavigationView], which uses this to render the app bar
class NavigationAppBar with Diagnosticable {
  /// {@macro flutter.widgets.Widget.key}
  final Key? key;

  /// The widget at the beggining of the app bar, before [title].
  ///
  /// Typically the [leading] widget is an [Icon] or an [IconButton].
  ///
  /// If this is null and [automaticallyImplyLeading] is set to true, the
  /// view will imply an appropriate widget. If  the parent [Navigator] can
  /// go back, the app bar will use an [IconButton] that calls [Navigator.maybePop].
  ///
  /// See also:
  ///   * [automaticallyImplyLeading], that controls whether we should try to
  ///     imply the leading widget, if [leading] is null
  final Widget? leading;

  /// {@macro flutter.material.appbar.automaticallyImplyLeading}
  final bool automaticallyImplyLeading;

  /// Typically a [Text] widget that contains the app name.
  final Widget? title;

  /// A list of Widgets to display in a row after the [title] widget.
  ///
  /// Typically these widgets are [IconButton]s representing common
  /// operations.
  final Widget? actions;

  /// The height of the app bar. [_kDefaultAppBarHeight] is used by default
  final double height;

  /// The background color of this app bar.
  ///
  /// If this is provided, [decoration] must be null.
  final Color? backgroundColor;

  /// The decoration of this app bar.
  ///
  /// If this is provided, [backgroundColor] must be null.
  final Decoration? decoration;

  /// A builder for creating custom app bar layouts.
  ///
  /// When provided, this builder is used instead of the default layout.
  /// This gives complete control over how the app bar content is arranged.
  ///
  /// The builder receives [NavigationAppBarData] containing all the default
  /// widgets that would normally be displayed, allowing you to rearrange
  /// or replace them as needed.
  ///
  /// Example:
  /// ```dart
  /// NavigationAppBar(
  ///   title: Text('My App'),
  ///   actions: IconButton(...),
  ///   layoutBuilder: (context, data) {
  ///     // Custom centered title layout
  ///     return Stack(
  ///       children: [
  ///         Align(
  ///           alignment: Alignment.centerLeft,
  ///           child: Row(
  ///             mainAxisSize: MainAxisSize.min,
  ///             children: [
  ///               data.leading,
  ///               if (data.additionalLeading != null) data.additionalLeading!,
  ///             ],
  ///           ),
  ///         ),
  ///         Center(child: data.title),
  ///         if (data.actions != null)
  ///           Align(
  ///             alignment: Alignment.centerRight,
  ///             child: data.actions,
  ///           ),
  ///       ],
  ///     );
  ///   },
  /// )
  /// ```
  final NavigationAppBarLayoutBuilder? layoutBuilder;

  /// Creates a windows-styled app bar.
  const NavigationAppBar({
    this.key,
    this.leading,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.height = _kDefaultAppBarHeight,
    this.backgroundColor,
    this.decoration,
    this.layoutBuilder,
  }) : assert(
         (backgroundColor == null && decoration == null) ||
             (backgroundColor != null && decoration == null) ||
             (backgroundColor == null && decoration != null),
         'Only one of backgroundColor or decoration can be provided',
       );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        FlagProperty(
          'automatically imply leading',
          value: automaticallyImplyLeading,
          ifFalse: 'do not imply leading',
          defaultValue: true,
        ),
      )
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(DiagnosticsProperty<Decoration>('decoration', decoration))
      ..add(
        DoubleProperty('height', height, defaultValue: _kDefaultAppBarHeight),
      );
  }

  Widget _buildLeading([bool imply = true]) {
    return Builder(
      builder: (context) {
        late Widget widget;
        if (leading != null) {
          widget = leading!;
        } else if (automaticallyImplyLeading && imply) {
          final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
          final canPop = parentRoute?.canPop ?? false;

          assert(debugCheckHasFluentLocalizations(context));
          assert(debugCheckHasFluentTheme(context));
          final localizations = FluentLocalizations.of(context);
          final localFluentTheme = FluentTheme.of(context);
          final onPressed = canPop ? () => Navigator.maybePop(context) : null;
          widget = NavigationPaneTheme(
            data: NavigationPaneTheme.of(context).merge(
              NavigationPaneThemeData(
                unselectedIconColor: WidgetStateProperty.resolveWith((states) {
                  if (states.isDisabled) {
                    return ButtonThemeData.buttonColor(context, states);
                  }
                  return ButtonThemeData.uncheckedInputColor(
                    localFluentTheme,
                    states,
                  ).basedOnLuminance();
                }),
              ),
            ),
            child: Builder(
              builder: (context) =>
                  PaneItem(
                    icon: const WindowsIcon(WindowsIcons.back, size: 14),
                    title: Text(localizations.backButtonTooltip),
                    body: const SizedBox.shrink(),
                  ).build(
                    context,
                    false,
                    onPressed,
                    displayMode: PaneDisplayMode.compact,
                  ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kCompactNavigationPaneWidth,
          ),
          child: widget,
        );
      },
    );
  }

  /// Determines the height of this app bar based on its height and the top
  /// padding from the system.
  @visibleForTesting
  double finalHeight(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final topPadding = MediaQuery.paddingOf(context).top;
    return height + topPadding;
  }
}

class _NavigationAppBar extends StatelessWidget {
  const _NavigationAppBar({
    required this.appBar,
    required this.additionalLeading,
  });

  final NavigationAppBar appBar;
  final Widget? additionalLeading;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasFluentLocalizations(context));

    final displayMode =
        InheritedNavigationView.maybeOf(context)?.displayMode ??
        PaneDisplayMode.top;
    final leading = appBar._buildLeading(displayMode != PaneDisplayMode.top);
    final title = () {
      if (appBar.title != null) {
        assert(debugCheckHasFluentTheme(context));
        final theme = NavigationPaneTheme.of(context);
        final fluentTheme = FluentTheme.of(context);

        return AnimatedPadding(
          duration: theme.animationDuration ?? Duration.zero,
          curve: theme.animationCurve ?? Curves.linear,
          padding: (theme.iconPadding ?? EdgeInsetsDirectional.zero).add(
            const EdgeInsetsDirectional.only(start: 6),
          ),
          child: DefaultTextStyle.merge(
            style: fluentTheme.typography.caption,
            maxLines: 1,
            softWrap: false,
            child: appBar.title!,
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }();

    late Widget result;

    // Check if a custom layout builder is provided
    if (appBar.layoutBuilder != null) {
      result = appBar.layoutBuilder!(
        context,
        NavigationAppBarData(
          leading: leading,
          title: title,
          actions: appBar.actions,
          displayMode: displayMode,
          additionalLeading: additionalLeading,
        ),
      );
    } else {
      // Use default layout based on display mode
      switch (displayMode) {
        case PaneDisplayMode.top:
          result = Stack(
            children: [
              Row(
                children: [
                  leading,
                  if (additionalLeading != null) additionalLeading!,
                  Expanded(child: title),
                ],
              ),
              if (appBar.actions != null)
                PositionedDirectional(end: 0, child: appBar.actions!),
            ],
          );
        case PaneDisplayMode.minimal:
        case PaneDisplayMode.open:
        case PaneDisplayMode.compact:
          result = Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    leading,
                    if (additionalLeading != null) additionalLeading!,
                    Flexible(child: title),
                  ],
                ),
              ),
              if (appBar.actions != null)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: appBar.actions,
                  ),
                ),
            ],
          );
        default:
          return const SizedBox.shrink();
      }
    }

    final mediaQueryPadding = MediaQuery.paddingOf(context);

    return Container(
      color: appBar.backgroundColor,
      decoration: appBar.decoration,
      height: appBar.finalHeight(context),
      padding: EdgeInsetsDirectional.only(top: mediaQueryPadding.top),
      child: result,
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
