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
  });

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
  }) : content = ListView(
         controller: scrollController,
         padding: EdgeInsets.zero,
         children: children,
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

          return Padding(
            padding: pagePadding,
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: viewInsets.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ?header,
                  Expanded(child: content),
                  ?footer,
                ],
              ),
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

/// The header of a Fluent page.
///
/// [PageHeader] describes the title and page-level commands. It does not
/// determine the outer page margins; [ScaffoldPage] supplies those margins so
/// custom headers and page content share one geometry contract.
///
/// The [commandBar] may be any widget, although [CommandBar] is the usual
/// choice. At narrow widths the title and commands receive flexible
/// constraints rather than a fixed minimum command width, allowing controls
/// such as [CommandBar] to apply their own overflow behavior.
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
    final theme = FluentTheme.of(context);
    final row = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: DefaultTextStyle.merge(
            style: theme.typography.title,
            maxLines: 2,
            child: title ?? const SizedBox(),
          ),
        ),
        if (commandBar != null) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: commandBar,
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 18),
      child: row,
    );
  }
}
