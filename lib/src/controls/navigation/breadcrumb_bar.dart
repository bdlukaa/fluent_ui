import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

/// The alignment of the chevron icon in the breadcrumb bar.
enum ChevronAlignment {
  /// The chevron icon is aligned to the top of the item.
  top,

  /// The chevron icon is aligned to the center of the item.
  ///
  /// This is the default value.
  center,

  /// The chevron icon is aligned to the bottom of the item.
  bottom;

  /// The cross axis alignment of the chevron icon based on its alignment.
  CrossAxisAlignment get crossAxisAlignment {
    switch (this) {
      case ChevronAlignment.top:
        return CrossAxisAlignment.start;
      case ChevronAlignment.center:
        return CrossAxisAlignment.center;
      case ChevronAlignment.bottom:
        return CrossAxisAlignment.end;
    }
  }
}

/// A builder for the chevron icon.
///
/// The builder should return a widget that will be displayed as the chevron icon.
///
/// See also:
///
/// * [ChevronAlignment], the alignment of the chevron icon.
/// * [BreadcrumbBar], the widget that uses this builder.
typedef ChevronIconBuilder = Widget Function(BuildContext context, int index);

/// A item in the breadcrumb bar.
///
/// The item contains a label and a value.
///
/// See also:
///
/// * [BreadcrumbBar], the widget that uses this item.
@immutable
class BreadcrumbItem<T> {
  /// The label of the item
  ///
  /// Usually a [Text] widget.
  final Widget label;

  /// The value of the item
  final T value;

  /// Creates a [BreadcrumbItem]
  const BreadcrumbItem({required this.label, required this.value});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BreadcrumbItem &&
        other.label == label &&
        other.value == value;
  }

  @override
  int get hashCode => label.hashCode ^ value.hashCode;
}

/// A navigation trail showing the path to the current location.
///
/// [BreadcrumbBar] displays a horizontal list of items representing the
/// user's navigation path, such as folders in a file system. Users can click
/// any item to navigate back to that location.
///
/// ![BreadcrumbBar showcase](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/breadcrumbbar-default.gif)
///
/// {@tool snippet}
/// This example shows a basic breadcrumb bar:
///
/// ```dart
/// BreadcrumbBar<String>(
///   items: [
///     BreadcrumbItem(label: Text('Home'), value: '/'),
///     BreadcrumbItem(label: Text('Documents'), value: '/documents'),
///     BreadcrumbItem(label: Text('Reports'), value: '/documents/reports'),
///   ],
///   onItemPressed: (item) {
///     // Navigate to item.value
///   },
/// )
/// ```
/// {@end-tool}
///
/// ## Overflow behavior
///
/// When items don't fit the available width, an overflow button appears
/// that shows the hidden items in a flyout menu.
///
/// See also:
///
///  * [BreadcrumbItem], the data model for breadcrumb items
///  * [NavigationView], for app-level navigation
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/breadcrumbbar>
class BreadcrumbBar<T> extends StatefulWidget {
  /// The items rendered in the bar.
  ///
  /// If the items overflow the available space, a overflow button will be shown.
  final List<BreadcrumbItem<T>> items;

  /// Overrides the default overflow button builder.
  ///
  /// Use the [openFlyout] argument to open the overflow flyout.
  ///
  /// ```dart
  /// BreadcrumbBar(
  ///   ...,
  ///   overflowButtonBuilder: (context, openFlyout) {
  ///     return IconButton(
  ///       icon: const WindowsIcon(WindowsIcons.more),
  ///       onPressed: openFlyout,
  ///     );
  ///   },
  /// )
  /// ```
  ///
  /// If a custom behavior is needed, use a global key to access the
  /// [FlyoutController] and show the flyout:
  ///
  /// ```dart
  /// final key = GlobalKey<BreadcrumbBarState>();
  ///
  /// BreadcrumbBar(
  ///   key: key,
  ///   ...,
  /// )
  ///
  /// key.currentState.flyoutController.showFlyout<void>(...);
  /// ```
  final Widget Function(BuildContext context, VoidCallback openFlyout)
  overflowButtonBuilder;

  /// Called when an item is pressed.
  final ValueChanged<BreadcrumbItem<T>>? onItemPressed;

  /// The builder for the chevron icon.
  ///
  /// The [index] is the index of the item in the list. If the index is -1,
  /// the chevron is attached to the overflow button.
  final ChevronIconBuilder chevronIconBuilder;

  /// The size of the chevron icon.
  ///
  /// Defaults to 8.0
  final double chevronIconSize;

  /// The alignment of the chevron icon.
  ///
  /// Defaults to [ChevronAlignment.center].
  final ChevronAlignment chevronAlignment;

  /// Creates a breadcrumb bar.
  const BreadcrumbBar({
    required this.items,
    super.key,
    this.overflowButtonBuilder = _defaultOverflowButtonBuilder,
    this.onItemPressed,
    this.chevronIconBuilder = _defaultChevronBuilder,
    this.chevronIconSize = 8.0,
    this.chevronAlignment = ChevronAlignment.center,
  });

