import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_icons/fluentui_icons.dart';

class RatingBar extends StatelessWidget {
  const RatingBar({
    Key key,
    @required this.rating,
    this.onChanged,
    this.amount = 5,
    this.animationDuration,
    this.animationCurve,
    this.icon,
    this.iconSize,
    this.ratedIconColor,
    this.unratedIconColor,
    // TODO: starSpacing
  })  : assert(rating != null),
        assert(amount != null),
        assert(rating <= amount && rating <= amount),
        super(key: key);

  final int amount;
  final double rating;

  final ValueChanged<double> onChanged;

  final Duration animationDuration;
  final Curve animationCurve;

  final IconData icon;
  final double iconSize;
  final Color ratedIconColor;
  final Color unratedIconColor;

  void _handleUpdate(double x, double size) {
    final iSize = (iconSize ?? size ?? 24);
    final value = x / iSize;
    if (value <= amount && !value.isNegative) onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final size = context.theme.iconStyle.size;
    return GestureDetector(
      onTapDown: (d) => _handleUpdate(d.localPosition.dx, size),
      onHorizontalDragStart: (d) => _handleUpdate(d.localPosition.dx, size),
      onHorizontalDragUpdate: (d) => _handleUpdate(d.localPosition.dx, size),
      child: TweenAnimationBuilder<double>(
        builder: (context, value, child) {
          double v = value + 1;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(amount, (index) {
              double r = v - 1;
              v -= 1;
              if (r > 1)
                r = 1;
              else if (r < 0) r = 0;
              return RatingIcon(
                rating: r,
                icon: icon,
                ratedColor: ratedIconColor,
                unratedColor: unratedIconColor,
                size: iconSize,
              );
            }),
          );
        },
        duration: animationDuration ?? Duration.zero,
        curve: animationCurve ?? Curves.linear,
        tween: Tween<double>(begin: 0, end: rating),
      ),
    );
  }
}

class RatingIcon extends StatelessWidget {
  const RatingIcon({
    Key key,
    @required this.rating,
    this.ratedColor,
    this.unratedColor,
    this.icon,
    this.size,
  })  : assert(rating != null),
        assert(rating >= 0.0 && rating <= 1.0),
        super(key: key);

  final double rating;
  final IconData icon;
  final Color ratedColor;
  final Color unratedColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme;
    final icon = this.icon ?? FluentSystemIcons.ic_fluent_star_filled;
    final size = this.size;
    if (rating == 1.0)
      return Icon(icon, color: ratedColor ?? style.accentColor, size: size);
    else if (rating == 0.0)
      return Icon(icon, color: unratedColor ?? style.disabledColor, size: size);
    return Stack(
      children: [
        Icon(icon, color: unratedColor ?? style.disabledColor, size: size),
        ClipRect(
          clipper: _StarClipper(rating),
          child: Icon(icon, color: ratedColor ?? style.accentColor, size: size),
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
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width * value,
      size.height,
    );
    return rect;
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) => oldClipper.value != value;
}
