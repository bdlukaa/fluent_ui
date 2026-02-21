import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// A control for viewing and setting star ratings.
///
/// The [RatingControl] allows users to rate content with a configurable number
/// of stars. Users can interact with touch, mouse, keyboard, or gamepad.
///
/// Interactive input (click/drag) always snaps to whole integers, matching
/// WinUI 3. The [RatingControl.rating] property accepts arbitrary fractional
/// doubles, which render as partial stars — useful for read-only average-rating
/// displays (e.g. `rating: 3.7`).
///
/// ![RatingControl Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/rating_rs2_doc_ratings_intro.png)
///
/// {@tool snippet}
/// This example shows a basic rating control:
///
/// ```dart
/// RatingControl(
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
/// RatingControl(
///   rating: 4.5,
///   onChanged: null, // Read-only
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Slider], for selecting numeric values from a range
///  * <https://learn.microsoft.com/en-us/windows/apps/develop/ui/controls/rating>
class RatingControl extends StatefulWidget {
  /// Creates a new rating control.
  ///
  /// [rating] must be greater than or equal to 0 and less than or equal to [amount].
  ///
  /// [starSpacing] and [amount] must be greater than or equal to 0.
  const RatingControl({
    required this.rating,
    super.key,
    this.onChanged,
    this.amount = 5,
    this.animationDuration = Duration.zero,
    this.animationCurve,
    this.icon,
    this.unratedIcon,
    this.iconSize = 20.0,
    this.ratedIconColor,
    this.unratedIconColor,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.starSpacing = 8.0,
    this.dragStartBehavior = DragStartBehavior.down,
  }) : assert(
         rating >= 0 && rating <= amount,
         'Rating must be between 0 and the amount of stars.',
       ),
       assert(starSpacing >= 0, 'Star spacing must be non-negative.'),
       assert(amount > 0, 'There must be at least one star in the control.'),
       assert(iconSize > 0, 'Icon size must be greater than zero.');

  /// The number of stars in the control. Defaults to 5.
  final int amount;

  /// The current rating.
  ///
  /// Must be between 0 and [amount] (inclusive). Fractional values are
  /// supported and render using a clipped partial star.
  final double rating;

  /// Called when the [rating] changes.
  ///
  /// If this is `null`, the control is read-only and does not respond to input.
  final ValueChanged<double>? onChanged;

  /// The duration of the rating change animation.
  final Duration animationDuration;

  /// The curve of the animation. If `null`, defaults to [Curves.linear].
  final Curve? animationCurve;

  /// The icon used for the filled (rated) portion of a star.
  ///
  /// If `null`, defaults to [kRatingControlIcon].
  final IconData? icon;

  /// The icon used for the unfilled (unrated) portion of a star.
  ///
  /// If `null`, defaults to [kRatingControlUnratedIcon].
  final IconData? unratedIcon;

  /// The size of each star icon.
  final double iconSize;

  /// The spacing between stars. Defaults to 8.0 to match WinUI 3.
  final double starSpacing;

  /// The color of the filled (selected) portion of stars.
  ///
  /// If `null`, uses the theme's accent color.
  final Color? ratedIconColor;

  /// The color of the unfilled (unselected) portion of stars.
  ///
  /// If `null`, uses [ResourceDictionary.textFillColorSecondary].
  final Color? unratedIconColor;

  /// Semantic label for the control.
  ///
  /// Announced in accessibility modes (e.g. TalkBack/VoiceOver). This label
  /// does not appear in the UI.
  ///
  /// See also:
  ///   * [SemanticsProperties.label], which is set to [semanticLabel].
  final String? semanticLabel;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Determines the way that drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  @override
  State<RatingControl> createState() => _RatingControlState();

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
      ..add(IconDataProperty('unratedIcon', unratedIcon))
      ..add(ColorProperty('ratedIconColor', ratedIconColor))
      ..add(ColorProperty('unratedIconColor', unratedIconColor))
      ..add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode))
      ..add(
        FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'),
      )
      ..add(DoubleProperty('starSpacing', starSpacing, defaultValue: 8.0))
      ..add(
        EnumProperty(
          'dragStartBehavior',
          dragStartBehavior,
          defaultValue: DragStartBehavior.down,
        ),
      );
  }
}

class _RatingControlState extends State<RatingControl> {
  late FocusNode _focusNode;
  late Map<LogicalKeySet, Intent> _shortcutMap;
  late Map<Type, Action<Intent>> _actionMap;