  /// The default overflow button builder.
  static Widget _defaultOverflowButtonBuilder(
    BuildContext context,
    VoidCallback openFlyout,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 19),
      child: HoverButton(
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
        onPressed: openFlyout,
        builder: (context, states) {
          final foregroundColor = ButtonThemeData.buttonForegroundColor(
            context,
            states,
          );

          return WindowsIcon(
            WindowsIcons.more,
            color: foregroundColor,
            size: 12,
          );
        },
      ),
    );
  }

  static Widget _defaultChevronBuilder(BuildContext context, int index) {
    final theme = FluentTheme.of(context);
    final textDirection = Directionality.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
      child: Icon(
        textDirection == TextDirection.ltr
            ? FluentIcons.chevron_right
            : FluentIcons.chevron_left,
        color: theme.resources.textFillColorPrimary,
      ),
    );
  }

  @override
  State<BreadcrumbBar<T>> createState() => BreadcrumbBarState();
}

class BreadcrumbBarState<T> extends State<BreadcrumbBar<T>> {
  /// The controller used to show the overflow flyout.
  final flyoutController = FlyoutController();

  Set<int> _overflowedIndexes = {};

  /// The indexes of the overflowed items.
  Set<int> get overflowedIndexes => _overflowedIndexes;

  /// Display the default overflow flyout.
  void showFlyout() {
    final overflowedItems = () sync* {
      for (var i = 0; i < widget.items.length; i++) {
        if (overflowedIndexes.contains(i)) yield widget.items[i];
      }
    }();
    flyoutController.showFlyout<void>(
      barrierColor: Colors.transparent,
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: FlyoutPlacementMode.bottomCenter.resolve(
          Directionality.of(context),
        ),
      ),
      builder: (context) {
        return MenuFlyout(
          items: overflowedItems.map((item) {
            return MenuFlyoutItem(
              text: item.label,
              onPressed: widget.onItemPressed == null
                  ? null
                  : () {
                      widget.onItemPressed!(item);
                      Navigator.of(context).pop();
                    },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
    final textDirection = Directionality.of(context);

    final isReversed = textDirection == TextDirection.rtl;
    final items = isReversed ? widget.items.reversed.toList() : widget.items;

    return _BreadcrumbBar(
      items: items,
      textDirection: textDirection,
      onIndexOverflow: (value) {
        _overflowedIndexes = value.map((index) {
          return items.indexOf(widget.items[index]);
        }).toSet();
      },
      overflowButton: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: widget.chevronAlignment.crossAxisAlignment,
        children: [
          FlyoutTarget(
            controller: flyoutController,
            child: widget.overflowButtonBuilder(context, showFlyout),
          ),
          IconTheme.merge(
            data: IconThemeData(size: widget.chevronIconSize),
            child: widget.chevronIconBuilder(context, -1),
          ),
        ],
      ),
      children: List.generate(items.length, (index) {
        final item = items[index];

        final label = HoverButton(
          onPressed:
              // we do not want to enable click on the last item
              widget.onItemPressed == null || item == widget.items.last
              ? null
              : () => widget.onItemPressed!(item),
          builder: (context, states) {
            final foregroundColor = ButtonThemeData.buttonForegroundColor(
              context,
              states.isDisabled ? {} : states,
            );

            return DefaultTextStyle.merge(
              style: TextStyle(color: foregroundColor),
              child: IconTheme.merge(
                data: IconThemeData(color: foregroundColor),
                child: item.label,
              ),
            );
          },
        );

        // the last item does not have a chevron
        final isLastItem = isReversed ? index == 0 : index == items.length - 1;
        if (isLastItem) return label;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.chevronAlignment.crossAxisAlignment,
          children: [
            label,
            IconTheme.merge(
              data: IconThemeData(size: widget.chevronIconSize),
              child: widget.chevronIconBuilder(context, index),
            ),
          ],
        );
      }),
    );
  }
}

class _BreadcrumbBar<T> extends MultiChildRenderObjectWidget {
  final Widget overflowButton;
  final List<BreadcrumbItem<T>> items;
  final ValueChanged<Set<int>> onIndexOverflow;
  final TextDirection textDirection;

  _BreadcrumbBar({
    required List<Widget> children,
    required this.overflowButton,
    required this.items,
    required this.onIndexOverflow,
    required this.textDirection,
  }) : super(
         children: textDirection == TextDirection.ltr
             ? [overflowButton, ...children]
             : [...children, overflowButton],
       );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBreadcrumbBar(
      items: items,
      onIndexOverflow: onIndexOverflow,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBreadcrumbBar<T> renderObject,
  ) {
    renderObject
      ..items = items
      ..onIndexOverflow = onIndexOverflow
      ..textDirection = textDirection;
  }
}

class _BreadcrumbChild extends ContainerBoxParentData<RenderBox>
    with ContainerParentDataMixin<RenderBox> {
  bool _overflow = false;
}

class RenderBreadcrumbBar<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BreadcrumbChild>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BreadcrumbChild> {
  RenderBreadcrumbBar({
    required List<BreadcrumbItem<T>> items,
    required ValueChanged<Set<int>> onIndexOverflow,
    required TextDirection textDirection,
  }) : _items = items,
       _onIndexOverflow = onIndexOverflow,
       _textDirection = textDirection;

  ValueChanged<Set<int>> _onIndexOverflow;
  ValueChanged<Set<int>> get onIndexOverflow => _onIndexOverflow;
  set onIndexOverflow(ValueChanged<Set<int>> value) {
    if (_onIndexOverflow != value) {
      _onIndexOverflow = value;
      markNeedsLayout();
    }
  }

  List<BreadcrumbItem<T>> _items;
  List<BreadcrumbItem<T>> get items => _items;
  set items(List<BreadcrumbItem<T>> value) {
    if (_items != value) {
      _items = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  RenderBox get overflowButton {
    switch (textDirection) {
      case TextDirection.ltr:
        return firstChild!;
      case TextDirection.rtl:
        return lastChild!;
    }
  }

  Set<int> get overflowedIndexes {
    final indexes = <int>{};
    loopOverChildren((child, childIndex) {
      if (child == overflowButton) return;

      final childParentData = child.parentData! as _BreadcrumbChild;
      if (childParentData._overflow) {
        if (textDirection == TextDirection.ltr) {
          indexes.add(childIndex - 1);
        } else {
          indexes.add(childIndex);
        }
      }
    });
    return indexes;
  }

  void loopOverChildren(
    void Function(RenderBox child, int childIndex) callback, [
    bool? reversed,
  ]) {
    final isReversed = reversed ?? textDirection == TextDirection.rtl;
    var child = isReversed ? lastChild : firstChild;
    var childIndex = isReversed ? childCount - 1 : 0;

    while (child != null) {
      callback(child, childIndex);

      final childParentData = child.parentData! as _BreadcrumbChild;
      if (isReversed) {
        child = childParentData.previousSibling;
        childIndex--;
      } else {
        child = childParentData.nextSibling;
        childIndex++;
      }
    }
  }

  @override
  void performLayout() {
    final childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
    overflowButton.layout(childConstraints, parentUsesSize: true);

    var maxExtent = overflowButton.size.width;
    var realExtent = 0.0; // the extent of only the rendered items;
    var height = 0.0;

    var hasOverflowed = false;
    loopOverChildren((child, childIndex) {
      final childParentData = child.parentData! as _BreadcrumbChild;
      if (child != overflowButton) {
        child.layout(childConstraints, parentUsesSize: true);

        if (child.size.height > height) height = child.size.height;

        if (maxExtent + child.size.width > constraints.maxWidth) {
          childParentData._overflow = true;
          if (!hasOverflowed) {
            hasOverflowed = true;
            realExtent += overflowButton.size.width;
          }
        } else {
          childParentData._overflow = false;
          realExtent += child.size.width;
        }
        // Add to the extent even if the child is hidden to avoid children
        // behind this to be displayed
        maxExtent += child.size.width;
      }
    }, textDirection == TextDirection.ltr);

    if (!hasOverflowed) maxExtent -= overflowButton.size.width;

    var currentOffsetX = (textDirection == TextDirection.rtl
        ? constraints.maxWidth -
              realExtent // align to the end
        : 0.0);
    if (hasOverflowed) {
      if (overflowButton.size.height > height) {
        height = overflowButton.size.height;
      }

      // Adds the offset to the parentData
      loopOverChildren((child, childIndex) {
        final childParentData = child.parentData! as _BreadcrumbChild;
        final freeSpace = height - child.size.height;

        if (!childParentData._overflow || child == overflowButton) {
          childParentData.offset = Offset(currentOffsetX, freeSpace / 2);
          currentOffsetX += child.size.width;
        }
      }, false);
    } else {
      loopOverChildren((child, childIndex) {
        final childParentData = child.parentData! as _BreadcrumbChild;

        if (child != overflowButton) {
          final freeSpace = height - child.size.height;

          childParentData.offset = Offset(currentOffsetX, freeSpace / 2);
          currentOffsetX += child.size.width;
        }
      }, false);
    }

    onIndexOverflow(overflowedIndexes);

    size = Size(
      maxExtent.clamp(constraints.maxWidth, constraints.maxWidth),
      height,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _BreadcrumbChild;

      if ((child == overflowButton && overflowedIndexes.isNotEmpty) ||
          (child != overflowButton && !childParentData._overflow)) {
        context.paintChild(child, offset + childParentData.offset);
      }

      child = childParentData.nextSibling;
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = _BreadcrumbChild();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var hit = false;
    loopOverChildren((child, index) {
      if (hit) return;

      final childParentData = child.parentData! as _BreadcrumbChild;

      if (!(child == overflowButton && overflowedIndexes.isEmpty)) {
        // Hidden children cannot generate a hit
        if (child == overflowButton || !childParentData._overflow) {
          // The x, y parameters have the top left of the node's box as the origin.
          final isHit = result.addWithPaintOffset(
            offset: childParentData.offset,
            position: position,
            hitTest: (result, transformed) {
              assert(transformed == position - childParentData.offset);
              return child.hitTest(result, position: transformed);
            },
          );
          if (isHit) {
            hit = true;
          }
        }
      }
    });
    return hit;
  }
}
