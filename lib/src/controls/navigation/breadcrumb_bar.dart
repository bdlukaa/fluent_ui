import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

typedef ChevronIconBuilder<T> = Widget Function(
  BuildContext context,
  int index,
);

class BreadcrumbItem<T> {
  /// The label of the item
  ///
  /// Usually a [Text] widget
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

/// A BreadcrumbBar provides the direct path of pages or folders to the current
/// location. It is often used for situations where the user's navigation trail
/// (in a file system or menu system) needs to be persistently visible and the
/// user may need to go back to a previous location.
///
/// ![BreadcrumbBar showcase](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/breadcrumbbar-default.gif)
///
/// See also:
///
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/breadcrumbbar>
///  * [BreadcrumbItem], which is used to represent an item in the bar.
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
  ///       icon: const Icon(FluentIcons.more),
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
  /// key.currentState.flyoutController.showFlyout(...);
  /// ```
  final Widget Function(
    BuildContext context,
    VoidCallback openFlyout,
  ) overflowButtonBuilder;

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

  /// Creates a breadcrumb bar.
  const BreadcrumbBar({
    super.key,
    required this.items,
    this.overflowButtonBuilder = _defaultOverflowButtonBuilder,
    this.onItemPressed,
    this.chevronIconBuilder = _defaultChevronBuilder,
    this.chevronIconSize = 8.0,
  });

  /// The default overflow button builder.
  static Widget _defaultOverflowButtonBuilder(
    BuildContext context,
    VoidCallback openFlyout,
  ) {
    return HoverButton(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 4.0),
      onPressed: openFlyout,
      builder: (context, states) {
        final foregroundColor = ButtonThemeData.buttonForegroundColor(
          context,
          states,
        );

        return Icon(
          FluentIcons.more,
          color: foregroundColor,
          size: 12.0,
        );
      },
    );
  }

  static Widget _defaultChevronBuilder(BuildContext context, int index) {
    final theme = FluentTheme.of(context);
    final textDirection = Directionality.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6.0),
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
    flyoutController.showFlyout(
      barrierColor: Colors.transparent,
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: FlyoutPlacementMode.bottomCenter,
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
      overflowButton: Row(mainAxisSize: MainAxisSize.min, children: [
        FlyoutTarget(
          controller: flyoutController,
          child: widget.overflowButtonBuilder(context, showFlyout),
        ),
        IconTheme.merge(
          data: IconThemeData(size: widget.chevronIconSize),
          child: widget.chevronIconBuilder(context, -1),
        ),
      ]),
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

        return Row(mainAxisSize: MainAxisSize.min, children: [
          label,
          IconTheme.merge(
            data: IconThemeData(size: widget.chevronIconSize),
            child: widget.chevronIconBuilder(context, index),
          ),
        ]);
      }),
    );
  }
}

class _BreadcrumbBar extends MultiChildRenderObjectWidget {
  final Widget overflowButton;
  final List<BreadcrumbItem> items;
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
    covariant RenderBreadcrumbBar renderObject,
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

class RenderBreadcrumbBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BreadcrumbChild>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BreadcrumbChild> {
  RenderBreadcrumbBar({
    required List<BreadcrumbItem> items,
    required ValueChanged<Set<int>> onIndexOverflow,
    required TextDirection textDirection,
  })  : _items = items,
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

  List<BreadcrumbItem> _items;
  List<BreadcrumbItem> get items => _items;
  set items(List<BreadcrumbItem> value) {
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

      final childParentData = child.parentData as _BreadcrumbChild;
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

      final childParentData = child.parentData as _BreadcrumbChild;
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
      final childParentData = child.parentData as _BreadcrumbChild;
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
        ? constraints.maxWidth - realExtent // align to the end
        : 0.0);
    if (hasOverflowed) {
      if (overflowButton.size.height > height) {
        height = overflowButton.size.height;
      }

      // Adds the offset to the parentData
      loopOverChildren((child, childIndex) {
        final childParentData = child.parentData as _BreadcrumbChild;
        final freeSpace = height - child.size.height;

        if (!childParentData._overflow || child == overflowButton) {
          childParentData.offset = Offset(currentOffsetX, freeSpace / 2);
          currentOffsetX += child.size.width;
        }
      }, false);
    } else {
      loopOverChildren((child, childIndex) {
        final childParentData = child.parentData as _BreadcrumbChild;

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
            hitTest: (BoxHitTestResult result, Offset transformed) {
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
