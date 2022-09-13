import 'package:fluent_ui/fluent_ui.dart';

typedef ShapeBuilder = ShapeBorder Function(bool open);

/// The expander direction
enum ExpanderDirection {
  /// Whether the [Expander] expands down
  down,

  /// Whether the [Expander] expands up
  up,
}

/// The [Expander] control lets you show or hide less important content
/// that's related to a piece of primary content that's always visible.
/// Items contained in the Header are always visible. The user can expand
/// and collapse the Content area, where secondary content is displayed,
/// by interacting with the header. When the content area is expanded,
/// it pushes other UI elements out of the way; it does not overlay other
/// UI. The Expander can expand upwards or downwards.
///
/// Both the Header and Content areas can contain any content, from simple
/// text to complex UI layouts. For example, you can use the control to show
/// additional options for an item.
///
/// ![Expander Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/expander-default.gif)
///
/// See also:
///
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/expander>
class Expander extends StatefulWidget {
  /// Creates an expander
  const Expander({
    Key? key,
    this.leading,
    required this.header,
    required this.content,
    this.icon,
    this.trailing,
    this.animationCurve,
    this.animationDuration,
    this.direction = ExpanderDirection.down,
    this.initiallyExpanded = false,
    this.onStateChanged,
    this.headerBackgroundColor,
    this.contentBackgroundColor,
    this.headerShape,
  }) : super(key: key);

  /// The leading widget.
  ///
  /// See also:
  ///
  ///  * [Icon]
  ///  * [RadioButton]
  ///  * [Checkbox]
  final Widget? leading;

  /// The expander header
  ///
  /// Usually a [Text]
  final Widget header;

  /// The expander content
  ///
  /// You can use complex, interactive UI as the content of the
  /// Expander, including nested Expander controls in the content
  /// of a parent Expander as shown here.
  ///
  /// ![Expander Nested Content](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/expander-nested.png)
  final Widget content;

  /// The icon of the toggle button.
  final Widget? icon;

  /// The trailing widget. It's positioned at the right of [header]
  /// and at the left of [icon].
  ///
  /// See also:
  ///
  ///  * [ToggleSwitch]
  final Widget? trailing;

  /// The expand-collapse animation duration. If null, defaults to
  /// [FluentTheme.fastAnimationDuration]
  final Duration? animationDuration;

  /// The expand-collapse animation curve. If null, defaults to
  /// [FluentTheme.animationCurve]
  final Curve? animationCurve;

  /// The expand direction. Defaults to [ExpanderDirection.down]
  final ExpanderDirection direction;

  /// Whether the [Expander] is initially expanded. Defaults to `false`
  final bool initiallyExpanded;

  /// A callback called when the current state is changed. `true` when
  /// open and `false` when closed.
  final ValueChanged<bool>? onStateChanged;

  /// The background color of the header.
  final ButtonState<Color>? headerBackgroundColor;

  /// The content color of the header
  final Color? contentBackgroundColor;

  final ShapeBuilder? headerShape;

  @override
  ExpanderState createState() => ExpanderState();
}

class ExpanderState extends State<Expander>
    with SingleTickerProviderStateMixin {
  late ThemeData _theme;

  bool? _open;
  bool get open => _open ?? false;
  set open(bool value) {
    if (_open != value) _handlePressed();
  }

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _open = PageStorage.of(context)?.readState(
          context,
          identifier: 'expanderOpen',
        ) as bool? ??
        widget.initiallyExpanded;
    if (_open == true) {
      _controller.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = FluentTheme.of(context);
    if (_open == null) {
      _open = !widget.initiallyExpanded;
      open = widget.initiallyExpanded;
    }
  }

  void _handlePressed() {
    if (open) {
      _controller.animateTo(
        0.0,
        duration: widget.animationDuration ?? _theme.fastAnimationDuration,
        curve: widget.animationCurve ?? _theme.animationCurve,
      );
      _open = false;
    } else {
      _controller.animateTo(
        1.0,
        duration: widget.animationDuration ?? _theme.fastAnimationDuration,
        curve: widget.animationCurve ?? _theme.animationCurve,
      );
      _open = true;
    }
    PageStorage.of(context)?.writeState(
      context,
      open,
      identifier: 'expanderOpen',
    );
    widget.onStateChanged?.call(open);
    if (mounted) setState(() {});
  }

  bool get _isDown => widget.direction == ExpanderDirection.down;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Duration expanderAnimationDuration = Duration(milliseconds: 70);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final children = [
      // HEADER
      HoverButton(
        onPressed: _handlePressed,
        builder: (context, states) {
          return Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: ShapeDecoration(
              color: widget.headerBackgroundColor?.resolve(states) ??
                  theme.resources.cardBackgroundFillColorDefault,
              shape: widget.headerShape?.call(open) ??
                  RoundedRectangleBorder(
                    side: BorderSide(
                      color: theme.resources.cardStrokeColorDefault,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(4.0),
                      bottom: Radius.circular(open ? 0.0 : 4.0),
                    ),
                  ),
            ),
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            alignment: AlignmentDirectional.centerStart,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (widget.leading != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10.0),
                  child: widget.leading!,
                ),
              Expanded(child: widget.header),
              if (widget.trailing != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20.0),
                  child: widget.trailing!,
                ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: widget.trailing != null ? 8.0 : 20.0,
                  end: 8.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: FocusBorder(
                  focused: states.isFocused,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color:
                          ButtonThemeData.uncheckedInputColor(_theme, states),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    alignment: Alignment.center,
                    child: widget.icon ??
                        RotationTransition(
                          turns: Tween<double>(begin: 0, end: 0.5)
                              .animate(_controller),
                          child: Icon(
                            _isDown
                                ? FluentIcons.chevron_down
                                : FluentIcons.chevron_up,
                            size: 10,
                          ),
                        ),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
      // CONTENT
      Flexible(
        fit: FlexFit.loose,
        child: SizeTransition(
          sizeFactor: _controller,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.resources.cardStrokeColorDefault,
              ),
              color: widget.contentBackgroundColor ??
                  theme.resources.cardBackgroundFillColorSecondary,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(4.0)),
            ),
            child: widget.content,
          ),
        ),
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _isDown ? children : children.reversed.toList(),
    );
  }
}
