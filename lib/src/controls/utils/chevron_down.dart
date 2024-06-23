import 'package:fluent_ui/fluent_ui.dart';

/// The chevron down icon.
///
/// It reacts to change in the current button state and reflect them accordingly
class ChevronDown extends StatelessWidget {
  /// The icon size
  final double iconSize;

  /// The icon to be displayed
  final IconData icon;

  /// The color of the icon
  final Color? iconColor;

  /// Creates a chevron down icon.
  const ChevronDown({
    super.key,
    this.iconSize = 8.0,
    this.icon = FluentIcons.chevron_down,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final states = HoverButton.maybeOf(context)?.states;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 50),
      curve: Curves.ease,
      tween: Tween(
        begin: 1,
        end: states == null || !states.isPressed ? 1 : 0.9,
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            filterQuality: FilterQuality.high,
            offset: Offset(0, value == 1 ? 0 : value * 1),
            child: Transform.scale(
              scale: value,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
