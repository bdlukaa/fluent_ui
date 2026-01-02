import 'package:fluent_ui/fluent_ui.dart';

/// The chevron down icon.
///
/// It reacts to change in the current button state and reflect them accordingly.
///
/// See also:
///
///  * [Icon], a material design icon.
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
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final states = HoverButton.maybeOf(context)?.states;

    return TweenAnimationBuilder<double>(
      duration: theme.fasterAnimationDuration,
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
            child: Transform.scale(scale: value, child: child),
          ),
        );
      },
    );
  }
}

/// A windows-styled rating icon.
///
/// The rating icon is a star icon that can be rated from 0 to 1.0.
///
/// See also:
///
///   * [RatingBar], a rating bar that uses this icon.
class RatingIcon extends StatelessWidget {
  /// Creates a rating-icon.
  const RatingIcon({
    required this.rating,
    super.key,
    this.ratedColor,
    this.unratedColor,
    this.icon = kRatingBarIcon,
    this.size,
  }) : assert(rating >= 0.0 && rating <= 1.0);

  /// The rating of the icon. Must be more or equal to 0 and less or equal than 1.0
  final double rating;

  /// The icon.
  final IconData icon;

  /// The color used by the rated part.
  ///
  /// If null, it will use the default accent color.
  final Color? ratedColor;

  /// The color used by the unrated part.
  ///
  /// If null, it will use the default control fill color secondary.
  final Color? unratedColor;

  /// The size of the icon.
  final double? size;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = FluentTheme.of(context);
    final icon = this.icon;
    final size = this.size;
    final unratedColor =
        this.unratedColor ?? style.resources.controlFillColorSecondary;
    final ratedColor =
        this.ratedColor ?? style.accentColor.defaultBrushFor(style.brightness);
    if (rating == 1.0) {
      return Icon(icon, color: ratedColor, size: size);
    } else if (rating == 0.0) {
      return Icon(icon, color: unratedColor, size: size);
    }
    return Stack(
      children: [
        Icon(icon, color: unratedColor, size: size),
        ClipRect(
          clipper: _StarClipper(rating),
          child: Icon(
            icon,
            // IconData(
            //   fontFamily: 'Segoe MDL2 Assets',
            // ),
            color: ratedColor,
            size: size,
          ),
        ),
      ],
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double value;

  _StarClipper(this.value);

  @override
  Rect getClip(Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width * value, size.height);
    return rect;
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) => oldClipper.value != value;
}
