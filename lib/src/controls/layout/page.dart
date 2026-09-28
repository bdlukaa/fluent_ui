import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// The default vertical padding of a [ScaffoldPage].
const double kPageDefaultVerticalPadding = 24;

/// The horizontal padding used by a page at compact widths.
const double kPageCompactHorizontalPadding = 12;

/// The horizontal padding used by a page at regular widths.
const double kPageDefaultHorizontalPadding = 24;

/// A Fluent page content shell.
///
/// [ScaffoldPage] owns the geometry of one page's content: an optional
/// [header], the flexible [content] region, and an optional [footer]. The
/// resolved page padding surrounds all three regions, so a header, body, and
/// footer always share the same content edges.
///
/// The default padding is 12 logical pixels horizontally at compact widths
/// (640 logical pixels or less) and 24 logical pixels otherwise. It is 24
/// logical pixels vertically. Supplying [padding] replaces these defaults;
/// every side of the supplied [EdgeInsetsGeometry] is applied exactly once.
///
/// [ScaffoldPage] does not make [content] scrollable. Use
/// [ScaffoldPage.scrollable] as a convenience for a page whose body is a
/// [ListView], or provide a [ListView], [CustomScrollView], or another
/// scrollable widget directly.
///
/// The page does not apply safe-area padding automatically. This keeps the
/// shell suitable for desktop and for use below [NavigationView]. Keyboard
/// view insets are applied to the page's available height when
/// [resizeToAvoidBottomInset] is true.
///
/// {@tool snippet}
/// A basic page with a header and page content:
///
/// ```dart
/// ScaffoldPage(
///   header: const PageHeader(title: Text('Settings')),
///   content: const SettingsView(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// A page with commands and a persistent footer:
///
/// ```dart
/// ScaffoldPage(
///   header: PageHeader(
///     title: const Text('Edit'),
///     commandBar: CommandBar(primaryItems: [...]),
///   ),
///   content: const EditorView(),
///   footer: const InfoBar(content: Text('Changes are saved automatically.')),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [PageHeader], a Fluent page header with title and commands
///  * [NavigationView], which provides application-level navigation and Mica
class ScaffoldPage extends StatelessWidget {
  /// Creates a page content shell.
  const ScaffoldPage({
    super.key,
    this.header,
    this.content = const SizedBox.expand(),
    this.footer,
    this.padding,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  }) : _contentHasOwnHorizontalPadding = false;

  /// Creates a page whose content is a scrollable [ListView].
  ///
  /// The list is the page body and uses the same outer page padding as the
  /// regular constructor. Header and footer remain outside the list, so they
  /// do not scroll away. Provide [padding] when the whole page needs custom
  /// insets; add padding inside a list only when it is specific to that list.
  ScaffoldPage.scrollable({
    required List<Widget> children,
    super.key,
    this.header,
    this.footer,
    this.padding,
    this.backgroundColor,
    ScrollController? scrollController,
    this.resizeToAvoidBottomInset = true,
  }) : _contentHasOwnHorizontalPadding = true,
       content = Builder(
         builder: (context) {
           return LayoutBuilder(
             builder: (context, constraints) {
               final pagePadding =
                   padding ?? _defaultPagePadding(context, constraints);
               final resolvedPadding = pagePadding.resolve(
                 Directionality.of(context),
               );
               return ListView(
                 controller: scrollController,
                 padding: EdgeInsets.only(
                   left: resolvedPadding.left,
                   right: resolvedPadding.right,
                 ),
                 children: children,
               );
             },
           );
         },
       );

  /// The primary content of the page.
  ///
  /// The content receives the flexible space between [header] and [footer].
  /// It is not implicitly scrollable.
  final Widget content;

  /// The page header, usually a [PageHeader].
  final Widget? header;

  /// Persistent content below the primary page content.
  ///
  /// This region is intended for page actions, status, wizard controls, or
  /// other page-level content. It is not application navigation; use
  /// [NavigationView] for that.
  final Widget? footer;

  /// The outer padding for the entire page content shell.
  ///
  /// The padding surrounds [header], [content], and [footer]. If null, the
  /// page uses 12 logical pixels horizontally at widths up to 640 logical
  /// pixels, 24 logical pixels horizontally at wider widths, and 24 logical
  /// pixels on the top and bottom. Directional padding is recommended for RTL
  /// layouts.
  final EdgeInsetsGeometry? padding;

  /// The background color for the page's Mica surface.
  ///
  /// When null, a standalone page uses the theme Mica background and a page
  /// below [NavigationView] is transparent so the application shell owns the
  /// backdrop. Set this explicitly when a page needs its own surface.
  final Color? backgroundColor;

