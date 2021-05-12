import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

part 'body.dart';
part 'pane.dart';
part 'style.dart';

/// The NavigationView control provides top-level navigation
/// for your app. It adapts to a variety of screen sizes and
/// supports both top and left navigation styles.
///
/// ![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/nav-view-header.png)
///
/// See also:
///   * [NavigationBody], a widget that implement fluent
///     transitions into [NavigationView]
///   * [NavigationPane], the pane used by [NavigationView],
///     that can be displayed either at the left and top
///   * [TabView], a widget similar to [NavigationView], useful
///     to display several pages of content while giving a user
///     the capability to rearrange, open, or close new tabs.
class NavigationView extends StatefulWidget {
  /// Creates a navigation view.
  const NavigationView({
    Key? key,
    this.appBar,
    this.pane,
    this.content = const SizedBox.shrink(),
    // If more properties are added here, make sure to
    // add them to the automatic mode as well.
  }) : super(key: key);

  /// The top app bar.
  final NavigationAppBar? appBar;

  /// The navigation pane, that can be displayed either on the
  /// left, on the top, or above [content].
  final NavigationPane? pane;

  /// The content of the pane.
  ///
  /// Usually an [NavigationBody].
  final Widget content;

  @override
  NavigationViewState createState() => NavigationViewState();
}

class NavigationViewState extends State<NavigationView> {
  /// The current display mode used by the automatic pane mode.
  /// This can not be changed
  PaneDisplayMode? currentDisplayMode;

  @override
  Widget build(BuildContext context) {
    Widget appBar = () {
      if (widget.appBar != null)
        return _NavigationAppBar(
          appBar: widget.appBar!,
          displayMode: widget.pane?.displayMode ?? PaneDisplayMode.top,
        );
      return SizedBox.shrink();
    }();

    late Widget paneResult;
    if (widget.pane != null) {
      final pane = widget.pane!;
      if (pane.displayMode == PaneDisplayMode.top) {
        paneResult = Column(children: [
          appBar,
          _TopNavigationPane(pane: pane),
          Expanded(child: widget.content),
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

            /// We display a new navigation view with the [currentDisplayMode].
            /// We can do this because [currentDisplayMode] can never be `auto`,
            /// so it won't stack overflow (error).
            return NavigationView(
              appBar: widget.appBar,
              content: widget.content,
              pane: NavigationPane(
                displayMode: currentDisplayMode!,
                autoSuggestBox: pane.autoSuggestBox,
                autoSuggestBoxReplacement: pane.autoSuggestBoxReplacement,
                footerItems: pane.footerItems,
                header: pane.header,
                items: pane.items,
                key: pane.key,
                onChanged: pane.onChanged,
                selected: pane.selected,
              ),
            );
          },
        );
      } else {
        switch (pane.displayMode) {
          case PaneDisplayMode.compact:
            paneResult = Column(children: [
              appBar,
              Expanded(
                child: Row(children: [
                  _CompactNavigationPane(pane: pane),
                  Expanded(child: widget.content),
                ]),
              ),
            ]);
            break;
          case PaneDisplayMode.open:
            paneResult = Column(children: [
              appBar,
              Expanded(
                child: Row(children: [
                  _OpenNavigationPane(pane: pane),
                  Expanded(child: widget.content),
                ]),
              ),
            ]);
            break;
          case PaneDisplayMode.minimal:
            assert(debugCheckHasOverlay(context));
            paneResult = Column(children: [
              appBar,
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
                  child: widget.content,
                ),
              ),
            ]);
            break;
          default:
            paneResult = widget.content;
        }
      }
    } else {
      paneResult = widget.content;
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

/// The bar displayed at the top of the app. It can adapt itself to
/// all the display modes.
///
/// See also:
///   - [NavigationView]
///   - [NavigationPane]
///   - [PaneDisplayMode]
class NavigationAppBar {
  final Key? key;

  /// The widget at the beggining of the app bar.
  final Widget? leading;

  /// Whether if [leading], if null, can be autoamtically set based on
  /// the current [BuildContext].
  final bool automaticallyImplyLeading;

  /// The app title
  final Widget? title;

  /// The actions of the app
  final Widget? actions;

  const NavigationAppBar({
    this.key,
    this.leading,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });
}

class _NavigationAppBar extends StatelessWidget {
  const _NavigationAppBar({
    Key? key,
    required this.appBar,
    required this.displayMode,
  }) : super(key: key);

  final NavigationAppBar appBar;
  final PaneDisplayMode displayMode;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneThemeData.of(context);
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    final leading = () {
      late Widget widget;
      if (appBar.leading != null)
        widget = Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: appBar.leading,
        );
      else if (appBar.automaticallyImplyLeading)
        widget = Container(
          width: _kCompactNavigationPanelWidth,
          child: Tooltip(
            message: 'Back',
            child: IconButton(
              icon: Icon(Icons.arrow_back_sharp),
              onPressed: canPop ? () => Navigator.pop(context) : null,
              style: ButtonThemeData(
                margin: EdgeInsets.zero,
                scaleFactor: 1.0,
              ),
            ),
          ),
        );
      else
        return SizedBox.shrink();
      widget = SizedBox(width: _kCompactNavigationPanelWidth, child: widget);
      return widget;
    }();
    final title = () {
      if (appBar.title != null)
        return AnimatedPadding(
          duration: theme.animationDuration ?? Duration.zero,
          curve: theme.animationCurve ?? Curves.linear,
          padding: EdgeInsets.only(
            left: displayMode == PaneDisplayMode.compact
                ? PageTopBar.horizontalPadding(context)
                : 12.0,
          ),
          child: DefaultTextStyle(
            style: FluentTheme.of(context).typography.caption!,
            child: appBar.title!,
          ),
        );
      else
        return SizedBox.shrink();
    }();
    switch (displayMode) {
      case PaneDisplayMode.top:
        return Acrylic(
          height: 30.0,
          enabled: false,
          opacity: 1.0,
          child: Row(children: [
            leading,
            title,
            if (appBar.actions != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: appBar.actions!,
                ),
              ),
          ]),
        );
      case PaneDisplayMode.open:
        return Row(children: [
          Acrylic(
            enabled: false,
            height: 30.0,
            width: _kOpenNavigationPanelWidth,
            color: theme.backgroundColor,
            child: Row(children: [
              leading,
              title,
            ]),
          ),
          Expanded(child: appBar.actions ?? SizedBox()),
        ]);
      case PaneDisplayMode.compact:
        return Row(children: [
          Acrylic(
            enabled: false,
            height: 30.0,
            color: theme.backgroundColor,
            child: leading,
          ),
          title,
          Expanded(child: appBar.actions ?? SizedBox()),
        ]);
      default:
        return Container();
    }
    return Container();
  }
}
