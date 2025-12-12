import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// A builder function that creates a [ShapeBorder] for an [Expander].
///
/// The [open] parameter indicates whether the expander is currently expanded.
typedef ExpanderShapeBuilder = ShapeBorder Function(bool open);

/// The expander direction
enum ExpanderDirection {
  /// Whether the [Expander] expands down
  down,

  /// Whether the [Expander] expands up
  up,
}

/// The [Expander] control lets you show or hide less important content that's
/// related to a piece of primary content that's always visible.
///
/// Items contained in the [header] are always visible. The user can expand and
/// collapse the [content] area, where secondary content is displayed, by
/// interacting with the header. When the content area is expanded, it pushes
/// other UI elements out of the way; it does not overlay other UI. The Expander
/// can expand upwards or downwards using the [direction] property.
///
/// Both the header and content areas can contain any content, from simple text
/// to complex UI layouts. For example, you can use the control to show
/// additional options for an item.
///
/// ![Expander Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/expander-default.gif)
///
/// {@tool snippet}
/// This example shows a basic expander with text content:
///
/// ```dart
/// Expander(
///   header: Text('Click to expand'),
///   content: Text('This is the expanded content.'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows an expander with a leading icon and trailing toggle:
///
/// ```dart
/// Expander(
///   leading: Icon(FluentIcons.settings),
///   header: Text('Settings'),
///   trailing: ToggleSwitch(
///     checked: isEnabled,
///     onChanged: (value) => setState(() => isEnabled = value),
///   ),
///   content: Column(
///     children: [
///       // Settings content...
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows nested expanders:
///
/// ```dart
/// Expander(
///   header: Text('Parent'),
///   content: Expander(
///     header: Text('Nested expander'),
///     content: Text('Nested content'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// ## State management
///
/// The expander maintains its own expanded/collapsed state. Use [initiallyExpanded]
/// to set the initial state, and [onStateChanged] to be notified when the state
/// changes. The expander also supports [PageStorage] to persist its state across
/// rebuilds.
///
/// ## Accessibility
///
/// The expander is accessible by default. The header acts as a button that
/// toggles the content visibility. Screen readers will announce the expanded
/// or collapsed state.
///
/// See also:
///
///  * [TreeView], for displaying hierarchical data
///  * [InfoBar], for displaying status messages that can be dismissed
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/expander>
class Expander extends StatefulWidget {
  /// Creates a windows-styled expander.
  const Expander({
    required this.header,
    required this.content,
    super.key,
    this.leading,
    this.icon,
    this.trailing,
    this.animationCurve,
    this.animationDuration,
    this.direction = ExpanderDirection.down,
    this.initiallyExpanded = false,
    this.onStateChanged,
    this.enabled = true,
    this.headerBackgroundColor,
    this.headerShape,
    this.contentBackgroundColor,
    this.contentPadding = const EdgeInsetsDirectional.all(16),
    this.contentShape,
  });

  /// The leading widget.
  ///
  /// See also:
  ///
  ///  * [Icon], used to display graphic content
  ///  * [RadioButton], used to select an exclusive option from a set of options
  ///  * [Checkbox], used to select or deselect items within a list
  final Widget? leading;

  /// The expander header
  ///
  /// Usually a [Text] widget.
  final Widget header;

  /// The content displayed when the expander is expanded.
  ///
  /// You can use complex, interactive UI as the content of the
  /// Expander, including nested Expander controls in the content
  /// of a parent Expander as shown here.
  ///
  /// ![Expander Nested Content](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/expander-nested.png)
  ///
  /// The content is hidden when the expander is collapsed and becomes
  /// visible when expanded. The transition is animated.
  final Widget content;

  /// The expander icon.
  ///
  /// If not provided, defaults to a chevron icon down or up, depending on the
  /// [direction].
  final Widget? icon;

  /// The trailing widget.
  ///
  /// It's positioned at the right of [header] and before [icon].
  ///
  /// See also:
  ///
  ///  * [ToggleSwitch], used to toggle a setting between two states
  final Widget? trailing;

  /// The expand-collapse animation duration.
  ///
  /// If null, defaults to [FluentThemeData.fastAnimationDuration]
  final Duration? animationDuration;

  /// The expand-collapse animation curve.
  ///
  /// If null, defaults to [FluentThemeData.animationCurve]
  final Curve? animationCurve;

  /// The expand direction.
  ///
  /// Defaults to [ExpanderDirection.down]
  final ExpanderDirection direction;

  /// Whether the [Expander] is initially expanded.
  ///
  /// Defaults to `false`.
  final bool initiallyExpanded;

  /// A callback called when the current state is changed.
  ///
  /// `true` when open and `false` when closed.
  final ValueChanged<bool>? onStateChanged;

  /// Whether the [Expander] is enabled.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// The background color of the header.
  final WidgetStateColor? headerBackgroundColor;

  /// The shape of the header.
  ///
  /// Use the `open` property to determine whether the expander is open or not.
  final ExpanderShapeBuilder? headerShape;

