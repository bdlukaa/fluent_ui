// Copyright 2022 Bruno D'Luka.
// Portions copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Signature of a function that is called to notify that the children
/// that have been hidden due to overflow has changed.
typedef DynamicOverflowChangedCallback =
    void Function(List<int> hiddenChildren);

/// Lays out children widgets in a single run, and if there is not
/// room to display them all, it will hide widgets that don't fit,
/// and display the "overflow widget" at the end. Optionally, the
/// "overflow widget" can be displayed all the time. Displaying the
/// overflow widget will take precedence over any children widgets.
///
/// Adapted from [Wrap].
class DynamicOverflow extends MultiChildRenderObjectWidget {
  /// {@macro flutter.widgets.wrap.direction}
  final Axis direction;

  /// {@macro flutter.widgets.wrap.alignment}
  final MainAxisAlignment alignment;

  /// {@macro flutter.widgets.wrap.crossAxisAlignment}
  final CrossAxisAlignment crossAxisAlignment;

  /// {@macro flutter.widgets.wrap.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.wrap.verticalDirection}
  final VerticalDirection verticalDirection;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// The alignment of the overflow widget between the end of the
  /// visible regular children and the end of the container.
  final MainAxisAlignment overflowWidgetAlignment;

  /// Whether or not to always display the overflowWidget, even if
  /// all other widgets are able to be displayed.
  final bool alwaysDisplayOverflowWidget;

  /// Function that is called when the list of children that are
  /// hidden because of the dynamic overflow has changed.
  final DynamicOverflowChangedCallback? overflowChangedCallback;

  /// Creates a dynamic overflow widget.
  DynamicOverflow({
    required List<Widget> children,
    required Widget overflowWidget,
    super.key,
    this.direction = Axis.horizontal,
    this.alignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
    this.alwaysDisplayOverflowWidget = false,
    this.overflowWidgetAlignment = MainAxisAlignment.end,
    this.overflowChangedCallback,
  }) : super(children: [...children, overflowWidget]);

  @override
  RenderDynamicOverflow createRenderObject(BuildContext context) {
    return RenderDynamicOverflow(
      direction: direction,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      verticalDirection: verticalDirection,
      clipBehavior: clipBehavior,
      overflowWidgetAlignment: overflowWidgetAlignment,
      alwaysDisplayOverflowWidget: alwaysDisplayOverflowWidget,
      overflowChangedCallback: overflowChangedCallback,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDynamicOverflow renderObject,
  ) {
    renderObject
      ..direction = direction
      ..alignment = alignment
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..verticalDirection = verticalDirection
      ..clipBehavior = clipBehavior
      ..overflowWidgetAlignment = overflowWidgetAlignment
      ..alwaysDisplayOverflowWidget = alwaysDisplayOverflowWidget
      ..overflowChangedCallback = overflowChangedCallback;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Axis>('direction', direction))
      ..add(EnumProperty<MainAxisAlignment>('alignment', alignment))
      ..add(
        EnumProperty<CrossAxisAlignment>(
          'crossAxisAlignment',
          crossAxisAlignment,
        ),
      )
      ..add(
        EnumProperty<TextDirection>(
          'textDirection',
          textDirection,
          defaultValue: null,
        ),
      )
      ..add(
        EnumProperty<VerticalDirection>('verticalDirection', verticalDirection),
      )
      ..add(EnumProperty<Clip>('clipBehavior', clipBehavior))
      ..add(
        EnumProperty<MainAxisAlignment>(
          'overflowWidgetAlignment',
          overflowWidgetAlignment,
        ),
      )
      ..add(
        FlagProperty(
          'alwaysDisplayOverflowWidget',
          value: alwaysDisplayOverflowWidget,
          ifTrue: 'always display overflow widget',
          ifFalse: 'do not always display overflow widget',
        ),
      );
  }
}

/// Parent data for use with [RenderDynamicOverflow].
class DynamicOverflowParentData extends ContainerBoxParentData<RenderBox> {
  /// Whether this child is currently hidden due to overflow.
  bool _isHidden = false;
}

