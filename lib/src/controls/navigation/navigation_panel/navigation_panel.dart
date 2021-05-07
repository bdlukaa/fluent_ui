import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart' as m;

import 'display_modes/open.dart';
import 'display_modes/compact.dart';

part 'style.dart';
part 'tiles.dart';
part 'body.dart';

// TODO: NAVIGATION PANEL rework
// This need a rework to support the following topics:
// - [ ] top and left navigation. Currently it supports only left. On top navigation, the page transitions should default to Horizontal page transition
// - [ ] minimal display mode. Currently it only supports open and compact. This also require a rework on the Scaffold widget
// - [ ] open an overlay when hovering the panel when it's in compact or mininal mode
// - [ ] automatic mode. The current automatic mode is pretty simple and any deep usage can break it.
// - [ ] selected indicator. Currently only one indicator is supported (sliding horizontally)
// - [ ] pane footer. Currently, only one tile can be in the bottom, but in the offical implementation, there can be multiple tiles
// - [ ] back button. There is no back button currently. This would also require to remove the default top bar and implement a custom one
// For more info, head over to the official documentation: https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/navigationview
// Track this on github: https://github.com/bdlukaa/fluent_ui/issues/3

/// ![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-auto.png)
enum NavigationPanelDisplayMode {
  open,
  compact,
  minimal,

  /// Let the [NavigationPanel] decide what display mode should be used
  /// based on the width.
  auto,
}

class NavigationPanel extends StatefulWidget {
  const NavigationPanel({
    Key? key,
    required this.currentIndex,
    required this.items,
    this.menu,
    this.bottom,
    this.displayMode = NavigationPanelDisplayMode.auto,
    this.useAcrylic = true,
    this.appBar,
    this.body,
  }) : super(key: key);

  final int currentIndex;

  final NavigationPanelMenuItem? menu;
  final List<NavigationPanelItem> items;
  final NavigationPanelItem? bottom;

  final NavigationPanelDisplayMode displayMode;

  final bool useAcrylic;

  final Widget? appBar;
  final Widget? body;

  @override
  _NavigationPanelState createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  final scrollController = ScrollController();
  late NavigationPanelDisplayMode displayMode;

  @override
  void initState() {
    super.initState();
    displayMode = widget.displayMode;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return LayoutBuilder(builder: (context, consts) {
      NavigationPanelDisplayMode? displayMode = this.displayMode;
      if (displayMode == NavigationPanelDisplayMode.auto) {
        double width = consts.biggest.width;
        if (width.isInfinite) width = MediaQuery.of(context).size.width;
        if (width >= 680) {
          displayMode = NavigationPanelDisplayMode.open;
          // _animationController.forward();
        } else if (width >= 400) {
          displayMode = NavigationPanelDisplayMode.compact;
          // _animationController.reverse();
        } else
          displayMode = NavigationPanelDisplayMode.minimal;
      }
      late Widget panel;
      switch (displayMode) {
        case NavigationPanelDisplayMode.compact:
          panel = OpenNavigationPanel(
            scrollController: scrollController,
            useAcrylic: widget.useAcrylic,
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
          break;
        case NavigationPanelDisplayMode.open:
          panel = CompactNavigationPanel(
            scrollController: scrollController,
            useAcrylic: widget.useAcrylic,
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
          break;
        case NavigationPanelDisplayMode.minimal:
        default:
          panel = SizedBox();
          break;
      }
      panel = AnimatedContainer(
        duration: FluentTheme.of(context).fastAnimationDuration,
        curve: FluentTheme.of(context).animationCurve,
        width: displayMode != NavigationPanelDisplayMode.compact
            ? kCompactNavigationPanelWidth
            : kOpenNavigationPanelWidth,
        child: panel,
      );
      return Container(
        height: double.infinity,
        width: double.infinity,
        color: AccentColor.resolve(
          FluentTheme.of(context).scaffoldBackgroundColor,
          context,
        ),
        child: Column(children: [
          if (widget.appBar != null)
            Acrylic(
              enabled: widget.useAcrylic,
              child: widget.appBar!,
            ),
          Expanded(
            child: Row(children: [
              panel,
              Expanded(child: widget.body ?? SizedBox()),
            ]),
          ),
        ]),
      );
    });
  }
}

class NavigationPanelAppBar extends StatelessWidget {
  const NavigationPanelAppBar({
    Key? key,
    this.leading,
    this.title,
    this.remainingSpace,
  }) : super(key: key);

  final Widget? leading;

  final Widget? title;

  final Widget? remainingSpace;

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    return Acrylic(
      elevation: 0.0,
      child: Row(children: [
        if (leading != null)
          Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: leading,
          )
        else if (!canPop)
          Container(
            width: 46.0,
            child: Tooltip(
              message: 'Back',
              child: IconButton(
                icon: Icon(Icons.arrow_back_sharp),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonThemeData(
                  margin: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        if (title != null)
          Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: title!,
          ),
        if (remainingSpace != null) Expanded(child: remainingSpace!),
      ]),
    );
  }
}
