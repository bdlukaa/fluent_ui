import 'package:fluent_ui/fluent_ui.dart';

/// The default vertical padding of the scaffold page
///
/// Eyeballed from Windows 10
const double kPageDefaultVerticalPadding = 24.0;

/// Creates a page that follows fluent-ui design guidelines.
///
/// See also:
///   * [PageHeader], usually used on the [header] property
///   * [NavigationBody], the widget that implements fluent page transitions
///     into navigation view.
///   * [ScaffoldPageParent], used by [NavigationView] to tell `ScaffoldPage`
///     if a button is necessary to be displayed before [title]
class ScaffoldPage extends StatelessWidget {
  /// Creates a new scaffold page.
  const ScaffoldPage({
    Key? key,
    this.header,
    this.content = const SizedBox.expand(),
    this.bottomBar,
    this.contentScrollController,
    this.padding,
  }) : super(key: key);

  /// The content of this page. The content area is where most of the information
  /// for the selected nav category is displayed.
  ///
  /// If this widget is scrollable, you may want to provide [contentScrollController]
  /// as well, to add a scrollbar to the right of the page.
  ///
  /// ![Content Example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/nav-content.png)
  final Widget content;

  /// The header of this page. Usually a [PageHeader] is used.
  ///
  /// ![Header example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/nav-header.png)
  final Widget? header;

  /// The bottom bar of this page. This is usually provided when the current
  /// screen is small.
  final Widget? bottomBar;

  /// The scroll controller used by the [Scrollbar] implemented by this widget.
  /// If null, no scrollbar will be added.
  final ScrollController? contentScrollController;

  /// The padding used by this widget.
  ///
  /// If [contentScrollController] is not null, the scrollbar is rendered over
  /// this padding
  ///
  /// If null, [PageHeader.horizontalPadding] is used horizontally and
  /// [kPageDefaultVerticalPadding] is used vertically
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final horizontalPadding = EdgeInsets.only(
      left: padding?.left ?? PageHeader.horizontalPadding(context),
      right: padding?.right ?? PageHeader.horizontalPadding(context),
    );
    return AnimatedContainer(
      duration: theme.fastAnimationDuration,
      curve: theme.animationCurve,
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        top: padding?.top ?? kPageDefaultVerticalPadding,
        bottom: padding?.bottom ?? kPageDefaultVerticalPadding,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (header != null) header!,
        Expanded(child: () {
          final finalContent = Padding(
            padding: horizontalPadding,
            child: content,
          );
          if (contentScrollController != null) {
            return Scrollbar(
              controller: contentScrollController,
              child: finalContent,
            );
          }
          return finalContent;
        }()),
        if (bottomBar != null)
          Padding(padding: horizontalPadding, child: bottomBar),
      ]),
    );
  }
}

class PageHeader extends StatelessWidget {
  /// Creates a page header.
  const PageHeader({
    Key? key,
    this.leading,
    this.title,
    this.commandBar,
  }) : super(key: key);

  /// The widget displayed before [title]. If null, some widget
  /// can be inserted here implicitly. To avoid this, set this
  /// property to `SizedBox.shrink()`.
  final Widget? leading;

  /// The title of this bar.
  ///
  /// Usually a [Text] widget.
  ///
  /// ![Header Example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/nav-header.png)
  final Widget? title;

  /// A bar with a list of actions an user can take
  final Widget? commandBar;

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
    final pageParent = ScaffoldPageParent.maybeOf(context);
    final leading = this.leading ?? pageParent?.paneButton;
    final horizontalPadding = PageHeader.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: 18.0,
        left: leading != null ? 0 : horizontalPadding,
        right: horizontalPadding,
      ),
      child: Row(children: [
        if (leading != null) leading,
        Expanded(
          child: DefaultTextStyle(
            style: FluentTheme.of(context).typography.subheader!,
            child: title ?? SizedBox(),
          ),
        ),
        if (commandBar != null) commandBar!,
      ]),
    );
  }
}

class ScaffoldPageParent extends InheritedWidget {
  const ScaffoldPageParent({
    Key? key,
    required this.child,
    this.paneButton,
  }) : super(key: key, child: child);

  final Widget child;

  /// The button used by [PageHeader], displayed before [PageHeader.header].
  /// It can be overritten
  final Widget? paneButton;

  static ScaffoldPageParent? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ScaffoldPageParent>();
  }

  @override
  bool updateShouldNotify(ScaffoldPageParent oldWidget) {
    return true;
  }
}