  bool _showFocusHighlight = false;

  /// The 1-based index of the star currently under the pointer, or null when
  /// the pointer is outside the control.
  int? _hoveredStar;

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
      if (widget.rating == widget.amount) return;
      widget.onChanged?.call(
        (widget.rating + 1).clamp(0, widget.amount).toDouble(),
      );
    }

    void decrease() {
      if (widget.rating == 0) return;
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

  /// Returns the total physical width of the star row.
  double get _totalWidth =>
      widget.amount * widget.iconSize +
      (widget.amount - 1) * widget.starSpacing;

  /// Flips [x] to LTR space when the layout direction is RTL, so that all
  /// downstream calculations can assume left-to-right ordering.
  double _adjustX(double x) {
    if (Directionality.of(context) == TextDirection.rtl) {
      return (_totalWidth - x).clamp(0.0, _totalWidth);
    }
    return x;
  }

  void _handleUpdate(double x) {
    final totalPerStar = widget.iconSize + widget.starSpacing;
    final raw = (_adjustX(x) / totalPerStar).clamp(
      0.0,
      widget.amount.toDouble(),
    );
    final snapped = raw.ceil().clamp(0, widget.amount).toDouble();
    widget.onChanged?.call(snapped);
  }

  void _handleHoverUpdate(double x) {
    final totalPerStar = widget.iconSize + widget.starSpacing;
    final index = (_adjustX(x) / totalPerStar).floor() + 1;
    final clamped = index.clamp(1, widget.amount);
    if (_hoveredStar != clamped) {
      setState(() => _hoveredStar = clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
    final theme = FluentTheme.of(context);
    final resources = theme.resources;
    final accentColor = theme.accentColor.defaultBrushFor(theme.brightness);
    final isEnabled = widget.onChanged != null;

    return Semantics(
      label: widget.semanticLabel,
      slider: isEnabled,
      maxValueLength: widget.amount,
      value: widget.rating.toStringAsFixed(2),
      focusable: true,
      focused: _focusNode.hasFocus,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: isEnabled,
        actions: _actionMap,
        shortcuts: _shortcutMap,
        onShowFocusHighlight: (v) {
          setState(() => _showFocusHighlight = v);
        },
        child: MouseRegion(
          cursor: isEnabled ? SystemMouseCursors.click : MouseCursor.defer,
          onHover: isEnabled
              ? (event) => _handleHoverUpdate(event.localPosition.dx)
              : null,
          onExit: isEnabled ? (_) => setState(() => _hoveredStar = null) : null,
          child: GestureDetector(
            dragStartBehavior: widget.dragStartBehavior,
            onTapDown: (d) {
              if (_hoveredStar != null) setState(() => _hoveredStar = null);
              _handleUpdate(d.localPosition.dx);
            },
            onHorizontalDragStart: (d) {
              if (_hoveredStar != null) setState(() => _hoveredStar = null);
              _handleUpdate(d.localPosition.dx);
            },
            onHorizontalDragUpdate: (d) => _handleUpdate(d.localPosition.dx),
            child: FocusBorder(
              focused: isEnabled && _showFocusHighlight,
              child: TweenAnimationBuilder<double>(
                duration: widget.animationDuration,
                curve: widget.animationCurve ?? Curves.linear,
                tween: Tween<double>(begin: 0, end: widget.rating),
                builder: (context, value, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.amount, (index) {
                      final Color starRatedColor;
                      final Color starUnratedColor;
                      final double r;

                      if (!isEnabled) {
                        r = (value - index).clamp(0.0, 1.0);
                        starRatedColor =
                            widget.ratedIconColor ??
                            resources.textFillColorDisabled;
                        starUnratedColor =
                            widget.unratedIconColor ??
                            resources.textFillColorSecondary;
                      } else if (_hoveredStar != null) {
                        final hovered = _hoveredStar!;
                        if (index < hovered) {
                          r = 1.0;
                          final alreadySelected = (index + 1) <= widget.rating;
                          starRatedColor =
                              widget.ratedIconColor ??
                              (alreadySelected
                                  ? accentColor
                                  : resources.textFillColorPrimary);
                          starUnratedColor = starRatedColor;
                        } else {
                          r = 0.0;
                          starRatedColor =
                              widget.ratedIconColor ??
                              resources.controlAltFillColorTertiary;
                          starUnratedColor =
                              widget.unratedIconColor ??
                              resources.controlAltFillColorTertiary;
                        }
                      } else {
                        // Normal (non-hover) state
                        r = (value - index).clamp(0.0, 1.0);
                        starRatedColor =
                            widget.ratedIconColor ??
                            accentColor; // SelectedForeground
                        starUnratedColor =
                            widget.unratedIconColor ??
                            resources
                                .textFillColorSecondary; // UnselectedForeground
                      }

                      final Widget star = RatingIcon(
                        rating: r,
                        icon: widget.icon ?? kRatingControlIcon,
                        unratedIcon:
                            widget.unratedIcon ?? kRatingControlUnratedIcon,
                        ratedColor: starRatedColor,
                        unratedColor: starUnratedColor,
                        size: widget.iconSize,
                      );

                      if (index != widget.amount - 1) {
                        return Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: widget.starSpacing,
                          ),
                          child: star,
                        );
                      }
                      return star;
                    }),
                  );
                },
              ),
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

/// The default icon data for the rated (filled) state of the rating control.
///
/// This is [FluentIcons.favorite_star_fill] (U+E735).
const IconData kRatingControlIcon = WindowsIcons.favorite_star_fill;

/// The default icon data for the unrated (unfilled) state of the rating control.
///
/// This is [FluentIcons.favorite_star] (U+E734).
const IconData kRatingControlUnratedIcon = WindowsIcons.favorite_star;

/// Deprecated. Use [kRatingControlIcon] instead.
@Deprecated('Use kRatingControlIcon instead.')
const IconData kRatingBarIcon = kRatingControlIcon;

/// Deprecated. Use [RatingControl] instead.
@Deprecated('Use RatingControl instead.')
typedef RatingBar = RatingControl;

/// A windows-styled rating icon.
///
/// The rating icon displays a star that is filled from left to right based on
/// [rating]. It uses two icons: [icon] (filled) for the rated portion and
/// [unratedIcon] (unfilled) for the unrated portion.
///
/// See also:
///
///   * [RatingControl], a rating bar that uses this icon.
class RatingIcon extends StatelessWidget {
  /// Creates a rating icon.
  const RatingIcon({
    required this.rating,
    super.key,
    this.ratedColor,
    this.unratedColor,
    this.icon = kRatingControlIcon,
    this.unratedIcon = kRatingControlUnratedIcon,
    this.size,
  }) : assert(rating >= 0.0 && rating <= 1.0);

  /// The rating of the icon. Must be more or equal to 0 and less or equal than 1.0
  final double rating;

  /// The filled (rated) icon.
  ///
  /// Defaults to [kRatingControlIcon].
  final IconData icon;

  /// The unfilled (unrated) icon.
  ///
  /// Defaults to [kRatingControlUnratedIcon].
  final IconData unratedIcon;

  /// The color used by the rated part.
  ///
  /// If null, uses the accent color.
  final Color? ratedColor;

  /// The color used by the unrated part.
  ///
  /// If null, uses [ResourceDictionary.textFillColorSecondary].
  final Color? unratedColor;

  /// The size of the icon.
  final double? size;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = FluentTheme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final size = this.size;
    final unratedColor =
        this.unratedColor ?? style.resources.textFillColorSecondary;
    final ratedColor =
        this.ratedColor ?? style.accentColor.defaultBrushFor(style.brightness);
    if (rating == 1.0) {
      return Icon(icon, color: ratedColor, size: size);
    } else if (rating == 0.0) {
      return Icon(unratedIcon, color: unratedColor, size: size);
    }
    final splitPoint = isRtl ? 1.0 - rating : rating;
    return Stack(
      children: [
        ClipRect(
          clipper: _StarClipper(splitPoint, fromRight: !isRtl),
          child: Icon(icon, color: unratedColor, size: size),
        ),
        ClipRect(
          clipper: _StarClipper(splitPoint, fromRight: isRtl),
          child: Icon(icon, color: ratedColor, size: size),
        ),
      ],
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double value;

  /// When true, clips to show the portion to the RIGHT of [value].
  /// When false (default), clips to show the portion to the LEFT of [value].
  final bool fromRight;

  const _StarClipper(this.value, {this.fromRight = false});

  @override
  Rect getClip(Size size) {
    if (fromRight) {
      return Rect.fromLTWH(
        size.width * value,
        0,
        size.width * (1.0 - value),
        size.height,
      );
    }
    return Rect.fromLTWH(0, 0, size.width * value, size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) =>
      oldClipper.value != value || oldClipper.fromRight != fromRight;
}
