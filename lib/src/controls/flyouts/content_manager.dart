import 'package:fluent_ui/fluent_ui.dart';

class ContentManager extends StatefulWidget {
  const ContentManager({
    Key? key,
    required this.content,
  }) : super(key: key);

  final WidgetBuilder content;

  @override
  State<ContentManager> createState() => _ContentManagerState();
}

class _ContentManagerState extends State<ContentManager> {
  final GlobalKey key = GlobalKey();
  Size size = Size.zero;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final context = key.currentContext;
      if (context == null) return;
      final box = context.findRenderObject() as RenderBox;
      setState(() => size = box.size);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: ContentSizeInfo(
        size: size,
        child: Builder(builder: (context) {
          return widget.content(context);
        }),
      ),
    );
  }
}

class ContentSizeInfo extends InheritedWidget {
  const ContentSizeInfo({
    Key? key,
    required Widget child,
    required this.size,
  }) : super(key: key, child: child);
  final Size size;
  static ContentSizeInfo of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ContentSizeInfo>()!;
  }

  static ContentSizeInfo? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ContentSizeInfo>();
  }

  @override
  bool updateShouldNotify(ContentSizeInfo oldWidget) {
    return oldWidget.size != size;
  }
}

typedef _MenuBuilder = Widget Function(
  BuildContext context,
  BoxConstraints rootSize,
  Iterable<Widget> menus,
  Iterable<GlobalKey> keys,
);

@protected
class MenuInfoProvider extends StatefulWidget {
  const MenuInfoProvider({
    Key? key,
    required this.builder,
    required this.flyoutKey,
    required this.additionalOffset,
    required this.margin,
  }) : super(key: key);

  final GlobalKey flyoutKey;
  final _MenuBuilder builder;
  final double additionalOffset;
  final double margin;

  static MenuInfoProviderState of(BuildContext context) {
    return context.findAncestorStateOfType<MenuInfoProviderState>()!;
  }

  @override
  State<MenuInfoProvider> createState() => MenuInfoProviderState();
}

class MenuInfoProviderState extends State<MenuInfoProvider> {
  final _menus = <GlobalKey, Widget>{};

  void add(Widget menu, GlobalKey key) {
    setState(() => _menus.addAll({key: menu}));
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
