import 'package:fluent_ui/fluent_ui.dart';

const double kPageDefaultVerticalPadding = 24.0;

/// Creates a page that follows fluent-ui design guidelines. Usually used
/// alongside [Scaffold] and [NavigationPanelBody].
class ScaffoldPage extends StatelessWidget {
  /// Creates a new scaffold page.
  const ScaffoldPage({
    Key? key,
    this.topBar,
    this.content = const SizedBox.expand(),
    this.bottomBar,
    this.contentScrollController,
  }) : super(key: key);

  /// The content of this page.
  final Widget content;

  /// The top bar of this page. Usually a [PageTopBar]
  final Widget? topBar;

  /// The bottom bar of this page. This is usually provided when the current
  /// screen is too small.
  final Widget? bottomBar;

  /// The scroll controller used by the [Scrollbar] implemented by this widget.
  /// If null, no scrollbar will be added.
  final ScrollController? contentScrollController;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 640.0;
    final double horizontalPadding =
        isSmallScreen ? 12.0 : kPageDefaultVerticalPadding;
    return Container(
      margin: EdgeInsets.only(top: kPageDefaultVerticalPadding),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (topBar != null) topBar!,
        Expanded(child: () {
          final finalContent = Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: bottomBar,
          ),
      ]),
    );
  }
}

class PageTopBar extends StatelessWidget {
  const PageTopBar({
    Key? key,
    this.leading,
    this.header,
    this.commandBar,
  }) : super(key: key);

  /// The widget displayed before [header]. If null, some widget
  /// can be inserted here implicitly. To avoid this, set this
  /// property to [SizedBox.shrink()].
  final Widget? leading;

  /// The header of this bar.
  ///
  /// Usually a [Text] widget.
  final Widget? header;

  /// A bar with a list of actions an user can take
  final Widget? commandBar;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final pageParent = ScaffoldPageParent.maybeOf(context);
    final leading = this.leading ?? pageParent?.paneButton;

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 640.0;
    final double horizontalPadding =
        isSmallScreen ? 12.0 : kPageDefaultVerticalPadding;

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
            child: header ?? SizedBox(),
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

  /// The button used by [PageTopBar], displayed before [PageTopBar.header].
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
