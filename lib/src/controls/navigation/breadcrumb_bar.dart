import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class BreadcrumbItem {
  /// The label of the item
  ///
  /// Usually a [Text] widget
  final Widget label;

  /// The value of the item
  final dynamic value;

  /// Creates a [BreadcrumbItem]
  const BreadcrumbItem({
    required this.label,
    required this.value,
  });

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

class BreadcrumbBar extends StatefulWidget {
  final List<BreadcrumbItem> items;
  final Widget Function(
    BuildContext context,
    VoidCallback openFlyout,
  ) overflowButtonBuilder;

  final ValueChanged<BreadcrumbItem>? onChanged;

  const BreadcrumbBar({
    super.key,
    required this.items,
    this.overflowButtonBuilder = _defaultOverflowButtonBuilder,
    this.onChanged,
  });

  static Widget _defaultOverflowButtonBuilder(
    BuildContext context,
    VoidCallback openFlyout,
  ) {
    return IconButton(
      icon: const Icon(FluentIcons.more),
      onPressed: openFlyout,
    );
  }

  @override
  State<BreadcrumbBar> createState() => _BreadcrumbBarState();
}

class _BreadcrumbBarState extends State<BreadcrumbBar> {
  final flyoutController = FlyoutController();

  Set<int> overflowedIndexes = {};

  void _showFlyout() {
    final overflowedItems = () sync* {
      for (var i = 0; i < widget.items.length; i++) {
        // [overflowedIndexes] include the 0 index that represents the overflow
        // button. We add + 1 to the index count because the 0 index can not be
        // included in the flyout items, otherwise the items will be displayed
        // in both the flyout and in the breadcrumb bar
        if (overflowedIndexes.contains(i + 1)) yield widget.items[i];
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
              onPressed: widget.onChanged == null
                  ? null
                  : () {
                      widget.onChanged!(item);
                      Navigator.of(context).pop();
                    },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const chevron = Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 6.0),
      child: Icon(FluentIcons.chevron_right, size: 8.0, color: Colors.white),
    );

    return _BreadcrumbBar(
      items: widget.items,
      onIndexOverflow: (value) {
        overflowedIndexes = value;
      },
      overflowButton: Row(mainAxisSize: MainAxisSize.min, children: [
        FlyoutTarget(
          controller: flyoutController,
          child: widget.overflowButtonBuilder(context, _showFlyout),
        ),
        chevron,
      ]),
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];

        final label = HoverButton(
          onPressed:
              // we do not want to enable click on the last item
              widget.onChanged == null || index == widget.items.length - 1
                  ? null
                  : () => widget.onChanged!(item),
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

        if (index == widget.items.length - 1) {
          return label;
        }

        return Row(mainAxisSize: MainAxisSize.min, children: [label, chevron]);
      }),
    );
  }
}

class _BreadcrumbBar extends MultiChildRenderObjectWidget {
  final Widget overflowButton;
  final List<BreadcrumbItem> items;
  final ValueChanged<Set<int>> onIndexOverflow;

  _BreadcrumbBar({
    required List<Widget> children,
    required this.overflowButton,
    required this.items,
    required this.onIndexOverflow,
  }) : super(children: [overflowButton, ...children]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBreadcrumbBar(items: items, onIndexOverflow: onIndexOverflow);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBreadcrumbBar renderObject,
  ) {
    renderObject
      ..items = items
      ..onIndexOverflow = onIndexOverflow;
  }
}

class _BreadcrumbChild extends ContainerBoxParentData<RenderBox>
    with ContainerParentDataMixin<RenderBox> {}

class RenderBreadcrumbBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BreadcrumbChild>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BreadcrumbChild> {
  RenderBreadcrumbBar({
    required List<BreadcrumbItem> items,
    required ValueChanged<Set<int>> onIndexOverflow,
  })  : _items = items,
        _onIndexOverflow = onIndexOverflow;

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

  Set<int> overflowedIndexes = {};

  @override
  void performLayout() {
    overflowedIndexes.clear();

    final childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
    final overflowButton = firstChild!
      ..layout(childConstraints, parentUsesSize: true);

    var maxExtent = overflowButton.size.width;
    var height = 0.0;

    var child = lastChild;
    var childIndex = childCount - 1;
    while (child != null) {
      if (child == overflowButton) break;
      final childParentData = child.parentData as _BreadcrumbChild;
      child.layout(childConstraints, parentUsesSize: true);

      if (child.size.height > height) height = child.size.height;

      if (maxExtent + child.size.width > constraints.maxWidth) {
        overflowedIndexes.add(childIndex);

        if (overflowedIndexes.length == 1) {
          maxExtent += overflowButton.size.width;
        }
      } else {
        maxExtent += child.size.width;
      }

      child = childParentData.previousSibling;
      childIndex--;
    }

    if (overflowedIndexes.isNotEmpty) {
      if (overflowButton.size.height > height) {
        height = overflowButton.size.height;
      }

      // Adds the offset to the parentData
      child = firstChild;
      childIndex = 0;
      var currentOffsetX = 0.0;
      while (child != null) {
        final childParentData = child.parentData as _BreadcrumbChild;
        final freeSpace = height - child.size.height;

        if (!overflowedIndexes.contains(childIndex) ||
            child == overflowButton) {
          childParentData.offset = Offset(currentOffsetX, freeSpace / 2);
          currentOffsetX += child.size.width;
        }

        child = childParentData.nextSibling;
        childIndex++;
      }
    } else {
      child = (firstChild!.parentData as _BreadcrumbChild).nextSibling;
      var currentOffsetX = 0.0;
      while (child != null) {
        final childParentData = child.parentData as _BreadcrumbChild;
        final freeSpace = height - child.size.height;

        childParentData.offset = Offset(currentOffsetX, freeSpace / 2);
        currentOffsetX += child.size.width;

        child = childParentData.nextSibling;
      }
    }

    onIndexOverflow(overflowedIndexes);

    size = Size(
      maxExtent.clamp(constraints.maxWidth, constraints.maxWidth),
      height,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var childIndex = 0;
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _BreadcrumbChild;

      if ((child == firstChild && overflowedIndexes.isNotEmpty) ||
          (child != firstChild && !overflowedIndexes.contains(childIndex))) {
        context.paintChild(child, childParentData.offset);
      }

      child = childParentData.nextSibling;
      childIndex++;
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = _BreadcrumbChild();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    var index = childCount - 1;
    while (child != null) {
      final childParentData = child.parentData! as _BreadcrumbChild;

      if (child == firstChild && overflowedIndexes.isEmpty) break;

      // Hidden children cannot generate a hit
      if (child == firstChild || !overflowedIndexes.contains(index)) {
        // The x, y parameters have the top left of the node's box as the origin.
        final isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childParentData.offset);
            return child!.hitTest(result, position: transformed);
          },
        );
        if (isHit) return true;
      }
      child = childParentData.previousSibling;
      index--;
    }
    return false;
  }
}
