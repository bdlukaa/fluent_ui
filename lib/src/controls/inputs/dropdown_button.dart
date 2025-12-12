import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const double _kVerticalOffset = 6;
const Widget _kDefaultDropdownButtonTrailing = ChevronDown();

/// A builder function for creating a custom dropdown button widget.
///
/// The [onOpen] callback opens the dropdown menu.
typedef DropDownButtonBuilder =
    Widget Function(BuildContext context, VoidCallback? onOpen);

/// A button that displays a dropdown menu when pressed.
///
/// [DropDownButton] shows a chevron indicator signaling that pressing it
/// opens a flyout menu with additional options. It's useful for grouping
/// related actions or presenting a list of choices.
///
/// ![DropDownButton Showcase](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/drop-down-button-align.png)
///
/// {@tool snippet}
/// This example shows a dropdown button with menu items:
///
/// ```dart
/// DropDownButton(
///   title: Text('Options'),
///   items: [
///     MenuFlyoutItem(
///       text: Text('Copy'),
///       leading: Icon(FluentIcons.copy),
///       onPressed: () => copy(),
///     ),
///     MenuFlyoutItem(
///       text: Text('Paste'),
///       leading: Icon(FluentIcons.paste),
///       onPressed: () => paste(),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [ComboBox], a text field with a dropdown menu
///  * [SplitButton], a button with a dropdown menu
///  * [MenuFlyout], a menu that can be used to display a list of options
///  * [Flyout], the underlying light-dismiss container
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/buttons#create-a-drop-down-button>
class DropDownButton extends StatefulWidget {
  /// Creates a dropdown button.
  const DropDownButton({
    required this.items,
    super.key,
    this.buttonBuilder,
    this.leading,
    this.title,
    this.trailing = _kDefaultDropdownButtonTrailing,
    this.verticalOffset = _kVerticalOffset,
    this.closeAfterClick = true,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    this.placement = FlyoutPlacementMode.bottomCenter,
    this.menuShape,
    this.menuColor,
    this.onOpen,
    this.onClose,
    this.transitionBuilder = _defaultTransitionBuilder,
    this.style,
  }) : assert(items.length > 0, 'You must provide at least one item');

  /// A builder for the button. If null, a [Button] with [leading], [title] and
  /// [trailing] is used.
  ///
  /// If [disabled] is true, [DropDownButtonBuilder.onOpen] will be null
  final DropDownButtonBuilder? buttonBuilder;

  /// The content at the start of this widget.
  ///
  /// Usually an [Icon]
  final Widget? leading;

  /// Title show a content at the center of this widget.
  ///
  /// Usually a [Text]
  final Widget? title;

  /// Trailing show a content at the right of this widget.
  ///
  /// If null, a chevron_down icon is displayed.
  ///
  /// Usually an [Icon] widget
  final Widget? trailing;

  /// The space between the button and the flyout.
  ///
  /// 6.0 is used by default
  final double verticalOffset;

  /// The items in the flyout. Must not be empty
  ///
  /// See also:
  ///
  ///  * [MenuFlyout], which displays a list of commands or options
  ///  * [MenuFlyoutItem], a single item in the list of items
  ///  * [MenuFlyoutSeparator], which represents a horizontal line that
  ///    separates items in a [MenuFlyout].
  ///  * [MenuFlyoutSubItem], which represents a menu item that displays a
  ///    sub-menu in a [MenuFlyout]
  ///  * [MenuFlyoutItemBuilder], which renders the given widget in the items list
  final List<MenuFlyoutItemBase> items;

  /// Whether the flyout will be closed after an item is tapped.
  ///
  /// This is only effective on items that are [MenuFlyoutItem].
  ///
  /// Defaults to `true`
  final bool closeAfterClick;

  /// If `true`, the button won't be clickable.
  final bool disabled;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The placement of the flyout.
  ///
  /// [FlyoutPlacementMode.bottomCenter] is used by default
  final FlyoutPlacementMode placement;

  /// The menu shape
  final ShapeBorder? menuShape;

  /// The menu color. If null, [FluentThemeData.menuColor] is used
  final Color? menuColor;

  /// Called when the flyout is opened
  final VoidCallback? onOpen;

  /// Called when the flyout is closed
  final VoidCallback? onClose;

  /// The transition animation builder.
  ///
  /// See also:
  ///
  ///  * [FlyoutTransitionBuilder], which is the signature of this property
  final FlyoutTransitionBuilder transitionBuilder;

  /// Customizes this button's appearance.
  final ButtonStyle? style;

  @override
  State<DropDownButton> createState() => DropDownButtonState();

