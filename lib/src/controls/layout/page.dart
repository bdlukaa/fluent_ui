import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// The default vertical padding of the scaffold page.
const double kPageDefaultVerticalPadding = 24;

/// A page layout that follows Windows Fluent Design guidelines.
///
/// [ScaffoldPage] provides a consistent page structure with an optional
/// header, content area, and bottom bar. It handles padding and layout
/// automatically while being customizable.
///
/// ![ScaffoldPage content area](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/nav-content.png)
///
/// {@tool snippet}
/// This example shows a basic scaffold page:
///
/// ```dart
/// ScaffoldPage(
///   header: PageHeader(title: Text('Settings')),
///   content: Center(child: Text('Page content')),
/// )
/// ```
/// {@end-tool}
///
/// ## Page variants
///
/// * [ScaffoldPage.scrollable] - Content is placed in a scrollable [ListView]
/// * [ScaffoldPage.withPadding] - Content has horizontal and vertical padding
///
/// See also:
///
///  * [PageHeader], typically used for the [header] property
///  * [NavigationView], for app-level navigation structure
class ScaffoldPage extends StatefulWidget {
  /// Creates a new scaffold page.
  const ScaffoldPage({
    super.key,
    this.header,
    this.content = const SizedBox.expand(),
    this.bottomBar,
    this.padding,
    this.resizeToAvoidBottomInset = true,
  });

  /// Creates a scrollable page
  ///
  /// The default horizontal and vertical padding is added automatically
  ScaffoldPage.scrollable({
    required List<Widget> children,
    super.key,
    this.header,
    this.bottomBar,
    this.padding,
    ScrollController? scrollController,
    this.resizeToAvoidBottomInset = true,
  }) : content = Builder(
         builder: (context) {
           return ListView(
             controller: scrollController,
             padding:
                 padding ??
                 EdgeInsetsDirectional.only(
                   bottom: kPageDefaultVerticalPadding,
                   start: PageHeader.horizontalPadding(context),
                   end: PageHeader.horizontalPadding(context),
                 ),
             children: children,
           );
         },
       );

  /// Creates a page with padding applied to [content]
  ScaffoldPage.withPadding({
    required Widget content,
    super.key,
    this.header,
    this.bottomBar,
    this.padding,
    this.resizeToAvoidBottomInset = true,
  }) : content = Builder(
         builder: (context) {
           return Padding(
             padding:
                 padding ??
                 EdgeInsetsDirectional.only(
                   bottom: kPageDefaultVerticalPadding,
                   start: PageHeader.horizontalPadding(context),
                   end: PageHeader.horizontalPadding(context),
                 ),
             child: content,
           );
         },
       );

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
  State<ScaffoldPage> createState() => _ScaffoldPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty(
          'padding',
          padding,
          defaultValue: kPageDefaultVerticalPadding,
        ),
      )
      ..add(
        FlagProperty(
          'resizeToAvoidBottomInset',
          value: resizeToAvoidBottomInset,
          defaultValue: true,
          ifFalse: 'do not resize',
        ),
      );
  }
}

class _ScaffoldPageState extends State<ScaffoldPage> {
  final _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasMediaQuery(context));

    final theme = FluentTheme.of(context);
    final view = NavigationView.maybeOf(context);

    return Mica(
      backgroundColor: view != null ? Colors.transparent : null,
      child: PageStorage(
        bucket: _bucket,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: widget.resizeToAvoidBottomInset
                ? MediaQuery.viewInsetsOf(context).bottom
                : 0.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  // we only show the scaffold background color if a [NavigationView] is
                  // not a parent widget of this page. this happens because, if a navigation
                  // view is not used, the page would be uncolored.
                  color: view == null ? theme.scaffoldBackgroundColor : null,
                  padding: widget.padding == null
                      ? const EdgeInsetsDirectional.only(
                          top: kPageDefaultVerticalPadding,
                        )
                      : EdgeInsetsDirectional.only(top: widget.padding!.top),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.header != null) widget.header!,
                      Expanded(child: widget.content),
                    ],
                  ),
                ),
              ),
              if (widget.bottomBar != null) widget.bottomBar!,
            ],
          ),
        ),
      ),
    );
  }
}

/// The header of a page.
///
/// See also:
///
///   * [ScaffoldPage], which creates a page that follows Windows-ui design
///                     guidelines.
///   * [Typography.title], which is the default style used by the header
///   * [CommandBar], which provide quick access to common tasks on the page
class PageHeader extends StatelessWidget {
  /// Creates a page header.
  const PageHeader({
    super.key,
    this.leading,
    this.title,
    this.commandBar,
    this.padding,
  });

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
  ///
  /// If not provided, the padding is calculated using the [horizontalPadding]
  /// function, which gets the padding based on the screen width.
  final double? padding;

  /// Gets the horizontal padding applied to the header based on the screen
  /// width.
  ///
  /// If the screen is small, the padding is 12.0, otherwise it defaults to
  /// [kPageDefaultVerticalPadding]
  static double horizontalPadding(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 640.0;
    final horizontalPadding = isSmallScreen
        ? 12.0
        : kPageDefaultVerticalPadding;
    return horizontalPadding;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final horizontalPadding = padding ?? PageHeader.horizontalPadding(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: 18,
        start: leading != null ? 0 : horizontalPadding,
      ),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(
            child: DefaultTextStyle.merge(
              style: theme.typography.title,
              child: title ?? const SizedBox(),
            ),
          ),
          SizedBox(width: horizontalPadding),
          if (commandBar != null) ...[
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: commandBar,
                ),
              ),
            ),
            SizedBox(width: horizontalPadding),
          ],
        ],
      ),
    );
  }
}
