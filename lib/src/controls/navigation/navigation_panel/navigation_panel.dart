import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

part 'style.dart';
part 'tiles.dart';

enum NavigationPanelDisplayMode { open, compact, minimal }

// TODO: this need a rework
class NavigationPanel extends StatefulWidget {
  const NavigationPanel({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.onChanged,
    this.menu,
    this.bottom,
    this.displayMode,
  })  : assert(items.length >= 2),
        assert(currentIndex >= 0 && currentIndex < items.length),
        super(key: key);

  final int currentIndex;
  final ValueChanged<int>? onChanged;

  final NavigationPanelMenuItem? menu;
  final List<NavigationPanelItem> items;
  final NavigationPanelItem? bottom;

  final NavigationPanelDisplayMode? displayMode;

  @override
  _NavigationPanelState createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  NavigationPanelDisplayMode? displayMode;

  @override
  void initState() {
    super.initState();
    if (widget.displayMode != null) displayMode = widget.displayMode!;
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    return LayoutBuilder(builder: (context, consts) {
      NavigationPanelDisplayMode? displayMode = this.displayMode;
      if (displayMode == null) {
        double width = consts.biggest.width;
        if (width.isInfinite) width = MediaQuery.of(context).size.width;
        if (width >= 680) {
          displayMode = NavigationPanelDisplayMode.open;
        } else if (width >= 400) {
          displayMode = NavigationPanelDisplayMode.compact;
        } else
          displayMode = NavigationPanelDisplayMode.minimal;
      }
      switch (displayMode) {
        case NavigationPanelDisplayMode.compact:
        case NavigationPanelDisplayMode.open:
          final width =
              displayMode == NavigationPanelDisplayMode.compact ? 50.0 : 320.0;
          final items = ([...widget.items]
            ..removeWhere((e) => e.runtimeType != NavigationPanelItem));
          return Acrylic(
            width: width,
            child: Column(children: [
              if (widget.menu != null)
                _WidthScrollview(
                  width: width,
                  padding: EdgeInsets.only(bottom: 22, top: 22),
                  child: NavigationPanelMenu(
                    item: widget.menu!,
                    compact: displayMode == NavigationPanelDisplayMode.compact,
                    onTap: () {
                      if (displayMode == NavigationPanelDisplayMode.open) {
                        setState(() {
                          this.displayMode = NavigationPanelDisplayMode.compact;
                        });
                      } else if (displayMode ==
                          NavigationPanelDisplayMode.compact) {
                        setState(() {
                          this.displayMode = NavigationPanelDisplayMode.open;
                        });
                      }
                    },
                  ),
                ),
              Expanded(
                child: ListView(children: [
                  ...List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    if (item is NavigationPanelSectionHeader &&
                        displayMode == NavigationPanelDisplayMode.compact)
                      return SizedBox();
                    // Use this to avoid overflow when animation is happening
                    return _WidthScrollview(
                      width: width,
                      child: () {
                        if (item is NavigationPanelSectionHeader)
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8,
                            ),
                            child: DefaultTextStyle(
                              style: context.theme!.typography?.base ??
                                  const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                              child: item.label!,
                            ),
                          );
                        else if (item is NavigationPanelTileSeparator) {
                          // TODO: NavigationPanelTileSeparator
                          return SizedBox();
                        }
                        final index = items.indexOf(item);
                        return NavigationPanelItemTile(
                          item: item,
                          selected: widget.currentIndex == index,
                          onTap: widget.onChanged == null
                              ? null
                              : () => widget.onChanged!(index),
                          compact:
                              displayMode == NavigationPanelDisplayMode.compact,
                        );
                      }(),
                    );
                  }),
                ]),
              ),
              if (widget.bottom != null)
                _WidthScrollview(
                  width: width,
                  padding: EdgeInsets.only(bottom: 4),
                  child: NavigationPanelItemTile(
                    item: widget.bottom!,
                    selected: false,
                    compact: displayMode == NavigationPanelDisplayMode.compact,
                    onTap: widget.onChanged == null
                        ? null
                        : () => widget.onChanged!(items.length),
                  ),
                ),
            ]),
          );
        case NavigationPanelDisplayMode.minimal:
        default:
          return SizedBox();
      }
    });
  }
}

class _WidthScrollview extends StatelessWidget {
  const _WidthScrollview({
    Key? key,
    required this.child,
    this.direction = Axis.horizontal,
    this.width,
    this.padding,
  }) : super(key: key);

  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: direction,
      child: AnimatedContainer(
        duration: context.theme!.animationDuration ?? Duration.zero,
        curve: context.theme!.animationCurve ?? Curves.linear,
        width: width,
        padding: padding,
        child: child,
      ),
    );
  }
}