/// Rendering logic for [DynamicOverflow] widget.
/// Adapted from [RenderWrap].
class RenderDynamicOverflow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DynamicOverflowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DynamicOverflowParentData> {
  RenderDynamicOverflow({
    required Axis direction,
    required MainAxisAlignment alignment,
    required CrossAxisAlignment crossAxisAlignment,
    required TextDirection? textDirection,
    required VerticalDirection verticalDirection,
    required Clip clipBehavior,
    required MainAxisAlignment overflowWidgetAlignment,
    required bool alwaysDisplayOverflowWidget,
    required this.overflowChangedCallback,
  }) : _direction = direction,
       _alignment = alignment,
       _crossAxisAlignment = crossAxisAlignment,
       _textDirection = textDirection,
       _verticalDirection = verticalDirection,
       _clipBehavior = clipBehavior,
       _overflowWidgetAlignment = overflowWidgetAlignment,
       _alwaysDisplayOverflowWidget = alwaysDisplayOverflowWidget;

  Axis _direction;

  /// The direction in which to lay out children.
  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  MainAxisAlignment _alignment;

  /// How children should be placed along the main axis.
  MainAxisAlignment get alignment => _alignment;
  set alignment(MainAxisAlignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  CrossAxisAlignment _crossAxisAlignment;

  /// How children should be placed along the cross axis.
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  TextDirection? _textDirection;
  TextDirection? get textDirection => _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  VerticalDirection? _verticalDirection;
  VerticalDirection? get verticalDirection => _verticalDirection;
  set verticalDirection(VerticalDirection? value) {
    if (_verticalDirection != value) {
      _verticalDirection = value;
      markNeedsLayout();
    }
  }

  Clip _clipBehavior;
  Clip get clipBehavior => _clipBehavior;
  set clipBehavior(Clip value) {
    if (_clipBehavior != value) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  MainAxisAlignment _overflowWidgetAlignment;
  MainAxisAlignment get overflowWidgetAlignment => _overflowWidgetAlignment;
  set overflowWidgetAlignment(MainAxisAlignment value) {
    if (_overflowWidgetAlignment != value) {
      _overflowWidgetAlignment = value;
      markNeedsLayout();
    }
  }

  bool _alwaysDisplayOverflowWidget;
  bool get alwaysDisplayOverflowWidget => _alwaysDisplayOverflowWidget;
  set alwaysDisplayOverflowWidget(bool value) {
    if (_alwaysDisplayOverflowWidget != value) {
      _alwaysDisplayOverflowWidget = value;
      markNeedsLayout();
    }
  }

  DynamicOverflowChangedCallback? overflowChangedCallback;

  bool get _debugHasNecessaryDirections {
    if (firstChild != null && lastChild != firstChild) {
      // i.e. there's more than one child
      switch (direction) {
        case Axis.horizontal:
          assert(
            textDirection != null,
            'Horizontal $runtimeType with multiple children has a null textDirection, so the layout order is undefined.',
          );
        case Axis.vertical:
          assert(
            verticalDirection != null,
            'Vertical $runtimeType with multiple children has a null verticalDirection, so the layout order is undefined.',
          );
      }
    }
    if (alignment == MainAxisAlignment.start ||
        alignment == MainAxisAlignment.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(
            textDirection != null,
            'Horizontal $runtimeType with alignment $alignment has a null textDirection, so the alignment cannot be resolved.',
          );
        case Axis.vertical:
          assert(
            verticalDirection != null,
            'Vertical $runtimeType with alignment $alignment has a null verticalDirection, so the alignment cannot be resolved.',
          );
      }
    }
    if (crossAxisAlignment == CrossAxisAlignment.start ||
        crossAxisAlignment == CrossAxisAlignment.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(
            verticalDirection != null,
            'Horizontal $runtimeType with crossAxisAlignment $crossAxisAlignment has a null verticalDirection, so the alignment cannot be resolved.',
          );
        case Axis.vertical:
          assert(
            textDirection != null,
            'Vertical $runtimeType with crossAxisAlignment $crossAxisAlignment has a null textDirection, so the alignment cannot be resolved.',
          );
      }
    }
    return true;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DynamicOverflowParentData) {
      child.parentData = DynamicOverflowParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        // The min intrinsic width is the width of the last child, which must
        // be the renderbox of the "overflow widget"
        var width = 0.0;
        final child = lastChild;
        if (child != null) {
          width = child.getMinIntrinsicWidth(double.infinity);
        }
        return width;
      case Axis.vertical:
        return computeDryLayout(BoxConstraints(maxHeight: height)).width;
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        // The max intrinsic width is the width of all children, except
        // potentially the last child if we do not always display the
        // "overflow widget"
        var width = 0.0;
        var lastChildWidth = 0.0;
        var child = firstChild;
        while (child != null) {
          lastChildWidth = child.getMaxIntrinsicWidth(double.infinity);
          width += lastChildWidth;
          child = childAfter(child);
        }
        if (!alwaysDisplayOverflowWidget && lastChild != null) {
          // we don't have to display the overflow item if
          // all other items are visible
          width -= lastChildWidth;
        }
        return width;
      case Axis.vertical:
        return computeDryLayout(BoxConstraints(maxHeight: height)).width;
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return computeDryLayout(BoxConstraints(maxWidth: width)).height;
      case Axis.vertical:
        // The min intrinsic height is the height of the last child, which must
        // be the renderbox of the "overflow widget"
        var height = 0.0;
        final child = lastChild;
        if (child != null) {
          height = child.getMinIntrinsicHeight(double.infinity);
        }
        return height;
    }
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return computeDryLayout(BoxConstraints(maxWidth: width)).height;
      case Axis.vertical:
        // The max intrinsic height is the height of all children, except
        // potentially the last child if we do not always display the
        // "overflow widget"
        var height = 0.0;
        var lastChildHeight = 0.0;
        var child = firstChild;
        while (child != null) {
          lastChildHeight = child.getMaxIntrinsicHeight(double.infinity);
          height += lastChildHeight;
          child = childAfter(child);
        }
        if (!alwaysDisplayOverflowWidget && lastChild != null) {
          // we don't have to display the overflow item if
          // all other items are visible
          height -= lastChildHeight;
        }
        return height;
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  double _getMainAxisExtent(Size childSize) {
    switch (direction) {
      case Axis.horizontal:
        return childSize.width;
      case Axis.vertical:
        return childSize.height;
    }
  }

