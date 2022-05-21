// Copyright 2022 Bruno D'Luka.
// Portions copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Signature of a function that is called to notify that the children
/// that have been hidden due to overflow has changed.
typedef DynamicOverflowChangedCallback = void Function(
    List<int> hiddenChildren);

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

  DynamicOverflow({
    Key? key,
    this.direction = Axis.horizontal,
    this.alignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
    this.alwaysDisplayOverflowWidget = false,
    this.overflowWidgetAlignment = MainAxisAlignment.end,
    this.overflowChangedCallback,
    required List<Widget> children,
    required Widget overflowWidget,
  }) : super(key: key, children: [...children, overflowWidget]);

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
      BuildContext context, RenderDynamicOverflow renderObject) {
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
    properties.add(EnumProperty<Axis>('direction', direction));
    properties.add(EnumProperty<MainAxisAlignment>('alignment', alignment));
    properties.add(EnumProperty<CrossAxisAlignment>(
        'crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(EnumProperty<VerticalDirection>(
        'verticalDirection', verticalDirection));
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior));
    properties.add(EnumProperty<MainAxisAlignment>(
        'overflowWidgetAlignment', overflowWidgetAlignment));
    properties.add(FlagProperty(
      'alwaysDisplayOverflowWidget',
      value: alwaysDisplayOverflowWidget,
      ifTrue: 'always display overflow widget',
      ifFalse: 'do not always display overflow widget',
    ));
  }
}

