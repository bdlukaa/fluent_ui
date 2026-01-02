import 'package:fluent_ui/fluent_ui.dart';

/// Stores info about the current flyout, such as positioning, sub menus and transitions
///
/// See also:
///
///  * [FlyoutAttach], which the flyout is displayed attached to
class Flyout extends StatefulWidget {
  /// {@template fluent_ui.flyout.builder}
  /// The builder for the flyout content.
  /// {@endtemplate}
  final WidgetBuilder builder;

  /// The root navigator state for navigation operations.
  final NavigatorState? root;

  /// The key of the root flyout in a flyout tree.
  final GlobalKey? rootFlyout;

  /// The key for this flyout's menu, used in sub-menus.
  final GlobalKey? menuKey;

  /// {@template fluent_ui.flyout.additionalOffset}
  /// How far the flyout should be from the target.
  /// {@endtemplate}
  final double additionalOffset;

  /// {@template fluent_ui.flyout.margin}
  /// How far the flyout should be from the screen edges.
  /// {@endtemplate}
  final double margin;

  /// {@template fluent_ui.flyout.transitionDuration}
  /// The duration of the transition animation when opening.
  /// {@endtemplate}
  final Duration transitionDuration;

  /// {@template fluent_ui.flyout.reverseTransitionDuration}
  /// The duration of the transition animation when closing.
  /// {@endtemplate}
  final Duration reverseTransitionDuration;

  /// {@template fluent_ui.flyout.transitionBuilder}
  /// The builder for the flyout transition animation.
  /// {@endtemplate}
  final FlyoutTransitionBuilder transitionBuilder;

  /// {@template fluent_ui.flyout.placementMode}
  /// The placement mode determining where the flyout appears.
  /// {@endtemplate}
  final FlyoutPlacementMode placementMode;

  /// Create a flyout.
  const Flyout({
    required this.builder,
    required this.root,
    required this.rootFlyout,
    required this.menuKey,
    required this.additionalOffset,
    required this.margin,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    required this.transitionBuilder,
    required this.placementMode,
    super.key,
  });

  /// Gets the current flyout info
  static FlyoutState of(BuildContext context) {
    return context.findAncestorStateOfType<FlyoutState>()!;
  }

  /// Returns the closest [FlyoutState] ancestor, if any.
  static FlyoutState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<FlyoutState>();
  }

  @override
  State<Flyout> createState() => FlyoutState();
}

/// The state for a [Flyout] widget.
///
/// Provides access to flyout properties and methods to control the flyout.
class FlyoutState extends State<Flyout> {
  final _key = GlobalKey(debugLabel: 'FlyoutState key');

  /// The flyout in the beggining of the flyout tree
  GlobalKey get rootFlyout => widget.rootFlyout!;

  /// How far the flyout should be from the target
  double get additionalOffset => widget.additionalOffset;

  /// How far the flyout should be from the screen
  double get margin => widget.margin;

  /// The duration of the transition animation
  Duration get transitionDuration => widget.transitionDuration;

  /// The duration of the reverse transition animation
  Duration get reverseTransitionDuration => widget.reverseTransitionDuration;

  /// The transition builder
  FlyoutTransitionBuilder get transitionBuilder => widget.transitionBuilder;

  /// The placement mode of the flyout
  FlyoutPlacementMode get placementMode => widget.placementMode;

  /// Closes the current open flyout.
  ///
  /// If the current flyout is a sub menu, the submenu is closed.
  void close() {
    if (widget.menuKey != null) {
      MenuInfoProvider.of(context).remove(widget.menuKey!);
      return;
    }
    final parent = Flyout.maybeOf(context);

    final navigatorKey = parent?.widget.root ?? widget.root;
    assert(navigatorKey != null, 'The flyout is not open');

    navigatorKey!.pop();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: Builder(builder: widget.builder),
    );
  }
}

/// A builder function for rendering menus in a flyout.
///
/// The [rootSize] provides the constraints of the root flyout area.
/// The [menus] are the current sub-menus to display.
/// The [keys] are the global keys for each menu.
typedef MenuBuilder =
    Widget Function(
      BuildContext context,
      BoxConstraints rootSize,
      Iterable<Widget> menus,
      Iterable<GlobalKey> keys,
    );

/// Provides menu state management for flyouts with sub-menus.
///
/// See also:
///
///  * [MenuInfoProviderState], which manages the sub-menu tree
class MenuInfoProvider extends StatefulWidget {
  /// The builder for rendering the menus.
  final MenuBuilder builder;

  /// Creates a menu info provider.
  @protected
  const MenuInfoProvider({required this.builder, super.key});

  /// Gets the current state of the sub menus of the root flyout
  static MenuInfoProviderState of(BuildContext context) {
    return context.findAncestorStateOfType<MenuInfoProviderState>()!;
  }

  /// Gets the current state of the sub menus of the root flyout
  static MenuInfoProviderState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<MenuInfoProviderState>();
  }

  @override
  State<MenuInfoProvider> createState() => MenuInfoProviderState();
}

/// The state for a [MenuInfoProvider] widget.
///
/// Manages sub-menus in a flyout tree, allowing menus to be added and removed.
class MenuInfoProviderState extends State<MenuInfoProvider> {
  final _menus = <GlobalKey, Widget>{};

  /// Inserts a sub menu in the tree. If already existing, it's updated with the
  /// provided [menu]
  void add(Widget menu, GlobalKey key) {
    setState(() => _menus[key] = menu);
  }

  /// Removes any sub menu from the flyout tree
  void remove(GlobalKey key) {
    if (contains(key)) setState(() => _menus.remove(key));
  }

  /// Whether then given sub menu is present in the tree
  bool contains(GlobalKey key) {
    return _menus.containsKey(key);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return widget.builder(context, constraints, _menus.values, _menus.keys);
      },
    );
  }
}
