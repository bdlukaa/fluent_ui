import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

part 'body.dart';
part 'pane.dart';
part 'style.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({Key? key, this.pane, this.content}) : super(key: key);

  final NavigationPane? pane;

  final Widget? content;

  @override
  _NavigationViewState createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  PaneDisplayMode? currentDisplayMode;

  @override
  Widget build(BuildContext context) {
    late Widget paneResult;
    if (widget.pane != null) {
      final pane = widget.pane!;
      if (pane.displayMode == PaneDisplayMode.top) {
        paneResult = Column(children: [
          _TopNavigationPane(pane: pane),
          if (widget.content != null) Expanded(child: widget.content!),
        ]);
      } else if (pane.displayMode == PaneDisplayMode.auto) {
        /// For more info on the adaptive behavior, see
        /// https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/navigationview#adaptive-behavior
        ///
        /// (07/05/2021)
        ///
        /// When PaneDisplayMode is set to its default value of Auto, the adaptive behavior is to show:
        /// - An expanded left pane on large window widths (1008px or greater).
        /// - A left, icon-only, nav pane (compact) on medium window widths (641px to 1007px).
        /// - Only a menu button (minimal) on small window widths (640px or less).
        return LayoutBuilder(
          builder: (context, consts) {
            double width = consts.biggest.width;
            if (width.isInfinite) width = MediaQuery.of(context).size.width;
            if (width >= 1008) {
              currentDisplayMode = PaneDisplayMode.open;
            } else if (width > 640) {
              currentDisplayMode = PaneDisplayMode.compact;
            } else {
              currentDisplayMode = PaneDisplayMode.minimal;
            }
            return SizedBox();
          },
        );
      } else {
        switch (pane.displayMode) {
          case PaneDisplayMode.compact:
            paneResult = Column(children: [
              if (pane.appBar != null) pane.appBar!,
              Expanded(
                child: Row(children: [
                  _CompactNavigationPane(pane: pane),
                  if (widget.content != null) Expanded(child: widget.content!),
                ]),
              ),
            ]);
            break;
          case PaneDisplayMode.open:
            paneResult = Column(children: [
              if (pane.appBar != null) pane.appBar!,
              Expanded(
                child: Row(children: [
                  _OpenNavigationPane(pane: pane),
                  if (widget.content != null) Expanded(child: widget.content!),
                ]),
              ),
            ]);
            break;
          case PaneDisplayMode.minimal:
            assert(debugCheckHasOverlay(context));
            paneResult = Column(children: [
              if (pane.appBar != null) pane.appBar!,
              Expanded(
                child: ScaffoldPageParent(
                  paneButton: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: PaneItem.buildPaneItemButton(
                      context,
                      PaneItem(
                        title: 'Open Navigation',
                        icon: Icon(Icons.menu),
                      ),
                      PaneDisplayMode.compact,
                      false,
                      () {
                        // TODO: open minimal overlay
                      },
                    ),
                  ),
                  child: widget.content!,
                ),
              ),
            ]);
            break;
          default:
            paneResult = SizedBox.shrink(child: widget.content!);
        }
      }
    } else {
      paneResult = SizedBox.shrink(child: widget.content!);
    }
    return Container(
      color: FluentTheme.of(context).scaffoldBackgroundColor,
      child: _NavigationBody(
        displayMode: widget.pane?.displayMode,
        child: paneResult,
      ),
    );
  }
}
