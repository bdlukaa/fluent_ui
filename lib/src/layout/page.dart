import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// The default vertical padding of the scaffold page
///
/// Eyeballed from Windows 10
const double kPageDefaultVerticalPadding = 24.0;

/// Creates a page that follows fluent-ui design guidelines.
///
/// See also:
///
///   * [PageHeader], usually used on the [header] property
class ScaffoldPage extends StatelessWidget {
  /// Creates a new scaffold page.
  const ScaffoldPage({
    Key? key,
    this.header,
    this.content = const SizedBox.expand(),
    this.bottomBar,
    this.padding,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  /// Creates a scrollable page
  ///
  /// The default horizontal and vertical padding is added automatically
  ScaffoldPage.scrollable({
    Key? key,
    this.header,
    this.bottomBar,
    this.padding,
    ScrollController? scrollController,
    required List<Widget> children,
    this.resizeToAvoidBottomInset = true,
  })  : content = Builder(builder: (context) {
          return ListView(
            controller: scrollController,
            padding: EdgeInsets.only(
              bottom: kPageDefaultVerticalPadding,
              left: PageHeader.horizontalPadding(context),
              right: PageHeader.horizontalPadding(context),
            ),
            children: children,
          );
        }),
        super(key: key);

  /// Creates a page with padding applied to [content]
  ScaffoldPage.withPadding({
    Key? key,
    this.header,
    this.bottomBar,
    this.padding,
    required Widget content,
    this.resizeToAvoidBottomInset = true,
  })  : content = Builder(builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: kPageDefaultVerticalPadding,
              left: PageHeader.horizontalPadding(context),
              right: PageHeader.horizontalPadding(context),
            ),
            child: content,
          );
        }),
        super(key: key);

  /// The content of this page. The content area is where most of the information
  /// for the selected nav category is displayed.
  ///
  /// ![Content Example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/nav-content.png)
  final Widget content;

  /// The header of this page. Usually a [PageHeader] is used.
  ///
  /// ![Header example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/nav-header.png)
  final Widget? header;

  /// The bottom bar of this page. This is usually provided when the current
  /// screen is small.
  ///
  /// Usually a [BottomNavigation]
  final Widget? bottomBar;

  /// The padding used by this widget.
  ///
  /// If null, [PageHeader.horizontalPadding] is used horizontally and
  /// [kPageDefaultVerticalPadding] is used vertically
  final EdgeInsets? padding;

  /// If true the body and the scaffold's floating widgets should size
  /// themselves to avoid the onscreen keyboard whose height is defined by the
  /// ambient MediaQuery's [MediaQueryData.viewInsets] bottom property.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true.
  final bool resizeToAvoidBottomInset;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty(
        'padding',
        padding,
        defaultValue: kPageDefaultVerticalPadding,
      ))
      ..add(FlagProperty(
        'resizeToAvoidBottomInset',
        value: resizeToAvoidBottomInset,
        defaultValue: true,
        ifFalse: 'do not resize',
      ));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasMediaQuery(context));

    final mediaQuery = MediaQuery.of(context);
    final theme = FluentTheme.of(context);
    final view = InheritedNavigationView.maybeOf(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: resizeToAvoidBottomInset ? mediaQuery.viewInsets.bottom : 0.0,
      ),
      child: Column(children: [
        Expanded(
          child: Container(
            // we only show the scaffold background color if a [NavigationView] is
            // not a parent widget of this page. this happens because, if a navigation
            // view is not used, the page would be uncolored.
            color: view == null ? theme.scaffoldBackgroundColor : null,
            padding: EdgeInsets.only(
              top: padding?.top ?? kPageDefaultVerticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (header != null) header!,
                Expanded(child: content),
              ],
            ),
          ),
        ),
        if (bottomBar != null) bottomBar!,
      ]),
    );
  }
}

/// The header of a page
///
/// See also:
///
///   * [ScaffoldPage], which creates a page that follows fluent-ui design guidelines.
///   * [Typography.title], which is the default style used by the header
///   * [CommandBar], which provide quick access to common tasks on the page
class PageHeader extends StatelessWidget {
  /// Creates a page header.
  const PageHeader({
    Key? key,
    this.leading,
    this.title,
    this.commandBar,
    this.padding,
  }) : super(key: key);

  /// The widget displayed before the [title]
  ///
  /// Usually an [Icon] widget.
  final Widget? leading;

  /// The title of this bar.
  ///
  /// ![Header Example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/nav-header.png)
  ///
  /// Usually a [Text] widget.
  final Widget? title;

  /// A bar with a list of actions an user can take
  ///
  /// Usually a [CommandBar] widget.
  final Widget? commandBar;

  /// The horizontal padding applied to both sides of the page
  final double? padding;

  /// Gets the horizontal padding applied to the header based on the screen width
  static double horizontalPadding(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 640.0;
    final double horizontalPadding =
        isSmallScreen ? 12.0 : kPageDefaultVerticalPadding;
    return horizontalPadding;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    final theme = FluentTheme.of(context);
    final horizontalPadding = padding ?? PageHeader.horizontalPadding(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: 18.0,
        left: leading != null ? 0 : horizontalPadding,
        right: horizontalPadding,
      ),
      child: Row(children: [
        if (leading != null) leading!,
        Expanded(
          child: DefaultTextStyle(
            style: theme.typography.title!,
            child: title ?? const SizedBox(),
          ),
        ),
        if (commandBar != null) commandBar!,
      ]),
    );
  }
}
