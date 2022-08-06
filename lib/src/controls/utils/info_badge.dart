import 'package:fluent_ui/fluent_ui.dart';

/// An InfoBadge is a small piece of UI that can be added
/// into an app and customized to display a number, icon,
/// or a simple dot.
///
/// Learn more:
///
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/info-badge>
class InfoBadge extends StatelessWidget {
  /// Creates an info badge.
  const InfoBadge({
    Key? key,
    this.source,
    this.color,
    this.foregroundColor,
  }) : super(key: key);

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
          : DefaultTextStyle(
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