  /// Whether the page should reduce its available height for the keyboard.
  ///
  /// When true, [MediaQueryData.viewInsets.bottom] is applied below the page
  /// shell, keeping the footer and page content above an onscreen keyboard.
  /// The ambient [MediaQuery] is otherwise left unchanged. Defaults to true.
  final bool resizeToAvoidBottomInset;

  final bool _contentHasOwnHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasMediaQuery(context));

    final navigationView = NavigationView.maybeOf(context);
    return Mica(
      backgroundColor:
          backgroundColor ??
          (navigationView == null ? null : Colors.transparent),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pagePadding =
              padding ?? _defaultPagePadding(context, constraints);
          final viewInsets = resizeToAvoidBottomInset
              ? MediaQuery.viewInsetsOf(context)
              : EdgeInsets.zero;

          final resolvedPadding = pagePadding.resolve(
            Directionality.of(context),
          );
          final horizontalPadding = EdgeInsets.only(
            left: resolvedPadding.left,
            right: resolvedPadding.right,
          );

          return Padding(
            padding: EdgeInsets.only(
              top: resolvedPadding.top,
              bottom: resolvedPadding.bottom + viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null)
                  Padding(padding: horizontalPadding, child: header),
                Expanded(
                  child: _contentHasOwnHorizontalPadding
                      ? content
                      : Padding(padding: horizontalPadding, child: content),
                ),
                if (footer != null)
                  Padding(padding: horizontalPadding, child: footer),
              ],
            ),
          );
        },
      ),
    );
  }

  static EdgeInsetsGeometry _defaultPagePadding(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : MediaQuery.widthOf(context);
    final horizontal = width <= 640
        ? kPageCompactHorizontalPadding
        : kPageDefaultHorizontalPadding;
    return EdgeInsetsDirectional.symmetric(
      horizontal: horizontal,
      vertical: kPageDefaultVerticalPadding,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding))
      ..add(DiagnosticsProperty<Color>('backgroundColor', backgroundColor))
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

const _pageHeaderCompactBreakpoint = 640.0;
const _pageHeaderHorizontalSpacing = 12.0;
const _pageHeaderCompactSpacing = 8.0;
const _pageHeaderBottomSpacing = 18.0;

/// The header of a Fluent page.
///
/// [PageHeader] describes the title and page-level commands. It does not
/// determine the outer page margins; [ScaffoldPage] supplies those margins so
/// custom headers and page content share one geometry contract.
///
/// The [commandBar] may be any widget, although [CommandBar] is the usual
/// choice. At regular widths, the title and actions share a row. At compact
/// widths, actions move below the title and align to the logical end of the
/// page. This gives the title room to wrap without making assumptions about
/// the width or implementation of the action widget.
///
/// See also:
///
///  * [ScaffoldPage], which places the header in the page shell
///  * [CommandBar], for Fluent page actions
class PageHeader extends StatelessWidget {
  /// Creates a page header.
  const PageHeader({super.key, this.leading, this.title, this.commandBar});

  /// The widget displayed before the [title].
  final Widget? leading;

  /// The title of the page.
  final Widget? title;

  /// The page actions, usually a [CommandBar].
  final Widget? commandBar;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasMediaQuery(context));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.widthOf(context);
        return Padding(
          padding: const EdgeInsetsDirectional.only(
            bottom: _pageHeaderBottomSpacing,
          ),
          child: _PageHeaderLayout(
            leading: leading,
            title: title,
            commandBar: commandBar,
            compact: width <= _pageHeaderCompactBreakpoint,
          ),
        );
      },
    );
  }
}

class _PageHeaderLayout extends StatelessWidget {
  const _PageHeaderLayout({
    required this.leading,
    required this.title,
    required this.commandBar,
    required this.compact,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? commandBar;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final titleWidget = DefaultTextStyle.merge(
      style: theme.typography.title,
      child: title ?? const SizedBox(),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _pageHeaderCompactSpacing,
        children: [
          _TitleRow(leading: leading, title: titleWidget),
          if (commandBar != null)
            Align(alignment: AlignmentDirectional.centerEnd, child: commandBar),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: _pageHeaderHorizontalSpacing,
      children: [
        ?leading,
        Expanded(child: titleWidget),
        if (commandBar != null)
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: commandBar,
            ),
          ),
      ],
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.leading, required this.title});

  final Widget? leading;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: _pageHeaderHorizontalSpacing,
      children: [
        ?leading,
        Expanded(child: title),
      ],
    );
  }
}
