import 'package:fluent_ui/fluent_ui.dart';

/// A teaching tip is a semi-persistent and content-rich flyout that provides
/// contextual information. It is often used for informing, reminding, and
/// teaching users about important and new features that may enhance their
/// experience.
///
/// A teaching tip may be light-dismiss or require explicit action to close. A
/// teaching tip can target a specific UI element with its tail and also be used
/// without a tail or target.
///
/// See also:
///
///  * [ContentDialog], modal UI overlays that provide contextual app information.
///  * [Tooltip], a popup that contains additional information about another object.
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/dialogs-and-flyouts/teaching-tip>
class TeachingTip extends StatelessWidget {
  /// Creates a teaching tip
  const TeachingTip({
    Key? key,
    this.alignment = Alignment.center,
    required this.title,
    required this.subtitle,
    this.buttons = const [],
  }) : super(key: key);

  /// Where the teaching tip should be displayed
  final Alignment alignment;

  /// The title of the teaching tip
  ///
  /// Usually a [Text]
  final Widget title;

  /// The subttile of the teaching tip
  ///
  /// Usually a [Text]
  final Widget subtitle;

  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 40.0,
        maxHeight: 520.0,
        minWidth: 320.0,
        maxWidth: 336.0,
      ),
      child: Acrylic(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(
            color: theme.resources.surfaceStrokeColorDefault,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: theme.typography.bodyStrong ?? const TextStyle(),
                child: title,
              ),
              subtitle,
              if (buttons.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: List.generate(buttons.length, (index) {
                      final isLast = buttons.length - 1 == index;
                      final button = buttons[index];
                      if (isLast) return Expanded(child: button);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6.0),
                          child: button,
                        ),
                      );
                    }),
                    // children: buttons.map((button) {
                    //   return Expanded(child: button);
                    // }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
