import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/navigation/navigation_panel/display_modes/compact.dart';
import 'package:flutter/rendering.dart';

part 'style.dart';
part 'tiles.dart';
part 'body.dart';

enum NavigationPanelDisplayMode { open, compact, minimal }

class NavigationPanel extends StatefulWidget {
  const NavigationPanel({
    Key? key,
    required this.currentIndex,
    required this.items,
    this.menu,
    this.bottom,
    this.displayMode,
  }) : super(key: key);

  final int currentIndex;

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
          return CompactOpenNavigationPanel(
            compact: displayMode == NavigationPanelDisplayMode.compact,
            currentIndex: widget.currentIndex,
            items: widget.items,
            bottom: widget.bottom,
            menu: widget.menu,
            onMenuTapped: () {
              if (displayMode == NavigationPanelDisplayMode.open) {
                setState(() {
                  this.displayMode = NavigationPanelDisplayMode.compact;
                });
              } else if (displayMode == NavigationPanelDisplayMode.compact) {
                setState(() {
                  this.displayMode = NavigationPanelDisplayMode.open;
                });
              }
            },
          );
        case NavigationPanelDisplayMode.minimal:
        default:
          return SizedBox();
      }
    });
  }
}