/// Parent data for use with [RenderDynamicOverflow].
class DynamicOverflowParentData extends ContainerBoxParentData<RenderBox> {
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
  })  : _direction = direction,
        _alignment = alignment,
        _crossAxisAlignment = crossAxisAlignment,
        _textDirection = textDirection,
        _verticalDirection = verticalDirection,
        _clipBehavior = clipBehavior,
        _overflowWidgetAlignment = overflowWidgetAlignment,
        _alwaysDisplayOverflowWidget = alwaysDisplayOverflowWidget;

  Axis _direction;
  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  MainAxisAlignment _alignment;
  MainAxisAlignment get alignment => _alignment;
  set alignment(MainAxisAlignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  CrossAxisAlignment _crossAxisAlignment;
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
          assert(textDirection != null,
              'Horizontal $runtimeType with multiple children has a null textDirection, so the layout order is undefined.');
          break;
        case Axis.vertical:
          assert(verticalDirection != null,
              'Vertical $runtimeType with multiple children has a null verticalDirection, so the layout order is undefined.');
          break;
      }
    }
    if (alignment == MainAxisAlignment.start ||
        alignment == MainAxisAlignment.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(textDirection != null,
              'Horizontal $runtimeType with alignment $alignment has a null textDirection, so the alignment cannot be resolved.');
          break;
        case Axis.vertical:
          assert(verticalDirection != null,
              'Vertical $runtimeType with alignment $alignment has a null verticalDirection, so the alignment cannot be resolved.');
          break;
      }
    }
    if (crossAxisAlignment == CrossAxisAlignment.start ||
        crossAxisAlignment == CrossAxisAlignment.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(verticalDirection != null,
              'Horizontal $runtimeType with crossAxisAlignment $crossAxisAlignment has a null verticalDirection, so the alignment cannot be resolved.');
          break;
        case Axis.vertical:
          assert(textDirection != null,
              'Vertical $runtimeType with crossAxisAlignment $crossAxisAlignment has a null textDirection, so the alignment cannot be resolved.');
          break;
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
        double width = 0.0;
        RenderBox? child = lastChild;
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
        double width = 0.0;
        double lastChildWidth = 0.0;
        RenderBox? child = firstChild;
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
        double height = 0.0;
        RenderBox? child = lastChild;
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
        double height = 0.0;
        double lastChildHeight = 0.0;
        RenderBox? child = firstChild;
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
      bool flipCrossAxis, double crossAxisExtent, double childCrossAxisExtent) {
    final double freeSpace = crossAxisExtent - childCrossAxisExtent;
    switch (crossAxisAlignment) {
      case CrossAxisAlignment.start:
        return flipCrossAxis ? freeSpace : 0.0;
      case CrossAxisAlignment.end:
        return flipCrossAxis ? 0.0 : freeSpace;
      case CrossAxisAlignment.center:
        return freeSpace / 2.0;
      case CrossAxisAlignment.stretch:
        throw UnsupportedError(
            "CrossAxisAlignment.stretch is not supported by DynamicOverflow");
      case CrossAxisAlignment.baseline:
        throw UnsupportedError(
            "CrossAxisAlignment.baseline is not supported by DynamicOverflow");
    }
  }

  bool _hasVisualOverflow = false;
  // indexes of the children that we hid, excluding the overflow item
  List<int> _hiddenChildren = [];

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeDryLayout(constraints);
  }

  Size _computeDryLayout(BoxConstraints constraints,
      [ChildLayouter layoutChild = ChildLayoutHelper.dryLayoutChild]) {
    final BoxConstraints childConstraints;
    double mainAxisLimit = 0.0;
    switch (direction) {
      case Axis.horizontal:
        childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
        mainAxisLimit = constraints.maxWidth;
        break;
      case Axis.vertical:
        childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
        mainAxisLimit = constraints.maxHeight;
        break;
    }

    // The last item is always the overflow item
    double overflowItemMainAxisExtent = 0.0;
    double overflowItemCrossAxisExtent = 0.0;
    if (lastChild != null) {
      final Size lastChildSize = layoutChild(lastChild!, childConstraints);
      overflowItemMainAxisExtent = _getMainAxisExtent(lastChildSize);
      overflowItemCrossAxisExtent = _getCrossAxisExtent(lastChildSize);
    }

    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    bool overflowed = false;
    RenderBox? child = firstChild;
    while (child != null && child != lastChild) {
      final Size childSize = layoutChild(child, childConstraints);
      final double childMainAxisExtent = _getMainAxisExtent(childSize);
      final double childCrossAxisExtent = _getCrossAxisExtent(childSize);

      // To keep things simpler, always include the extent of the overflow item
      // in the run limit calculation, even if it would not need to be displayed.
      // This results in the overflow item being shown a little bit sooner than
      // is needed in some cases, but that is OK.
      if (mainAxisExtent + childMainAxisExtent + overflowItemMainAxisExtent >
          mainAxisLimit) {
        // This child is not going to be rendered, but the overflow item is.
        mainAxisExtent += overflowItemMainAxisExtent;
        crossAxisExtent =
            math.max(crossAxisExtent, overflowItemCrossAxisExtent);
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
    final BoxConstraints constraints = this.constraints;
    assert(_debugHasNecessaryDirections);
    RenderBox? child = firstChild;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final BoxConstraints childConstraints;
    double mainAxisLimit = 0.0;
    bool flipMainAxis = false;
    bool flipCrossAxis = false;
    switch (direction) {
      case Axis.horizontal:
        childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
        mainAxisLimit = constraints.maxWidth;
        if (textDirection == TextDirection.rtl) flipMainAxis = true;
        if (verticalDirection == VerticalDirection.up) flipCrossAxis = true;
        break;
      case Axis.vertical:
        childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
        mainAxisLimit = constraints.maxHeight;
        if (verticalDirection == VerticalDirection.up) flipMainAxis = true;
        if (textDirection == TextDirection.rtl) flipCrossAxis = true;
        break;
    }

    // The last item is always the overflow item
    double overflowItemMainAxisExtent = 0.0;
    double overflowItemCrossAxisExtent = 0.0;
    if (lastChild != null) {
      lastChild!.layout(childConstraints, parentUsesSize: true);
      overflowItemMainAxisExtent = _getMainAxisExtent(lastChild!.size);
      overflowItemCrossAxisExtent = _getCrossAxisExtent(lastChild!.size);
    }

    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    int childIndex = 0;
    int visibleChildCount = 0;
    bool overflowed = false;
    bool overflowItemVisible = false;
    // Indexes of hidden children. Never includes the index for the
    // overflow item.
    List<int> hiddenChildren = [];
    // First determine how many items will fit into the one run and
    // if there is any overflow.
    while (child != null && child != lastChild) {
      child.layout(childConstraints, parentUsesSize: true);
      final double childMainAxisExtent = _getMainAxisExtent(child.size);
      final double childCrossAxisExtent = _getCrossAxisExtent(child.size);

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
        crossAxisExtent =
            math.max(crossAxisExtent, overflowItemCrossAxisExtent);
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
      final DynamicOverflowParentData childParentData =
          child.parentData! as DynamicOverflowParentData;
      childParentData._isHidden = overflowed;
      child = childParentData.nextSibling;
    }
    if (!overflowed && _alwaysDisplayOverflowWidget) {
      mainAxisExtent += overflowItemMainAxisExtent;
      crossAxisExtent = math.max(crossAxisExtent, overflowItemCrossAxisExtent);
      overflowItemVisible = true;
    }
    if (lastChild != null) {
      final DynamicOverflowParentData overflowItemParentData =
          lastChild!.parentData! as DynamicOverflowParentData;
      overflowItemParentData._isHidden = !overflowItemVisible;
    }
    if (overflowItemVisible) {
      // The overflow item should be counted as visible so that spacing
      // and alignment consider the overflow item as well.
      visibleChildCount += 1;
    }

    double containerMainAxisExtent = 0.0;
    double containerCrossAxisExtent = 0.0;

    switch (direction) {
      case Axis.horizontal:
        size = constraints.constrain(Size(mainAxisExtent, crossAxisExtent));
        containerMainAxisExtent = size.width;
        containerCrossAxisExtent = size.height;
        break;
      case Axis.vertical:
        size = constraints.constrain(Size(crossAxisExtent, mainAxisExtent));
        containerMainAxisExtent = size.height;
        containerCrossAxisExtent = size.width;
        break;
    }

    _hasVisualOverflow = containerMainAxisExtent < mainAxisExtent ||
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

    double crossAxisOffset =
        flipCrossAxis ? (containerCrossAxisExtent - crossAxisExtent) : 0;

    final double mainAxisFreeSpace =
        math.max(0.0, containerMainAxisExtent - mainAxisExtent);
    double childLeadingSpace = 0.0;
    double childBetweenSpace = 0.0;

    switch (alignment) {
      case MainAxisAlignment.start:
        break;
      case MainAxisAlignment.end:
        childLeadingSpace = mainAxisFreeSpace;
        break;
      case MainAxisAlignment.center:
        childLeadingSpace = mainAxisFreeSpace / 2.0;
        break;
      case MainAxisAlignment.spaceBetween:
        childBetweenSpace = visibleChildCount > 1
            ? mainAxisFreeSpace / (visibleChildCount - 1)
            : 0.0;
        break;
      case MainAxisAlignment.spaceAround:
        childBetweenSpace =
            visibleChildCount > 0 ? mainAxisFreeSpace / visibleChildCount : 0.0;
        childLeadingSpace = childBetweenSpace / 2.0;
        break;
      case MainAxisAlignment.spaceEvenly:
        childBetweenSpace = mainAxisFreeSpace / (visibleChildCount + 1);
        childLeadingSpace = childBetweenSpace;
        break;
    }

    double childMainPosition = flipMainAxis
        ? containerMainAxisExtent - childLeadingSpace
        : childLeadingSpace;

    // Enumerate through all items again and calculate their position,
    // now that we know the actual main and cross axis extents and can
    // calculate proper positions given the desired alignment parameters.
    child = firstChild;
    while (child != null) {
      final DynamicOverflowParentData childParentData =
          child.parentData! as DynamicOverflowParentData;

      if (childParentData._isHidden) {
        // Hide the widget by setting its offset to outside of the
        // container's extent, so it will be guaranteed to be cropped...
        childParentData.offset = _getOffset(
            containerMainAxisExtent + 100, containerCrossAxisExtent + 100);
      } else {
        final double childMainAxisExtent = _getMainAxisExtent(child.size);
        final double childCrossAxisExtent = _getCrossAxisExtent(child.size);
        final double childCrossAxisOffset = _getChildCrossAxisOffset(
            flipCrossAxis, crossAxisExtent, childCrossAxisExtent);
        if (flipMainAxis) {
          childMainPosition -= childMainAxisExtent;
        }
        if (child == lastChild) {
          // There is a special layout for the overflow item. We may want
          // it to be aligned at the "opposite side" as this looks visually
          // more consistent
          late double overflowChildMainPosition;
          double endAlignedMainAxisPosition =
              flipMainAxis ? 0 : containerMainAxisExtent - childMainAxisExtent;
          switch (_overflowWidgetAlignment) {
            case MainAxisAlignment.start:
              // we're already in the right spot
              overflowChildMainPosition = childMainPosition;
              break;
            case MainAxisAlignment.center:
              overflowChildMainPosition =
                  (childMainPosition + endAlignedMainAxisPosition) / 2;
              break;
            case MainAxisAlignment.end:
            default:
              overflowChildMainPosition = endAlignedMainAxisPosition;
              break;
          }
          childParentData.offset = _getOffset(overflowChildMainPosition,
              crossAxisOffset + childCrossAxisOffset);
        } else {
          childParentData.offset = _getOffset(
              childMainPosition, crossAxisOffset + childCrossAxisOffset);
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
    RenderBox? child = lastChild;
    while (child != null) {
      final DynamicOverflowParentData childParentData =
          child.parentData! as DynamicOverflowParentData;
      // Hidden children cannot generate a hit
      if (!childParentData._isHidden) {
        // The x, y parameters have the top left of the node's box as the origin.
        final bool isHit = result.addWithPaintOffset(
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
    RenderBox? child = firstChild;
    while (child != null) {
      final DynamicOverflowParentData childParentData =
          child.parentData! as DynamicOverflowParentData;
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
    properties.add(EnumProperty<Axis>('direction', direction));
    properties.add(EnumProperty<MainAxisAlignment>('alignment', alignment));
    properties.add(EnumProperty<CrossAxisAlignment>(
        'crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(EnumProperty<VerticalDirection>(
        'verticalDirection', verticalDirection));
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior));
    properties.add(EnumProperty<MainAxisAlignment>(
        'overflowWidgetAlignment', overflowWidgetAlignment));
    properties.add(FlagProperty(
      'alwaysDisplayOverflowWidget',
      value: alwaysDisplayOverflowWidget,
      ifTrue: 'always display overflow widget',
      ifFalse: 'do not always display overflow widget',
    ));
  }
}
