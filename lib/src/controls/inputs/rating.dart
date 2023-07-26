import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

const IconData kRatingBarIcon = FluentIcons.favorite_star_fill;

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
    super.key,
    required this.rating,
    this.onChanged,
    this.amount = 5,
    this.animationDuration = Duration.zero,
    this.animationCurve,
    this.icon,
    this.iconSize = 20.0,
    this.ratedIconColor,
    this.unratedIconColor,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.starSpacing = 0,
    this.dragStartBehavior = DragStartBehavior.down,
  })  : assert(rating >= 0 && rating <= amount),
        assert(starSpacing >= 0),
        assert(amount > 0);

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

  /// The curve of the animation. If `null`, uses [FluentThemeData.animationCurve]
  final Curve? animationCurve;

  /// The icon used in the bar. If `null`, uses [kRatingBarIcon]
  final IconData? icon;

  /// The size of the icon. If `null`, uses [IconThemeData.size]
  final double iconSize;

  /// The space between each icon
  final double starSpacing;

  /// The color of the icons that are rated. If `null`, uses [FluentThemeData.accentColor]
  final Color? ratedIconColor;

  /// The color of the icons that are not rated. If `null`, uses [FluentThemeData.disabled]
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

  /// Determines the way that drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  @override
  State<RatingBar> createState() => _RatingBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('amount', amount, defaultValue: 5))
      ..add(DoubleProperty('rating', rating))
      ..add(
        DiagnosticsProperty<Duration>('animationDuration', animationDuration),
      )
      ..add(
        DiagnosticsProperty<Curve>('animationCurve', animationCurve),
      )
      ..add(DoubleProperty('iconSize', iconSize))
      ..add(IconDataProperty('icon', icon))
      ..add(ColorProperty('ratedIconColor', ratedIconColor))
      ..add(ColorProperty('unratedIconColor', unratedIconColor))
      ..add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode))
      ..add(
          FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'))
      ..add(DoubleProperty('starSpacing', starSpacing, defaultValue: 0))
      ..add(EnumProperty(
        'dragStartBehavior',
        dragStartBehavior,
        defaultValue: DragStartBehavior.down,
      ));
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

    switch (intent.type) {
      case _SliderAdjustmentType.right:
        switch (directionality) {
          case TextDirection.rtl:
            decrease();
            break;
          case TextDirection.ltr:
            increase();
            break;
        }
        break;
      case _SliderAdjustmentType.left:
        switch (directionality) {
          case TextDirection.rtl:
            increase();
            break;
          case TextDirection.ltr:
            decrease();
            break;
        }
        break;
      case _SliderAdjustmentType.up:
        increase();
        break;
      case _SliderAdjustmentType.down:
        decrease();
        break;
    }
  }

  void _handleUpdate(double x) {
    final iSize = widget.iconSize;
    final value = (x / iSize) - (widget.starSpacing / widget.amount);
    if (value <= widget.amount && !value.isNegative) {
      widget.onChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
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
        enabled: widget.onChanged != null,
        actions: _actionMap,
        shortcuts: _shortcutMap,
        onShowFocusHighlight: (v) {
          setState(() => _showFocusHighlight = v);
        },
        child: GestureDetector(
          dragStartBehavior: widget.dragStartBehavior,
          onTapDown: (d) => _handleUpdate(d.localPosition.dx),
          onHorizontalDragStart: (d) => _handleUpdate(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => _handleUpdate(d.localPosition.dx),
          child: FocusBorder(
            focused: widget.onChanged != null && _showFocusHighlight,
            child: TweenAnimationBuilder<double>(
              builder: (context, value, child) {
                var v = value + 1.0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: () {
                    final items = List.generate(widget.amount, (index) {
                      var r = v - 1.0;
                      v -= 1;
                      if (r > 1) {
                        r = 1;
                      } else if (r < 0) {
                        r = 0;
                      }
                      Widget icon = RatingIcon(
                        rating: r,
                        icon: widget.icon ?? kRatingBarIcon,
                        ratedColor: widget.ratedIconColor,
                        unratedColor: widget.unratedIconColor,
                        size: widget.iconSize,
                      );
                      if (index != widget.amount - 1) {
                        return Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: widget.starSpacing,
                          ),
                          child: icon,
                        );
                      }
                      return icon;
                    });
                    return items;
                  }(),
                );
              },
              duration: widget.animationDuration,
              curve: widget.animationCurve ?? Curves.linear,
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
    super.key,
    required this.rating,
    this.ratedColor,
    this.unratedColor,
    this.icon = kRatingBarIcon,
    this.size,
  }) : assert(rating >= 0.0 && rating <= 1.0);

  /// The rating of the icon. Must be more or equal to 0 and less or equal than 1.0
  final double rating;

  /// The icon.
  final IconData icon;

  /// The color used by the rated part. If `null`, uses [FluentThemeData.accentColor]
  final Color? ratedColor;

  /// The color used by the unrated part. If `null`, uses [FluentThemeData.disabledColor]
  final Color? unratedColor;

  /// The size of the icon
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
      return Icon(
        icon,
        color: ratedColor,
        size: size,
      );
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
