import 'package:fluent_ui/fluent_ui.dart';

typedef InfoBadgeSeverity = InfoBarSeverity;

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
    this.severity = InfoBarSeverity.info,
  });

  /// Creates an attention info badge.
  ///
  /// Uses the default accent color to draw attention to important content.
  const InfoBadge.attention({super.key, this.source, this.foregroundColor})
    : severity = InfoBarSeverity.warning,
      color = null;

  /// Creates an informational info badge.
  ///
  /// Uses the default accent color to indicate informational content.
  const InfoBadge.informational({super.key, this.source, this.foregroundColor})
    : severity = InfoBarSeverity.info,
      color = null;

  /// Creates a success info badge.
  ///
  /// Uses the success color to indicate successful completion or positive status.
  const InfoBadge.success({super.key, this.source, this.foregroundColor})
    : severity = InfoBarSeverity.success,
      color = null;

  /// Creates a critical info badge.
  ///
  /// Uses the error color to indicate critical issues or errors.
  const InfoBadge.critical({super.key, this.source, this.foregroundColor})
    : severity = InfoBarSeverity.error,
      color = null;

  /// The source of the badge.
  ///
  /// Usually a [Text] or an [Icon]
  final Widget? source;

  /// The background color of the badge. If not provided, the color will
  /// be decided based on the [severity].
  final Color? color;

  /// The foreground color.
  final Color? foregroundColor;

  /// The severity of the badge.
  final InfoBadgeSeverity severity;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    final theme = FluentTheme.of(context);
    final color =
        this.color ??
        switch (severity) {
          InfoBarSeverity.info => theme.accentColor.defaultBrushFor(
            theme.brightness,
          ),
          InfoBarSeverity.warning =>
            theme.resources.systemFillColorSolidAttentionBackground,
          InfoBarSeverity.success => theme.resources.systemFillColorSuccess,
          InfoBarSeverity.error => theme.resources.systemFillColorCritical,
        };
    final foregroundColor =
        this.foregroundColor ?? theme.resources.textOnAccentFillColorPrimary;

    if (source == null) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
        maxHeight: 16,
      ),
      padding: const EdgeInsetsDirectional.only(start: 4, end: 4, bottom: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        style: TextStyle(color: foregroundColor, fontSize: 11),
        child: IconTheme.merge(
          data: IconThemeData(color: foregroundColor, size: 12),
          child: source!,
        ),
      ),
    );
  }
}
