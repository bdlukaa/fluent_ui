import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// The default icon data for the rating bar.
const IconData kRatingBarIcon = FluentIcons.favorite_star_fill;

/// A control for viewing and setting star ratings.
///
/// The [RatingBar] allows users to rate content with a configurable number
/// of stars. Users can interact with touch, mouse, keyboard, or gamepad.
///
/// ![RatingBar Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/rating_rs2_doc_ratings_intro.png)
///
/// {@tool snippet}
/// This example shows a basic rating bar:
///
/// ```dart
/// RatingBar(
///   rating: currentRating,
///   onChanged: (rating) => setState(() => currentRating = rating),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a read-only rating display:
///
/// ```dart
/// RatingBar(
///   rating: 4.5,
///   onChanged: null, // Read-only
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Slider], for selecting numeric values from a range
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/rating>
class RatingBar extends StatefulWidget {
  /// Creates a new rating bar.
  ///
  /// [rating] must be greater than 0 and less than [amount]
  ///
  /// [starSpacing] and [amount] must be greater than 0
  const RatingBar({
    required this.rating,
    super.key,
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
  }) : assert(rating >= 0 && rating <= amount),
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
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve))
      ..add(DoubleProperty('iconSize', iconSize))
      ..add(IconDataProperty('icon', icon))
      ..add(ColorProperty('ratedIconColor', ratedIconColor))
      ..add(ColorProperty('unratedIconColor', unratedIconColor))
      ..add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode))
      ..add(
        FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'),
      )
      ..add(DoubleProperty('starSpacing', starSpacing, defaultValue: 0))
      ..add(
        EnumProperty(
          'dragStartBehavior',
          dragStartBehavior,
          defaultValue: DragStartBehavior.down,
        ),
      );
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
          case TextDirection.ltr:
            increase();
        }
      case _SliderAdjustmentType.left:
        switch (directionality) {
          case TextDirection.rtl:
            increase();
          case TextDirection.ltr:
            decrease();
        }
      case _SliderAdjustmentType.up:
        increase();
      case _SliderAdjustmentType.down:
        decrease();
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
                      final Widget icon = RatingIcon(
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

enum _SliderAdjustmentType { right, left, up, down }
