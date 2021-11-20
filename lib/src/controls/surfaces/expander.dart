import 'package:fluent_ui/fluent_ui.dart';

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
    required this.header,
    required this.content,
    this.icon,
    this.animationCurve,
    this.animationDuration,
    this.direction = ExpanderDirection.down,
    this.initiallyExpanded = false,
    this.onStateChanged,
  }) : super(key: key);

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

  @override
  ExpanderState createState() => ExpanderState();
}

class ExpanderState extends State<Expander>
    with SingleTickerProviderStateMixin {
  late ThemeData theme;

  late bool _open;
  bool get open => _open;
  set open(bool value) {
    if (_open != value) _handlePressed();
  }

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? const Duration(milliseconds: 150),
    );
  }

  void _handlePressed() {
    if (open) {
      _controller.animateTo(
        0.0,
        duration: widget.animationDuration ?? theme.fastAnimationDuration,
        curve: widget.animationCurve ?? theme.animationCurve,
      );
      _open = false;
    } else {
      _controller.animateTo(
        1.0,
        duration: widget.animationDuration ?? theme.fastAnimationDuration,
        curve: widget.animationCurve ?? theme.animationCurve,
      );
      _open = true;
    }
    widget.onStateChanged?.call(open);
    if (mounted) setState(() {});
  }

  bool get _isDown => widget.direction == ExpanderDirection.down;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    theme = FluentTheme.of(context);
    final children = [
      HoverButton(
        onPressed: _handlePressed,
        builder: (context, states) {
          return Container(
            height: 48.0,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border.all(
                width: 0.25,
                color: Color(0xffBCBCBC),
              ),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(4.0),
                bottom: Radius.circular(open ? 0.0 : 4.0),
              ),
            ),
            padding: const EdgeInsets.only(left: 16.0),
            alignment: Alignment.centerLeft,
            child: Row(children: [
              Expanded(child: widget.header),
              Container(
                margin: const EdgeInsets.only(
                  left: 20.0,
                  right: 8.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: ButtonThemeData.uncheckedInputColor(theme, states),
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
            ]),
          );
        },
      ),
      SizeTransition(
        sizeFactor: _controller,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.25,
              color: Color(0xffBCBCBC),
            ),
            color: theme.acrylicBackgroundColor, 
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(4.0)),
          ),
          child: widget.content,
        ),
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _isDown ? children : children.reversed.toList(),
    );
  }
}