  double _getCrossAxisExtent(Size childSize) {
    switch (direction) {
      case Axis.horizontal:
        return childSize.height;
      case Axis.vertical:
        return childSize.width;
    }
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    switch (direction) {
      case Axis.horizontal:
        return Offset(mainAxisOffset, crossAxisOffset);
      case Axis.vertical:
        return Offset(crossAxisOffset, mainAxisOffset);
    }
  }

  double _getChildCrossAxisOffset(
    bool flipCrossAxis,
    double crossAxisExtent,
    double childCrossAxisExtent,
  ) {
    final freeSpace = crossAxisExtent - childCrossAxisExtent;
    switch (crossAxisAlignment) {
      case CrossAxisAlignment.start:
        return flipCrossAxis ? freeSpace : 0.0;
      case CrossAxisAlignment.end:
        return flipCrossAxis ? 0.0 : freeSpace;
      case CrossAxisAlignment.center:
        return freeSpace / 2.0;
      case CrossAxisAlignment.stretch:
        throw UnsupportedError(
          'CrossAxisAlignment.stretch is not supported by DynamicOverflow',
        );
      case CrossAxisAlignment.baseline:
        throw UnsupportedError(
          'CrossAxisAlignment.baseline is not supported by DynamicOverflow',
        );
    }
  }

