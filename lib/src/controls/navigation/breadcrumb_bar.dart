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
}

class BreadcrumbBar extends StatefulWidget {
  final List<BreadcrumbItem> items;
  final Widget overflowButton;

  const BreadcrumbBar({
    super.key,
    required this.items,
    required this.overflowButton,
  });

  @override
  State<BreadcrumbBar> createState() => _BreadcrumbBarState();
}

class _BreadcrumbBarState extends State<BreadcrumbBar> {
  @override
  Widget build(BuildContext context) {
    return _BreadcrumbBar(
      overflowButton: widget.overflowButton,
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];

        if (index == widget.items.length - 1) {
          return item.label;
        }

        return Row(mainAxisSize: MainAxisSize.min, children: [
          item.label,
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 4.0),
            child: Icon(FluentIcons.chevron_right, size: 12.0),
          ),
        ]);
      }),
    );
  }
}

class _BreadcrumbBar extends MultiChildRenderObjectWidget {
  final Widget overflowButton;

  _BreadcrumbBar({
    super.key,
    required List<Widget> children,
    required this.overflowButton,
  }) : super(children: [overflowButton, ...children]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBreadcrumbBar();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBreadcrumbBar renderObject,
  ) {}
}

class _BreadcrumbChild extends ContainerBoxParentData<RenderBox>
    with ContainerParentDataMixin<RenderBox> {}

class RenderBreadcrumbBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BreadcrumbChild>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BreadcrumbChild> {
  RenderBreadcrumbBar();

  Set<int> overflowedIndexes = {};

  @override
  void performLayout() {
    overflowedIndexes.clear();
    final childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
    final overflowButton = firstChild!
      ..layout(childConstraints, parentUsesSize: true);
    var maxExtent = 0.0;

    var child = lastChild;
    var childIndex = childCount - 1;
    while (child != null) {
      if (child == overflowButton) break;
      final childParentData = child.parentData as _BreadcrumbChild;
      child.layout(childConstraints, parentUsesSize: true);

      if (maxExtent + child.size.width > constraints.maxWidth) {
        debugPrint('$childIndex item overflowed');
        // childParentData.offset = Offset(0, 100);
        overflowedIndexes.add(childIndex);
      } else {
        // childParentData.offset = Offset(maxExtent, 0);
        maxExtent += child.size.width;
        // print(child.size.width);
      }

      child = childParentData.previousSibling;
      childIndex--;
    }

    if (overflowedIndexes.isNotEmpty) {
      maxExtent += overflowButton.size.width;
    }

    size = Size(
      maxExtent.clamp(constraints.maxWidth, constraints.maxWidth),
      100.0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var offsetX = 0.0;
    if (overflowedIndexes.isNotEmpty) {
      final overflowButton = firstChild!;
      context.paintChild(overflowButton, offset);
      offsetX += overflowButton.size.width;
    }

    var childIndex = 1;
    var child = (firstChild?.parentData as _BreadcrumbChild?)?.nextSibling;
    while (child != null) {
      final childParentData = child.parentData! as _BreadcrumbChild;
      if (!overflowedIndexes.contains(childIndex)) {
        context.paintChild(child, Offset(offsetX, 0.0) + offset);
        offsetX += child.size.width;
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
    var index = childCount;
    while (child != null) {
      final childParentData = child.parentData! as _BreadcrumbChild;
      // Hidden children cannot generate a hit
      if (!overflowedIndexes.contains(index) || (child == firstChild)) {
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
