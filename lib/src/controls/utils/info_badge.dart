import 'package:fluent_ui/fluent_ui.dart';

/// Badging is a non-intrusive and intuitive way to display notifications or
/// bring focus to an area within an app - whether that be for notifications,
/// indicating new content, or showing an alert. An `InfoBadge` is a small
/// piece of UI that can be added into an app and customized to display a number,
/// icon, or a simple dot.
///
/// ![InfoBadge Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/infobadge/infobadge-example-1.png)
///
/// [InfoBadge] is built into [NavigationView], but can also be placed as a
/// standalone widget, allowing you to place [InfoBadge] into any control or
/// piece of UI of your choosing. When you use an [InfoBadge] somewhere other
/// than [NavigationView], you are responsible for programmatically determining
/// when to show and dismiss the [InfoBadge], and where to place the [InfoBadge].
///
/// Learn more:
///
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/info-badge>
///  * [NavigationView], which provides top-level navigation for your app
class InfoBadge extends StatelessWidget {
  /// Creates an info badge.
  const InfoBadge({
    super.key,
    this.source,
    this.color,
    this.foregroundColor,
  });

  /// The source of the badge.
  ///
  /// Usually a [Text] or an [Icon]
  final Widget? source;

  /// The background color of the badge. If null, the current
  /// [FluentTheme.accentColor] is used
  ///
  /// Some other used colors are:
  ///
  ///  * [Colors.errorPrimaryColor]
  ///  * [Colors.successPrimaryColor]
  ///  * [Colors.warningPrimaryColor]
  final Color? color;

  /// The foreground color.
  ///
  /// Applied to [Text]s and [Icon]s
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    final theme = FluentTheme.of(context);
    final color =
        this.color ?? theme.accentColor.defaultBrushFor(theme.brightness);
    final foregroundColor =
        this.foregroundColor ?? theme.resources.textOnAccentFillColorPrimary;

    return Container(
      constraints: source == null
          ? const BoxConstraints(
              maxWidth: 10.0,
              maxHeight: 10.0,
            )
          : const BoxConstraints(
              minWidth: 16.0,
              minHeight: 16.0,
              maxHeight: 16.0,
            ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: source == null
          ? null
          : DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 11.0,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: foregroundColor,
                  size: 8.0,
                ),
                child: source!,
              ),
            ),
    );
  }
}