  bool _hasVisualOverflow = false;
  // indexes of the children that we hid, excluding the overflow item
  List<int> _hiddenChildren = [];

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeDryLayout(constraints);
  }

  Size _computeDryLayout(
    BoxConstraints constraints, [
    ChildLayouter layoutChild = ChildLayoutHelper.dryLayoutChild,
  ]) {
    final BoxConstraints childConstraints;
    var mainAxisLimit = 0.0;
    switch (direction) {
      case Axis.horizontal:
        childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
        mainAxisLimit = constraints.maxWidth;
      case Axis.vertical:
        childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
        mainAxisLimit = constraints.maxHeight;
    }

    // The last item is always the overflow item
    var overflowItemMainAxisExtent = 0.0;
    var overflowItemCrossAxisExtent = 0.0;
    if (lastChild != null) {
      final lastChildSize = layoutChild(lastChild!, childConstraints);
      overflowItemMainAxisExtent = _getMainAxisExtent(lastChildSize);
      overflowItemCrossAxisExtent = _getCrossAxisExtent(lastChildSize);
    }

    var mainAxisExtent = 0.0;
    var crossAxisExtent = 0.0;
    var overflowed = false;
    var child = firstChild;
    while (child != null && child != lastChild) {
      final childSize = layoutChild(child, childConstraints);
      final childMainAxisExtent = _getMainAxisExtent(childSize);
      final childCrossAxisExtent = _getCrossAxisExtent(childSize);

      // To keep things simpler, always include the extent of the overflow item
      // in the run limit calculation, even if it would not need to be displayed.
      // This results in the overflow item being shown a little bit sooner than
      // is needed in some cases, but that is OK.
      if (mainAxisExtent + childMainAxisExtent + overflowItemMainAxisExtent >
          mainAxisLimit) {
        // This child is not going to be rendered, but the overflow item is.
        mainAxisExtent += overflowItemMainAxisExtent;
        crossAxisExtent = math.max(
          crossAxisExtent,
          overflowItemCrossAxisExtent,
        );
        overflowed = true;
        break;
      }
      mainAxisExtent += childMainAxisExtent;
      crossAxisExtent = math.max(crossAxisExtent, childCrossAxisExtent);
      child = childAfter(child);
    }
    if (!overflowed && _alwaysDisplayOverflowWidget) {
      mainAxisExtent += overflowItemMainAxisExtent;
      crossAxisExtent = math.max(crossAxisExtent, overflowItemCrossAxisExtent);
    }

    switch (direction) {
      case Axis.horizontal:
        return constraints.constrain(Size(mainAxisExtent, crossAxisExtent));
      case Axis.vertical:
        return constraints.constrain(Size(crossAxisExtent, mainAxisExtent));
    }
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    assert(_debugHasNecessaryDirections);
    var child = firstChild;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final BoxConstraints childConstraints;
    var mainAxisLimit = 0.0;
    var flipMainAxis = false;
    var flipCrossAxis = false;
    switch (direction) {
      case Axis.horizontal:
        childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
        mainAxisLimit = constraints.maxWidth;
        if (textDirection == TextDirection.rtl) flipMainAxis = true;
        if (verticalDirection == VerticalDirection.up) flipCrossAxis = true;
      case Axis.vertical:
        childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
        mainAxisLimit = constraints.maxHeight;
        if (verticalDirection == VerticalDirection.up) flipMainAxis = true;
        if (textDirection == TextDirection.rtl) flipCrossAxis = true;
    }

    // The last item is always the overflow item
    var overflowItemMainAxisExtent = 0.0;
    var overflowItemCrossAxisExtent = 0.0;
    if (lastChild != null) {
      lastChild!.layout(childConstraints, parentUsesSize: true);
      overflowItemMainAxisExtent = _getMainAxisExtent(lastChild!.size);
      overflowItemCrossAxisExtent = _getCrossAxisExtent(lastChild!.size);
    }

    var mainAxisExtent = 0.0;
    var crossAxisExtent = 0.0;
    var childIndex = 0;
    var visibleChildCount = 0;
    var overflowed = false;
    var overflowItemVisible = false;
    // Indexes of hidden children. Never includes the index for the
    // overflow item.
    final hiddenChildren = <int>[];
    // First determine how many items will fit into the one run and
    // if there is any overflow.
    while (child != null && child != lastChild) {
      child.layout(childConstraints, parentUsesSize: true);
      final childMainAxisExtent = _getMainAxisExtent(child.size);
      final childCrossAxisExtent = _getCrossAxisExtent(child.size);

      // To keep things simpler, always include the extent of the overflow item
      // in the run limit calculation, even if it would not need to be displayed.
      // This results in the overflow item being shown a little bit sooner than
      // is needed in some cases, but that is OK.
      if (overflowed) {
        hiddenChildren.add(childIndex);
      } else if (mainAxisExtent +
              childMainAxisExtent +
              overflowItemMainAxisExtent >
          mainAxisLimit) {
        // This child is not going to be rendered, but the overflow item is.
        mainAxisExtent += overflowItemMainAxisExtent;
        crossAxisExtent = math.max(
          crossAxisExtent,
          overflowItemCrossAxisExtent,
        );
        overflowItemVisible = true;
        overflowed = true;
        hiddenChildren.add(childIndex);
        // Don't break since we are obligated to call layout for all
        // children via the contract of performLayout.
      } else {
        mainAxisExtent += childMainAxisExtent;
        crossAxisExtent = math.max(crossAxisExtent, childCrossAxisExtent);
        visibleChildCount += 1;
      }

      childIndex += 1;
      final childParentData = (child.parentData! as DynamicOverflowParentData)
        .._isHidden = overflowed;
      child = childParentData.nextSibling;
    }
    if (!overflowed && _alwaysDisplayOverflowWidget) {
      mainAxisExtent += overflowItemMainAxisExtent;
      crossAxisExtent = math.max(crossAxisExtent, overflowItemCrossAxisExtent);
      overflowItemVisible = true;
    }
    if (lastChild != null) {
      (lastChild!.parentData! as DynamicOverflowParentData)._isHidden =
          !overflowItemVisible;
    }
    if (overflowItemVisible) {
      // The overflow item should be counted as visible so that spacing
      // and alignment consider the overflow item as well.
      visibleChildCount += 1;
    }

    var containerMainAxisExtent = 0.0;
    var containerCrossAxisExtent = 0.0;

    switch (direction) {
      case Axis.horizontal:
        size = constraints.constrain(Size(mainAxisExtent, crossAxisExtent));
        containerMainAxisExtent = size.width;
        containerCrossAxisExtent = size.height;
      case Axis.vertical:
        size = constraints.constrain(Size(crossAxisExtent, mainAxisExtent));
        containerMainAxisExtent = size.height;
        containerCrossAxisExtent = size.width;
    }

    _hasVisualOverflow =
        containerMainAxisExtent < mainAxisExtent ||
        containerCrossAxisExtent < crossAxisExtent;

    // Notify callback if the children we've hidden has changed
    if (!listEquals(_hiddenChildren, hiddenChildren)) {
      _hiddenChildren = hiddenChildren;
      if (overflowChangedCallback != null) {
        // This will likely trigger setState in a parent widget,
        // so schedule to happen at the end of the frame...
        SchedulerBinding.instance.addPostFrameCallback((_) {
          overflowChangedCallback!(hiddenChildren);
        });
      }
    }

    // Calculate alignment parameters based on the axis extents.

    final crossAxisOffset = flipCrossAxis
        ? (containerCrossAxisExtent - crossAxisExtent)
        : 0;

    final double mainAxisFreeSpace = math.max(
      0,
      containerMainAxisExtent - mainAxisExtent,
    );
    var childLeadingSpace = 0.0;
    var childBetweenSpace = 0.0;

    switch (alignment) {
      case MainAxisAlignment.start:
        break;
      case MainAxisAlignment.end:
        childLeadingSpace = mainAxisFreeSpace;
      case MainAxisAlignment.center:
        childLeadingSpace = mainAxisFreeSpace / 2.0;
      case MainAxisAlignment.spaceBetween:
        childBetweenSpace = visibleChildCount > 1
            ? mainAxisFreeSpace / (visibleChildCount - 1)
            : 0.0;
      case MainAxisAlignment.spaceAround:
        childBetweenSpace = visibleChildCount > 0
            ? mainAxisFreeSpace / visibleChildCount
            : 0.0;
        childLeadingSpace = childBetweenSpace / 2.0;
      case MainAxisAlignment.spaceEvenly:
        childBetweenSpace = mainAxisFreeSpace / (visibleChildCount + 1);
        childLeadingSpace = childBetweenSpace;
    }

    var childMainPosition = flipMainAxis
        ? containerMainAxisExtent - childLeadingSpace
        : childLeadingSpace;

    // Enumerate through all items again and calculate their position,
    // now that we know the actual main and cross axis extents and can
    // calculate proper positions given the desired alignment parameters.
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as DynamicOverflowParentData;

      if (childParentData._isHidden) {
        // Hide the widget by setting its offset to outside of the
        // container's extent, so it will be guaranteed to be cropped...
        childParentData.offset = _getOffset(
          containerMainAxisExtent + 100,
          containerCrossAxisExtent + 100,
        );
      } else {
        final childMainAxisExtent = _getMainAxisExtent(child.size);
        final childCrossAxisExtent = _getCrossAxisExtent(child.size);
        final childCrossAxisOffset = _getChildCrossAxisOffset(
          flipCrossAxis,
          crossAxisExtent,
          childCrossAxisExtent,
        );
        if (flipMainAxis) {
          childMainPosition -= childMainAxisExtent;
        }
        if (child == lastChild) {
          // There is a special layout for the overflow item. We may want
          // it to be aligned at the "opposite side" as this looks visually
          // more consistent
          late double overflowChildMainPosition;
          final endAlignedMainAxisPosition = flipMainAxis
              ? 0.0
              : containerMainAxisExtent - childMainAxisExtent;
          switch (_overflowWidgetAlignment) {
            case MainAxisAlignment.start:
              // we're already in the right spot
              overflowChildMainPosition = childMainPosition;
            case MainAxisAlignment.center:
              overflowChildMainPosition =
                  (childMainPosition + endAlignedMainAxisPosition) / 2;
            case MainAxisAlignment.end:
            default:
              overflowChildMainPosition = endAlignedMainAxisPosition;
          }
          childParentData.offset = _getOffset(
            overflowChildMainPosition,
            crossAxisOffset + childCrossAxisOffset,
          );
        } else {
          childParentData.offset = _getOffset(
            childMainPosition,
            crossAxisOffset + childCrossAxisOffset,
          );
        }
        if (flipMainAxis) {
          childMainPosition -= childBetweenSpace;
        } else {
          childMainPosition += childMainAxisExtent + childBetweenSpace;
        }
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final childParentData = child.parentData! as DynamicOverflowParentData;
      // Hidden children cannot generate a hit
      if (!childParentData._isHidden) {
        // The x, y parameters have the top left of the node's box as the origin.
        final isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (result, transformed) {
            assert(transformed == position - childParentData.offset);
            return child!.hitTest(result, position: transformed);
          },
        );
        if (isHit) return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasVisualOverflow && clipBehavior != Clip.none) {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        _paintSkipHiddenChildren,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      _paintSkipHiddenChildren(context, offset);
    }
  }

  void _paintSkipHiddenChildren(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as DynamicOverflowParentData;
      if (!childParentData._isHidden) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Axis>('direction', direction))
      ..add(EnumProperty<MainAxisAlignment>('alignment', alignment))
      ..add(
        EnumProperty<CrossAxisAlignment>(
          'crossAxisAlignment',
          crossAxisAlignment,
        ),
      )
      ..add(
        EnumProperty<TextDirection>(
          'textDirection',
          textDirection,
          defaultValue: null,
        ),
      )
      ..add(
        EnumProperty<VerticalDirection>('verticalDirection', verticalDirection),
      )
      ..add(EnumProperty<Clip>('clipBehavior', clipBehavior))
      ..add(
        EnumProperty<MainAxisAlignment>(
          'overflowWidgetAlignment',
          overflowWidgetAlignment,
        ),
      )
      ..add(
        FlagProperty(
          'alwaysDisplayOverflowWidget',
          value: alwaysDisplayOverflowWidget,
          ifTrue: 'always display overflow widget',
          ifFalse: 'do not always display overflow widget',
        ),
      );
  }
}
