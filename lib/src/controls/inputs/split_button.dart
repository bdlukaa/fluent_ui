import 'package:fluent_ui/fluent_ui.dart';

/// A builder for the secondary part of a split button.
///
/// The builder should return a widget that will be displayed when the secondary
/// part of the button is pressed.
///
/// See also:
///
/// * [SplitButton], which is the widget that uses this builder.
/// * [FlyoutController], which is the controller for the flyout.
typedef SplitButtonSecondaryBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback showFlyout,
      FlyoutController flyoutController,
    );

enum _SplitButtonType { normal, toggle }

/// A button with two parts: a primary action and a flyout trigger.
///
/// [SplitButton] combines a standard button with a dropdown. Clicking the
/// primary area invokes the default action, while clicking the secondary
/// area (chevron) opens a flyout with additional options.
///
/// ![SplitButton showcase](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/split-button-rtb.png)
///
/// {@tool snippet}
/// This example shows a split button with color options:
///
/// ```dart
/// SplitButton(
///   child: Container(
///     color: selectedColor,
///     width: 24,
///     height: 24,
///   ),
///   onInvoked: () => applyColor(selectedColor),
///   flyout: MenuFlyout(
///     items: colors.map((color) => MenuFlyoutItem(
///       text: Text(color.name),
///       onPressed: () => setState(() => selectedColor = color),
///     )).toList(),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// ## Programmatic flyout control
///
/// Use a [GlobalKey] to show the flyout programmatically:
///
/// ```dart
/// final key = GlobalKey<SplitButtonState>();
/// key.currentState?.showFlyout<void>();
/// ```
///
/// See also:
///
///  * [DropDownButton], a button that only shows a dropdown
///  * [Button], a simple action button
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/buttons#create-a-split-button>
class SplitButton extends StatefulWidget {
  /// The type of the button
  final _SplitButtonType _type;

  /// The primary widget to be displayed
  final Widget child;

  /// The secondary widget to be displayed. If not provided, the default chevron
  /// down icon is displayed.
  ///
  /// Example:
  /// ```dart
  /// SplitButton(
  ///   child: Text('Split Button'),
  ///   // invoke [showFlyout] to show the flyout, or use the flyoutController
  ///   // to display a flyout with custom options
  ///   secondaryBuilder: (context, showFlyout, flyoutController) {
  ///     return IconButton(
  ///       icon: const ChevronDown(),
  ///       onPressed: showFlyout,
  ///     );
  ///   },
  ///   flyout: Container(
  ///     width: 200,
  ///     height: 200,
  ///     color: Colors.white,
  ///   ),
  /// ),
  /// ```
  ///
  /// See also:
  ///
  ///   * [ChevronDown], the default icon used
  ///   * [flyout], the widget to be displayed when the flyout is requested
  final SplitButtonSecondaryBuilder? secondaryBuilder;

  /// The widget to be displayed when the flyout is requested
  ///
  /// Usually a [FlyoutContent] or a [MenuFlyout]
  final Widget flyout;

  /// When the primary part of the button is invoked
  final VoidCallback? onInvoked;

  /// Whether the button is enabled
  final bool enabled;

  /// Whether the split button is checked
  final bool checked;

  /// Creates a split button
  const SplitButton({
    required this.child,
    required this.flyout,
    super.key,
    this.secondaryBuilder,
    this.onInvoked,
    this.enabled = true,
  }) : _type = _SplitButtonType.normal,
       checked = false;

  /// Creates a split toggle button
  const SplitButton.toggle({
    required this.child,
    required this.checked,
    required this.flyout,
    super.key,
    this.secondaryBuilder,
    this.onInvoked,
    this.enabled = true,
  }) : _type = _SplitButtonType.toggle;

  @override
  State<SplitButton> createState() => SplitButtonState();
}

class SplitButtonState extends State<SplitButton> {
  /// The controller for the flyout.
  late final FlyoutController flyoutController = FlyoutController();

  bool _showFocusHighlight = false;

  @override
  void dispose() {
    flyoutController.dispose();
    super.dispose();
  }

  /// Shows the flyout attached to the dropdown button
  Future<void> showFlyout() async {
    await flyoutController.showFlyout<void>(
      barrierColor: Colors.transparent,
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: FlyoutPlacementMode.bottomCenter,
      ),
      builder: (context) {
        return widget.flyout;
      },
    );
  }

  void _updateFocusHighlight(bool focused) {
    setState(() => _showFocusHighlight = focused);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final radius = BorderRadius.circular(4);

    return FocusBorder(
      focused: _showFocusHighlight,
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: widget.checked
                ? FilledButton.shapeBorder(theme, {})
                : ButtonThemeData.shapeBorder(context, {}),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HoverButton(
                  onPressed: widget.enabled ? widget.onInvoked : null,
                  onFocusChange: _updateFocusHighlight,
                  focusEnabled:
                      widget._type == _SplitButtonType.toggle ||
                      widget.secondaryBuilder != null,
                  builder: (context, states) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.checked
                            ? FilledButton.backgroundColor(theme, states)
                            : ButtonThemeData.buttonColor(
                                context,
                                widget.enabled &&
                                        widget.onInvoked == null &&
                                        states.isDisabled
                                    ? {}
                                    : states,
                                transparentWhenNone: true,
                              ),
                      ),
                      child: DefaultTextStyle.merge(
                        style: widget.checked
                            ? TextStyle(
                                color: FilledButton.foregroundColor(
                                  theme,
                                  states,
                                ),
                              )
                            : null,
                        child: IconTheme.merge(
                          data: IconThemeData(
                            color: widget.checked
                                ? FilledButton.foregroundColor(theme, states)
                                : null,
                          ),
                          child: widget.child,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(
                  direction: Axis.vertical,
                  style: DividerThemeData(
                    horizontalMargin: EdgeInsetsDirectional.zero,
                    verticalMargin: EdgeInsetsDirectional.zero,
                  ),
                ),
                if (widget.secondaryBuilder == null)
                  HoverButton(
                    onPressed: widget.enabled ? showFlyout : null,
                    onFocusChange: _updateFocusHighlight,
                    focusEnabled: widget._type == _SplitButtonType.normal,
                    builder: (context, states) {
                      return FlyoutTarget(
                        controller: flyoutController,
                        child: Container(
                          color: widget.checked
                              ? ButtonThemeData.checkedInputColor(theme, states)
                              : ButtonThemeData.buttonColor(
                                  context,
                                  flyoutController.isOpen
                                      ? {WidgetState.pressed}
                                      : states,
                                  transparentWhenNone: true,
                                ),
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 12,
                          ),
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            duration: theme.fastAnimationDuration,
                            opacity: flyoutController.isOpen ? 0.5 : 1,
                            child: ChevronDown(
                              iconColor: widget.checked
                                  ? FilledButton.foregroundColor(theme, states)
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  widget.secondaryBuilder!(
                    context,
                    showFlyout,
                    flyoutController,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
