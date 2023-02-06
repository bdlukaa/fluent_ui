import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const double _kVerticalOffset = 6.0;
const Widget _kDefaultDropdownButtonTrailing = Icon(
  FluentIcons.chevron_down,
  size: 8.0,
);

typedef DropDownButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback? onOpen,
);

/// A dropdown button is a button that shows a chevron as a visual indicator that
/// it has an attached flyout that contains more options. It has the same
/// behavior as a standard Button control with a flyout; only the appearance is
/// different.
///
/// ![DropDownButton Showcase](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/drop-down-button-align.png)
///
/// See also:
///
///   * [Flyout], a light dismiss container that can show arbitrary UI as its
///     content. Used to back this button
///   * [ComboBox], a list of items that a user can select from
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/buttons#create-a-drop-down-button>
class DropDownButton extends StatefulWidget {
  /// Creates a dropdown button.
  const DropDownButton({
    Key? key,
    this.buttonBuilder,
    required this.items,
    this.leading,
    this.title,
    this.trailing,
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
  })  : assert(items.length > 0, 'You must provide at least one item'),
        super(key: key);

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
  final List<MenuFlyoutItem> items;

  /// Whether the flyout will be closed after an item is tapped.
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

  /// The menu color. If null, [ThemeData.menuColor] is used
  final Color? menuColor;

  /// Called when the flyout is opened
  final VoidCallback? onOpen;

  /// Called when the flyout is closed
  final VoidCallback? onClose;

  final FlyoutTransitionBuilder transitionBuilder;

  @override
  State<DropDownButton> createState() => DropDownButtonState();

  static Widget _defaultTransitionBuilder(
    context,
    animation,
    placement,
    flyout,
  ) {
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

        switch (placement) {
          case FlyoutPlacementMode.bottomCenter:
          case FlyoutPlacementMode.bottomLeft:
          case FlyoutPlacementMode.bottomRight:
            return ClipRect(
              child: SlideTransition(
                textDirection: textDirection,
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: const Offset(0, 0),
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: FluentTheme.of(context).animationCurve,
                )),
                child: child,
              ),
            );
          case FlyoutPlacementMode.topCenter:
          case FlyoutPlacementMode.topLeft:
          case FlyoutPlacementMode.topRight:
            return ClipRect(
              child: SlideTransition(
                textDirection: textDirection,
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: const Offset(0, 0),
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: FluentTheme.of(context).animationCurve,
                )),
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
      ..add(DoubleProperty(
        'verticalOffset',
        verticalOffset,
        defaultValue: _kVerticalOffset,
      ))
      ..add(FlagProperty(
        'close after click',
        value: closeAfterClick,
        defaultValue: false,
        ifFalse: 'do not close after click',
      ))
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
    Widget spacer = const SizedBox(width: 8.0),
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

    final buttonChildren = _space(<Widget>[
      if (widget.leading != null) widget.leading!,
      if (widget.title != null) widget.title!,
      IconTheme.merge(
        data: IconThemeData(
          color: theme.resources.textFillColorSecondary,
        ),
        child: widget.trailing ?? _kDefaultDropdownButtonTrailing,
      ),
    ]);

    return FlyoutTarget(
      controller: _flyoutController,
      child: Builder(builder: (context) {
        return widget.buttonBuilder?.call(
              context,
              widget.disabled ? null : open,
            ) ??
            Button(
              onPressed: widget.disabled ? null : open,
              autofocus: widget.autofocus,
              focusNode: widget.focusNode,
              child: IconTheme.merge(
                data: const IconThemeData(size: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: buttonChildren,
                ),
              ),
            );
      }),
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
  void open({
    bool barrierDismissible = true,
    bool dismissWithEsc = true,
    bool dismissOnPointerMoveAway = false,
  }) async {
    if (_flyoutController.isOpen) return;

    widget.onOpen?.call();
    await _flyoutController.showFlyout(
      placementMode: FlyoutPlacementMode.auto,
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
          items: widget.items.map((item) {
            if (widget.closeAfterClick) {
              return MenuFlyoutItem(
                onPressed: () {
                  Navigator.of(context).pop();
                  item.onPressed?.call();
                },
                key: item.key,
                leading: item.leading,
                text: item.text,
                trailing: item.trailing,
                selected: item.selected,
              );
            }
            return item;
          }).toList(),
        );
      },
    );
    widget.onClose?.call();
  }
}
