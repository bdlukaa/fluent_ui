import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/navigation/navigation_panel/display_modes/compact.dart';
import 'package:flutter/rendering.dart';

part 'style.dart';
part 'tiles.dart';
part 'body.dart';

// TODO: NAVIGATION PANEL rework
// This need a rework to support the following topics:
// - top and left navigation. Currently it supports only left. On top navigation, the page transitions should default to Horizontal page transition
// - minimal display mode. Currently it only supports open and compact. This also require a rework on the Scaffold widget
// - open an overlay when hovering the panel when it's in compact or mininal mode
// - automatic mode. The current automatic mode is pretty simple and any deep usage can break it.
// - selected indicator. Currently only one indicator is supported (sliding horizontally)
// - pane footer. Currently, only one tile can be in the bottom, but in the offical implementation, there can be multiple tiles
// - back button. There is no back button currently. This would also require to remove the default top bar and implement a custom one
// For more info, head over to the official documentation: https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/navigationview
// Track this on github: https://github.com/bdlukaa/fluent_ui/issues/3

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
