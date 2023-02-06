import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const double _kVerticalOffset = 6.0;
const Widget _kDefaultDropdownButtonTrailing = Icon(
  FluentIcons.chevron_down,
  size: 10,
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
    this.buttonStyle,
    this.placement = FlyoutPlacementMode.bottomCenter,
    this.menuShape,
    this.menuColor,
    this.onOpen,
    this.onClose,
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

  /// Customizes the button's appearance.
  @Deprecated('buttonStyle was deprecated in 3.11.1. Use buttonBuilder instead')
  final ButtonStyle? buttonStyle;

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

  @override
  State<DropDownButton> createState() => DropDownButtonState();

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
        .expand((item) sync* {
          yield spacer;
          yield item;
        })
        .skip(1)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));

    final buttonChildren = _space(<Widget>[
      if (widget.leading != null)
        IconTheme.merge(
          data: const IconThemeData(size: 20.0),
          child: widget.leading!,
        ),
      if (widget.title != null) widget.title!,
      widget.trailing ?? _kDefaultDropdownButtonTrailing,
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
              // ignore: deprecated_member_use_from_same_package
              style: widget.buttonStyle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: buttonChildren,
              ),
            );
      }),
    );
  }

  /// Opens the dropdown flyout
  void open() async {
    if (_flyoutController.isOpen) return;

    widget.onOpen?.call();
    await _flyoutController.showFlyout(
      placementMode: FlyoutPlacementMode.auto,
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: widget.placement,
      ),
      additionalOffset: widget.verticalOffset,
      transitionBuilder: (context, animation, placement, flyout) {
        switch (placement) {
          case FlyoutPlacementMode.bottomCenter:
          case FlyoutPlacementMode.bottomLeft:
          case FlyoutPlacementMode.bottomRight:
            return ClipRect(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: const Offset(0, 0),
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: FluentTheme.of(context).animationCurve,
                )),
                child: flyout,
              ),
            );
          case FlyoutPlacementMode.topCenter:
          case FlyoutPlacementMode.topLeft:
          case FlyoutPlacementMode.topRight:
            return ClipRect(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: const Offset(0, 0),
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: FluentTheme.of(context).animationCurve,
                )),
                child: flyout,
              ),
            );
          default:
            return flyout;
        }
      },
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

/// An item used by [DropDownButton].
@Deprecated('DropDownButtonItem is deprecated. Use MenuFlyoutItem instead')
class DropDownButtonItem extends MenuFlyoutItem {
  /// Creates a drop down button item
  DropDownButtonItem({
    Key? key,
    required VoidCallback? onTap,
    Widget? leading,
    Widget? title,
    Widget? trailing,
  })  : assert(
          leading != null || title != null || trailing != null,
          'You must provide at least one property: leading, title or trailing',
        ),
        super(
          key: key,
          leading: leading,
          text: title ?? const SizedBox.shrink(),
          trailing: trailing,
          onPressed: onTap,
        );
}