  /// The content color of the content.
  final Color? contentBackgroundColor;

  /// The padding of the content.
  final EdgeInsetsGeometry? contentPadding;

  /// The shape of the content
  ///
  /// Use the `open` property to determine whether the expander is open or not.
  final ExpanderShapeBuilder? contentShape;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<Duration>('animationDuration', animationDuration),
      )
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve))
      ..add(
        DiagnosticsProperty<ExpanderDirection>(
          'direction',
          direction,
          defaultValue: ExpanderDirection.down,
        ),
      )
      ..add(
        DiagnosticsProperty<bool>(
          'initiallyExpanded',
          initiallyExpanded,
          defaultValue: false,
        ),
      )
      ..add(ColorProperty('contentBackgroundColor', contentBackgroundColor))
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          'contentPadding',
          contentPadding,
          defaultValue: const EdgeInsetsDirectional.all(16),
        ),
      );
  }

  @override
  State<Expander> createState() => ExpanderState();
}

/// The state for an [Expander] widget.
///
/// Provides access to the [isExpanded] property to programmatically control
/// the expander's state.
class ExpanderState extends State<Expander>
    with SingleTickerProviderStateMixin {
  late FluentThemeData _theme;

  late bool _isExpanded;

  /// Whether the expander is currently expanded.
  ///
  /// Setting this value will animate the expander to the new state.
  bool get isExpanded => _isExpanded;
  set isExpanded(bool value) {
    if (_isExpanded != value) _handlePressed();
  }

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _isExpanded =
        PageStorage.of(context).readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded == true) {
      _controller.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = FluentTheme.of(context);
  }

  void _handlePressed() {
    if (_isExpanded) {
      _controller.animateTo(
        0,
        duration: widget.animationDuration ?? _theme.mediumAnimationDuration,
        curve: widget.animationCurve ?? _theme.animationCurve,
      );
      _isExpanded = false;
    } else {
      _controller.animateTo(
        1,
        duration: widget.animationDuration ?? _theme.mediumAnimationDuration,
      );
      _isExpanded = true;
    }
    PageStorage.of(context).writeState(context, _isExpanded);
    widget.onStateChanged?.call(_isExpanded);
    if (mounted) setState(() {});
  }

  bool get _isDown => widget.direction == ExpanderDirection.down;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final children = [
      // HEADER
      HoverButton(
        onPressed: widget.enabled ? _handlePressed : null,
        hitTestBehavior: HitTestBehavior.deferToChild,
        builder: (context, states) {
          return Container(
            constraints: const BoxConstraints(minHeight: 42),
            decoration: ShapeDecoration(
              color:
                  widget.headerBackgroundColor?.resolve(states) ??
                  theme.resources.cardBackgroundFillColorDefault,
              shape:
                  widget.headerShape?.call(_isExpanded) ??
                  RoundedRectangleBorder(
                    side: BorderSide(
                      color: theme.resources.cardStrokeColorDefault,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(6),
                      bottom: Radius.circular(_isExpanded ? 0.0 : 6.0),
                    ),
                  ),
            ),
            padding: const EdgeInsetsDirectional.only(start: 16),
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.leading != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: widget.leading,
                  ),
                Expanded(child: widget.header),
                if (widget.trailing != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 20),
                    child: widget.trailing,
                  ),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: widget.trailing != null ? 8.0 : 20.0,
                    end: 8,
                    top: 8,
                    bottom: 8,
                  ),
                  child: FocusBorder(
                    focused: states.isFocused,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: ButtonThemeData.uncheckedInputColor(
                          _theme,
                          states,
                          transparentWhenNone: true,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:
                          widget.icon ??
                          RotationTransition(
                            turns: Tween<double>(begin: 0, end: 0.5).animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Interval(
                                  0.5,
                                  1,
                                  curve:
                                      widget.animationCurve ??
                                      _theme.animationCurve,
                                ),
                              ),
                            ),
                            child: AnimatedSlide(
                              duration: theme.fastAnimationDuration,
                              curve: Curves.easeInCirc,
                              offset: states.isPressed
                                  ? const Offset(0, 0.1)
                                  : Offset.zero,
                              child: Icon(
                                _isDown
                                    ? FluentIcons.chevron_down
                                    : FluentIcons.chevron_up,
                                size: 8,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      SizeTransition(
        sizeFactor: CurvedAnimation(
          curve: Interval(
            0,
            0.5,
            curve: widget.animationCurve ?? _theme.animationCurve,
          ),
          parent: _controller,
        ),
        child: Container(
          width: double.infinity,
          padding: widget.contentPadding,
          decoration: ShapeDecoration(
            shape:
                widget.contentShape?.call(_isExpanded) ??
                RoundedRectangleBorder(
                  side: BorderSide(
                    color: theme.resources.cardStrokeColorDefault,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(6),
                  ),
                ),
            color:
                widget.contentBackgroundColor ??
                theme.resources.cardBackgroundFillColorSecondary,
          ),
          child: ExcludeFocus(excluding: !_isExpanded, child: widget.content),
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
