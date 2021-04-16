import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The rating bar allows users to view and set ratings that
/// reflect degrees of satisfaction with content and services.
/// Users can interact with the rating control with touch, pen,
/// mouse, gamepad or keyboard. The follow guidance shows how to
/// use the rating control's features to provide flexibility and
/// customization.
///
/// ![RatingBar Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/rating_rs2_doc_ratings_intro.png)
///
/// See also:
///   - [Slider]
class RatingBar extends StatefulWidget {
  /// Creates a new rating bar.
  ///
  /// [rating] must be greater than 0 and less than [amount]
  ///
  /// [starSpacing] and [amount] must be greater than 0
  const RatingBar({
    Key? key,
    required this.rating,
    this.onChanged,
    this.amount = 5,
    this.animationDuration = Duration.zero,
    this.animationCurve,
    this.icon,
    this.iconSize,
    this.ratedIconColor,
    this.unratedIconColor,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.starSpacing = 0,
  })  : assert(rating >= 0 && rating <= amount),
        assert(starSpacing >= 0),
        assert(amount > 0),
        super(key: key);

  /// The amount of stars in the bar. The default amount is 5
  final int amount;

  /// The current rating of the bar.
  /// It must be more or equal to 0 and less than [amount]
  final double rating;

  /// Called when the [rating] is changed.
  /// If this is `null`, the RatingBar will not detect touch inputs
  final ValueChanged<double>? onChanged;

  /// The duration of the animation
  final Duration animationDuration;

  /// The curve of the animation. If `null`, uses [Style.animationCurve]
  final Curve? animationCurve;

  /// The icon used in the bar. If `null`, uses [Icons.star_rate_sharp]
  final IconData? icon;

  /// The size of the icon. If `null`, uses [IconStyle.size]
  final double? iconSize;

  /// The space between each icon
  final double starSpacing;

  /// The color of the icons that are rated. If `null`, uses [Style.accentColor]
  final Color? ratedIconColor;

  /// The color of the icons that are not rated. If `null`, uses [Style.disabled]
  final Color? unratedIconColor;

  /// Semantic label for the bar
  ///
  /// Announced in accessibility modes (e.g TalkBack/VoiceOver). This
  /// label does not show in the UI.
  ///
  ///   * [SemanticsProperties.label], which is set to [semanticLabel]
  ///     in the underlying [Semantics] widget.
  final String? semanticLabel;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  @override
  _RatingBarState createState() => _RatingBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('amount', amount));
    properties.add(DoubleProperty('rating', rating));
    properties.add(
      DiagnosticsProperty<Duration>('animationDuration', animationDuration),
    );
    properties.add(
      DiagnosticsProperty<Curve>('animationCurve', animationCurve),
    );
    properties.add(DoubleProperty('iconSize', iconSize));
    properties.add(IconDataProperty('icon', icon));
    properties.add(ColorProperty('ratedIconColor', ratedIconColor));
    properties.add(ColorProperty('unratedIconColor', unratedIconColor));
    properties.add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
    properties.add(FlagProperty(
      'autofocus',
      value: autofocus,
      ifFalse: 'manual focus',
    ));
    properties.add(DoubleProperty('starSpacing', starSpacing));
  }
}

class _RatingBarState extends State<RatingBar> {
  late FocusNode _focusNode;
  late Map<LogicalKeySet, Intent> _shortcutMap;
  late Map<Type, Action<Intent>> _actionMap;

