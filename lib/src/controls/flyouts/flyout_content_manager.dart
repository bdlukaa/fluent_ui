import 'package:fluent_ui/fluent_ui.dart';

/// Stores info about the current flyout, such as positioning, sub menus and transitions
///
/// See also:
///
///  * [FlyoutAttach], which the flyout is displayed attached to
class Flyout extends StatefulWidget {
  final WidgetBuilder builder;

  final NavigatorState? root;
  final GlobalKey? rootFlyout;
  final GlobalKey? menuKey;

  final double additionalOffset;
  final double margin;

  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  final FlyoutTransitionBuilder transitionBuilder;

  final FlyoutPlacementMode placementMode;

  /// Create a flyout.
  const Flyout({
    super.key,
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
  });

  /// Gets the current flyout info
  static FlyoutState of(BuildContext context) {
    return context.findAncestorStateOfType<FlyoutState>()!;
  }

  static FlyoutState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<FlyoutState>();
  }

  @override
  State<Flyout> createState() => FlyoutState();
}

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

typedef MenuBuilder = Widget Function(
  BuildContext context,
  BoxConstraints rootSize,
  Iterable<Widget> menus,
  Iterable<GlobalKey> keys,
);

class MenuInfoProvider extends StatefulWidget {
  final MenuBuilder builder;

  @protected
  const MenuInfoProvider({super.key, required this.builder});

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
    return LayoutBuilder(builder: (context, constraints) {
      return widget.builder(
        context,
        constraints,
        _menus.values,
        _menus.keys,
      );
    });
  }
}