  static Widget _defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    FlyoutPlacementMode placement,
    Widget flyout,
  ) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
    final textDirection = Directionality.of(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        /// On the slide animation, we make use of a [ClipRect] to ensure
        /// only the necessary parts of the widgets will be visible. Altough,
        /// [ClipRect] clips all the borders of the widget, not only the necessary
        /// parts, hiding any shadow the [flyout] may have. To avoid this issue,
        /// we show the flyout independent when the animation is complated (1.0)
        /// or dismissed (0.0)
        if (animation.isCompleted || animation.isDismissed) return child!;

        if (animation.status == AnimationStatus.reverse) {
          return FadeTransition(opacity: animation, child: child);
        }

        final animationCurve = FluentTheme.of(context).animationCurve;
        switch (placement) {
          case FlyoutPlacementMode.bottomCenter:
          case FlyoutPlacementMode.bottomLeft:
          case FlyoutPlacementMode.bottomRight:
            return ClipRect(
              child: SlideTransition(
                textDirection: textDirection,
                position:
                    Tween<Offset>(
                      begin: const Offset(0, -1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: animationCurve),
                    ),
                child: child,
              ),
            );
          case FlyoutPlacementMode.topCenter:
          case FlyoutPlacementMode.topLeft:
          case FlyoutPlacementMode.topRight:
            return ClipRect(
              child: SlideTransition(
                textDirection: textDirection,
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: animationCurve),
                    ),
                child: child,
              ),
            );
          default:
            return child!;
        }
      },
      child: flyout,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<MenuFlyoutItemBase>('items', items))
      ..add(
        DoubleProperty(
          'verticalOffset',
          verticalOffset,
          defaultValue: _kVerticalOffset,
        ),
      )
      ..add(
        FlagProperty(
          'close after click',
          value: closeAfterClick,
          defaultValue: false,
          ifFalse: 'do not close after click',
        ),
      )
      ..add(EnumProperty<FlyoutPlacementMode>('placement', placement))
      ..add(DiagnosticsProperty<ShapeBorder>('menu shape', menuShape))
      ..add(ColorProperty('menu color', menuColor));
  }
}

class DropDownButtonState extends State<DropDownButton> {
  final _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  // See: https://github.com/flutter/flutter/issues/16957#issuecomment-558878770
  List<Widget> _space(
    Iterable<Widget> children, {
    Widget spacer = const SizedBox(width: 8),
  }) {
    return children
        .expand((child) sync* {
          yield spacer;
          yield child;
        })
        .skip(1)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));

    final theme = FluentTheme.of(context);
    return FlyoutTarget(
      controller: _flyoutController,
      child: Builder(
        builder: (context) {
          if (widget.buttonBuilder != null) {
            return widget.buttonBuilder!(
              context,
              widget.disabled ? null : open,
            );
          }

          return Button(
            onPressed: widget.disabled ? null : open,
            autofocus: widget.autofocus,
            focusNode: widget.focusNode,
            style: widget.style,
            child: Builder(
              builder: (context) {
                final state = HoverButton.of(context).states;

                return IconTheme.merge(
                  data: const IconThemeData(size: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _space(<Widget>[
                      if (widget.leading != null) widget.leading!,
                      if (widget.title != null) widget.title!,
                      if (widget.trailing != null)
                        IconTheme.merge(
                          data: IconThemeData(
                            color: state.isDisabled
                                ? theme.resources.textFillColorDisabled
                                : state.isPressed
                                ? theme.resources.textFillColorTertiary
                                : state.isHovered
                                ? theme.resources.textFillColorSecondary
                                : theme.resources.textFillColorPrimary,
                          ),
                          child: AnimatedSlide(
                            duration: theme.fastAnimationDuration,
                            curve: Curves.easeInCirc,
                            offset: state.isPressed
                                ? const Offset(0, 0.1)
                                : Offset.zero,
                            child: widget.trailing,
                          ),
                        ),
                    ]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Whether the dropdown flyout is open
  ///
  /// See also:
  ///
  ///  * [FlyoutController.isOpen], which verifies if the flyout is open
  bool get isOpen => _flyoutController.isOpen;

  /// Opens the dropdown flyout
  ///
  /// {@macro fluent_ui.flyouts.barrierDismissible}
  ///
  /// {@macro fluent_ui.flyouts.dismissWithEsc}
  ///
  /// {@macro fluent_ui.flyouts.dismissOnPointerMoveAway}
  ///
  /// See also:
  ///
  ///  * [FlyoutController.showFlyout], which is used to show the dropdown flyout
  Future<void> open({
    bool barrierDismissible = true,
    bool dismissWithEsc = true,
    bool dismissOnPointerMoveAway = false,
  }) async {
    if (_flyoutController.isOpen) return;
    widget.onOpen?.call();
    await _flyoutController.showFlyout<void>(
      barrierColor: Colors.transparent,
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: widget.placement,
      ),
      additionalOffset: widget.verticalOffset,
      barrierDismissible: barrierDismissible,
      dismissOnPointerMoveAway: dismissOnPointerMoveAway,
      dismissWithEsc: dismissWithEsc,
      transitionBuilder: widget.transitionBuilder,
      builder: (context) {
        return MenuFlyout(
          color: widget.menuColor,
          shape: widget.menuShape,
          items: widget.items
              .map((item) => _transformItem(item, context))
              .toList(),
        );
      },
    );
    widget.onClose?.call();
  }

  MenuFlyoutItemBase _transformItem(
    MenuFlyoutItemBase item,
    BuildContext context,
  ) {
    if (item is MenuFlyoutSubItem) {
      return _createSubMenuItem(item);
    } else if (item is MenuFlyoutItem) {
      return _createMenuItem(item, context);
    } else {
      return item;
    }
  }

  MenuFlyoutSubItem _createSubMenuItem(MenuFlyoutSubItem item) {
    return MenuFlyoutSubItem(
      key: item.key,
      text: item.text,
      items: (context) => item
          .items(context)
          .map((item) => _transformItem(item, context))
          .toList(),
      leading: item.leading,
      trailing: item.trailing,
      showBehavior: item.showBehavior,
      showHoverDelay: item.showHoverDelay,
    );
  }

  MenuFlyoutItem _createMenuItem(MenuFlyoutItem item, BuildContext context) {
    return MenuFlyoutItem(
      onPressed: item.onPressed,
      closeAfterClick: !!item.closeAfterClick || !widget.closeAfterClick,
      key: item.key,
      leading: item.leading,
      text: item.text,
      trailing: item.trailing,
      selected: item.selected,
    );
  }
}