  bool _showFocusHighlight = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowUp): const _AdjustSliderIntent.up(),
      LogicalKeySet(LogicalKeyboardKey.arrowDown):
          const _AdjustSliderIntent.down(),
      LogicalKeySet(LogicalKeyboardKey.arrowLeft):
          const _AdjustSliderIntent.left(),
      LogicalKeySet(LogicalKeyboardKey.arrowRight):
          const _AdjustSliderIntent.right(),
    };
    _actionMap = <Type, Action<Intent>>{
      _AdjustSliderIntent: CallbackAction<_AdjustSliderIntent>(
        onInvoke: _actionHandler,
      ),
    };
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _actionHandler(_AdjustSliderIntent intent) {
    final directionality = Directionality.of(context);
    void increase() {
      if (widget.rating == widget.amount) {
        return;
      }
      widget.onChanged?.call(
        (widget.rating + 1).clamp(0, widget.amount).toDouble(),
      );
    }

    void decrease() {
      if (widget.rating == 0) {
        return;
      }
      widget.onChanged?.call(
        (widget.rating - 1).clamp(0, widget.amount).toDouble(),
      );
    }

    switch (intent) {
      case _AdjustSliderIntent.right():
        switch (directionality) {
          case TextDirection.rtl:
            decrease();
            break;
          case TextDirection.ltr:
            increase();
            break;
        }
        break;
      case _AdjustSliderIntent.left():
        switch (directionality) {
          case TextDirection.rtl:
            increase();
            break;
          case TextDirection.ltr:
            decrease();
            break;
        }
        break;
      case _AdjustSliderIntent.up():
        increase();
        break;
      case _AdjustSliderIntent.down():
        decrease();
        break;
    }
  }

  void _handleUpdate(double x, double? size) {
    final iSize = (widget.iconSize ?? size ?? 24);
    final value = (x / iSize) - (widget.starSpacing / widget.amount);
    if (value <= widget.amount && !value.isNegative)
      widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final size = context.theme.iconStyle?.size;
    return Semantics(
      label: widget.semanticLabel,
      // It's only a slider if its value can be changed
      slider: widget.onChanged != null,
      maxValueLength: widget.amount,
      value: widget.rating.toStringAsFixed(2),
      focusable: true,
      focused: _focusNode.hasFocus,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        actions: _actionMap,
        shortcuts: _shortcutMap,
        onShowFocusHighlight: (v) {
          setState(() => _showFocusHighlight = v);
        },
        child: FocusBorder(
          focused: _showFocusHighlight,
          child: GestureDetector(
            onTapDown: (d) => _handleUpdate(d.localPosition.dx, size),
            onHorizontalDragStart: (d) =>
                _handleUpdate(d.localPosition.dx, size),
            onHorizontalDragUpdate: (d) =>
                _handleUpdate(d.localPosition.dx, size),
            child: TweenAnimationBuilder<double>(
              builder: (context, value, child) {
                double v = value + 1;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: () {
                    final items = List.generate(widget.amount, (index) {
                      double r = v - 1;
                      v -= 1;
                      if (r > 1)
                        r = 1;
                      else if (r < 0) r = 0;
                      Widget icon = RatingIcon(
                        rating: r,
                        icon: widget.icon ?? Icons.star_rate_sharp,
                        ratedColor: widget.ratedIconColor,
                        unratedColor: widget.unratedIconColor,
                        size: widget.iconSize,
                      );
                      if (index != widget.amount - 1) {
                        return Padding(
                          padding: EdgeInsets.only(right: widget.starSpacing),
                          child: icon,
                        );
                      }
                      return icon;
                    });
                    if (Directionality.of(context) == TextDirection.rtl) {
                      return items.reversed.toList();
                    }
                    return items;
                  }(),
                );
              },
              duration: widget.animationDuration,
              curve: widget.animationCurve ??
                  context.theme.animationCurve ??
                  Curves.linear,
              tween: Tween<double>(begin: 0, end: widget.rating),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdjustSliderIntent extends Intent {
  const _AdjustSliderIntent({required this.type});

  const _AdjustSliderIntent.right() : type = _SliderAdjustmentType.right;

  const _AdjustSliderIntent.left() : type = _SliderAdjustmentType.left;

  const _AdjustSliderIntent.up() : type = _SliderAdjustmentType.up;

  const _AdjustSliderIntent.down() : type = _SliderAdjustmentType.down;

  final _SliderAdjustmentType type;
}

enum _SliderAdjustmentType {
  right,
  left,
  up,
  down,
}

class RatingIcon extends StatelessWidget {
  const RatingIcon({
    Key? key,
    required this.rating,
    this.ratedColor,
    this.unratedColor,
    this.icon = Icons.star_rate_sharp,
    this.size,
  })  : assert(rating >= 0.0 && rating <= 1.0),
        super(key: key);

  /// The rating of the icon. Must be more or equal to 0 and less or equal than 1.0
  final double rating;

  /// The icon.
  final IconData icon;

  /// The color used by the rated part. If `null`, uses [Style.accentColor]
  final Color? ratedColor;

  /// The color used by the unrated part. If `null`, uses [Style.disabledColor]
  final Color? unratedColor;

  /// The size of the icon
  final double? size;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme;
    final icon = this.icon;
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
          child: Icon(
            icon,
            color: ratedColor ?? style.accentColor,
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
