import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// Defines constants that specify the preferred location for positioning a
/// flyout derived control relative to a visual element.
///
/// See also:
///
///  * <https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.controls.primitives.flyoutplacementmode>
enum FlyoutPlacementMode {
  /// Preferred location is determined automatically.
  ///
  /// If there is space below, [bottomCenter] is assigned;
  /// If there is space above, [topCenter] is assigned.
  auto,

  /// Preferred location is below the target element.
  bottomCenter,

  /// Preferred location is below the target element, with the left edge of
  /// flyout aligned with left edge of the target element.
  bottomLeft,

  /// Preferred location is below the target element, with the right edge of
  /// flyout aligned with right edge of the target element.
  bottomRight,

  /// Preferred location is to the left of the target element.
  leftTop,

  /// Preferred location is to the left of the target element, with the top edge
  /// of flyout aligned with top edge of the target element.
  leftCenter,

  /// Preferred location is to the left of the target element, with the bottom
  /// edge of flyout aligned with bottom edge of the target element.
  leftBottom,

  /// Preferred location is to the right of the target element.
  rightTop,

  /// Preferred location is to the right of the target element, with the top edge
  /// of flyout aligned with top edge of the target element.
  rightCenter,

  /// Preferred location is to the right of the target element, with the bottom
  /// edge of flyout aligned with bottom edge of the target element.
  rightBottom,

  /// Preferred location is above the target element.
  topCenter,

  /// Preferred location is above the target element, with the left edge of
  /// flyout aligned with left edge of the target element.
  topLeft,

  /// Preferred location is above the target element, with the right edge of
  /// flyout aligned with right edge of the target element.
  topRight,

  /// Fills the entire screen. The child is allowed to position itself.
  full;

  /// Whether the placement is horizontal
  bool get isHorizontal {
    switch (this) {
      case FlyoutPlacementMode.leftTop:
      case FlyoutPlacementMode.leftCenter:
      case FlyoutPlacementMode.leftBottom:
      case FlyoutPlacementMode.rightTop:
      case FlyoutPlacementMode.rightCenter:
      case FlyoutPlacementMode.rightBottom:
        return true;
      default:
        return false;
    }
  }

  /// All the horizontal modes.
  static List<FlyoutPlacementMode> get horizontalPlacements {
    return [
      FlyoutPlacementMode.leftTop,
      FlyoutPlacementMode.leftCenter,
      FlyoutPlacementMode.leftBottom,
      FlyoutPlacementMode.rightTop,
      FlyoutPlacementMode.rightCenter,
      FlyoutPlacementMode.rightBottom,
    ];
  }

  /// The vertical alignment of this placement.
  TextAlignVertical get verticalAlignment {
    switch (this) {
      case FlyoutPlacementMode.topCenter:
      case FlyoutPlacementMode.topLeft:
      case FlyoutPlacementMode.topRight:
      case FlyoutPlacementMode.leftTop:
      case FlyoutPlacementMode.rightTop:
        return TextAlignVertical.top;
      case FlyoutPlacementMode.bottomCenter:
      case FlyoutPlacementMode.bottomLeft:
      case FlyoutPlacementMode.bottomRight:
      case FlyoutPlacementMode.leftBottom:
      case FlyoutPlacementMode.rightBottom:
        return TextAlignVertical.bottom;
      case FlyoutPlacementMode.leftCenter:
      case FlyoutPlacementMode.rightCenter:
      case FlyoutPlacementMode.full:
        return TextAlignVertical.center;
      case FlyoutPlacementMode.auto:
        throw UnsupportedError('Auto mode does not have a vertical alignment');
    }
  }

  /// Returns a new placement mode with the specified vertical alignment.
  FlyoutPlacementMode withVerticalAlignment(
    TextAlignVertical verticalAlignment,
  ) {
    switch (verticalAlignment) {
      case TextAlignVertical.top:
        switch (this) {
          case FlyoutPlacementMode.bottomCenter:
            return FlyoutPlacementMode.topCenter;
          case FlyoutPlacementMode.bottomLeft:
            return FlyoutPlacementMode.topLeft;
          case FlyoutPlacementMode.bottomRight:
            return FlyoutPlacementMode.topRight;
          case FlyoutPlacementMode.leftBottom:
          case FlyoutPlacementMode.leftCenter:
            return FlyoutPlacementMode.leftTop;
          case FlyoutPlacementMode.rightBottom:
          case FlyoutPlacementMode.rightCenter:
            return FlyoutPlacementMode.rightTop;
          case FlyoutPlacementMode.topCenter:
          case FlyoutPlacementMode.topLeft:
          case FlyoutPlacementMode.topRight:
            return this;
          default:
            throw UnsupportedError(
              'Unsupported vertical alignment for $this: $verticalAlignment',
            );
        }
      case TextAlignVertical.center:
        switch (this) {
          case FlyoutPlacementMode.topCenter:
          case FlyoutPlacementMode.bottomCenter:
          case FlyoutPlacementMode.leftCenter:
          case FlyoutPlacementMode.rightCenter:
          case FlyoutPlacementMode.full:
            return this;
          case FlyoutPlacementMode.topLeft:
          case FlyoutPlacementMode.topRight:
            return FlyoutPlacementMode.topCenter;
          case FlyoutPlacementMode.bottomLeft:
          case FlyoutPlacementMode.bottomRight:
            return FlyoutPlacementMode.bottomCenter;
          case FlyoutPlacementMode.leftTop:
          case FlyoutPlacementMode.leftBottom:
            return FlyoutPlacementMode.leftCenter;
          case FlyoutPlacementMode.rightTop:
          case FlyoutPlacementMode.rightBottom:
            return FlyoutPlacementMode.rightCenter;
          default:
            throw UnsupportedError(
              'Unsupported vertical alignment for $this: $verticalAlignment',
            );
        }
      case TextAlignVertical.bottom:
        switch (this) {
          case FlyoutPlacementMode.topCenter:
            return FlyoutPlacementMode.bottomCenter;
          case FlyoutPlacementMode.topLeft:
            return FlyoutPlacementMode.bottomLeft;
          case FlyoutPlacementMode.topRight:
            return FlyoutPlacementMode.bottomRight;
          case FlyoutPlacementMode.leftTop:
          case FlyoutPlacementMode.leftCenter:
            return FlyoutPlacementMode.leftBottom;
          case FlyoutPlacementMode.rightTop:
          case FlyoutPlacementMode.rightCenter:
            return FlyoutPlacementMode.rightBottom;
          case FlyoutPlacementMode.bottomCenter:
          case FlyoutPlacementMode.bottomLeft:
          case FlyoutPlacementMode.bottomRight:
            return this;
          default:
            throw UnsupportedError(
              'Unsupported vertical alignment for $this: $verticalAlignment',
            );
        }
      default:
        throw UnsupportedError(
          'Unsupported vertical alignment $verticalAlignment',
        );
    }
  }

  /// Resolves this placement with the current text [direction]
  ///
  /// Basic usage:
  /// ```dart
  /// controller.showFlyout<void>(
  ///   placementMode: FlyoutPlacementMode.bottomLeft.resolve(Directionality.of(context)),
  /// );
  /// ```
  ///
  /// See also:
  ///
  ///  * [TextDirection], a direction in which text flows.
  FlyoutPlacementMode resolve(TextDirection direction) {
    assert(
      this != FlyoutPlacementMode.auto,
      'Can not resolve directionality of an auto placement',
    );
    final isRtl = direction == TextDirection.rtl;

    switch (this) {
      case FlyoutPlacementMode.bottomCenter:
      case FlyoutPlacementMode.topCenter:
      case FlyoutPlacementMode.full:
        return this;
      case FlyoutPlacementMode.bottomLeft:
        return isRtl ? FlyoutPlacementMode.bottomRight : this;
      case FlyoutPlacementMode.topLeft:
        return isRtl ? FlyoutPlacementMode.topRight : this;
      case FlyoutPlacementMode.bottomRight:
        return isRtl ? FlyoutPlacementMode.bottomLeft : this;
      case FlyoutPlacementMode.topRight:
        return isRtl ? FlyoutPlacementMode.topLeft : this;
      case FlyoutPlacementMode.leftTop:
        return isRtl ? FlyoutPlacementMode.rightTop : this;
      case FlyoutPlacementMode.leftCenter:
        return isRtl ? FlyoutPlacementMode.rightCenter : this;
      case FlyoutPlacementMode.leftBottom:
        return isRtl ? FlyoutPlacementMode.rightBottom : this;
      case FlyoutPlacementMode.rightTop:
        return isRtl ? FlyoutPlacementMode.leftTop : this;
      case FlyoutPlacementMode.rightCenter:
        return isRtl ? FlyoutPlacementMode.leftCenter : this;
      case FlyoutPlacementMode.rightBottom:
        return isRtl ? FlyoutPlacementMode.leftBottom : this;
      case FlyoutPlacementMode.auto:
        return this;
    }
  }

  EdgeInsetsGeometry _getAdditionalOffsetPosition(double additionalOffset) {
    switch (this) {
      case FlyoutPlacementMode.bottomCenter:
      case FlyoutPlacementMode.bottomLeft:
      case FlyoutPlacementMode.bottomRight:
        return EdgeInsets.only(top: additionalOffset);
      case FlyoutPlacementMode.topCenter:
      case FlyoutPlacementMode.topLeft:
      case FlyoutPlacementMode.topRight:
        return EdgeInsets.only(bottom: additionalOffset);
      case FlyoutPlacementMode.leftTop:
      case FlyoutPlacementMode.leftCenter:
      case FlyoutPlacementMode.leftBottom:
        return EdgeInsets.only(right: additionalOffset);
      case FlyoutPlacementMode.rightTop:
      case FlyoutPlacementMode.rightCenter:
      case FlyoutPlacementMode.rightBottom:
        return EdgeInsets.only(left: additionalOffset);
      case FlyoutPlacementMode.auto:
      case FlyoutPlacementMode.full:
        return EdgeInsets.all(additionalOffset);
    }
  }

  /// Gets the available space according to the flyout placement
  BoxConstraints _getAvailableSpace(
    Offset targetOffset,
    Size rootSize,
    double margin,
  ) {
    switch (this) {
      case FlyoutPlacementMode.full:
        return BoxConstraints(
          maxWidth: rootSize.width._ensurePositive(),
          maxHeight: rootSize.height._ensurePositive(),
        );
      case FlyoutPlacementMode.bottomCenter:
      case FlyoutPlacementMode.bottomLeft:
      case FlyoutPlacementMode.bottomRight:
        return BoxConstraints(
          maxWidth: rootSize.width._ensurePositive(),
          maxHeight: (rootSize.height - margin - targetOffset.dy)
              ._ensurePositive(),
        );
      case FlyoutPlacementMode.topCenter:
      case FlyoutPlacementMode.topLeft:
      case FlyoutPlacementMode.topRight:
        return BoxConstraints(
          maxWidth: rootSize.width._ensurePositive(),
          maxHeight: targetOffset.dy._ensurePositive(),
        );
      case FlyoutPlacementMode.leftTop:
      case FlyoutPlacementMode.leftCenter:
      case FlyoutPlacementMode.leftBottom:
        return BoxConstraints(
          maxWidth: targetOffset.dx._ensurePositive(),
          maxHeight: rootSize.height._ensurePositive(),
        );
      case FlyoutPlacementMode.rightTop:
      case FlyoutPlacementMode.rightCenter:
      case FlyoutPlacementMode.rightBottom:
        return BoxConstraints(
          maxWidth: (rootSize.width - targetOffset.dx)._ensurePositive(),
          maxHeight: rootSize.height._ensurePositive(),
        );
      case FlyoutPlacementMode.auto:
        throw UnsupportedError(
          'It is not possible to find the available space of an auto mode',
        );
    }
  }

  FlyoutPlacementMode _assignAutoMode(
    Offset targetOffset,
    Size rootSize,
    double margin,
    FlyoutAutoConfiguration configuration,
  ) {
    assert(this == FlyoutPlacementMode.auto);
    assert(configuration.autoAvailableSpace != null);

    // as = available space

    final availableSpace = configuration.autoAvailableSpace!;

    if (configuration.horizontal) {
      final las = FlyoutPlacementMode.leftCenter
          ._getAvailableSpace(targetOffset, rootSize, margin)
          .biggest;
      final ras = FlyoutPlacementMode.rightCenter
          ._getAvailableSpace(targetOffset, rootSize, margin)
          .biggest;

      if (las.width >= availableSpace && ras.width >= availableSpace) {
        return configuration.preferredMode;
      } else if (las.width >= availableSpace) {
        return FlyoutPlacementMode.leftCenter.withVerticalAlignment(
          configuration.preferredMode.verticalAlignment,
        );
      } else if (ras.width >= availableSpace) {
        return FlyoutPlacementMode.rightCenter.withVerticalAlignment(
          configuration.preferredMode.verticalAlignment,
        );
      } else {
        return configuration.preferredMode;
      }
    }

    // preferred available space
    // we perform this check before all the calculation to save computing time
    final pas = configuration.preferredMode
        ._getAvailableSpace(targetOffset, rootSize, margin)
        .biggest;
    if (pas.height >= availableSpace) {
      return configuration.preferredMode;
    }

    final isLeftPreferred = [
      FlyoutPlacementMode.leftTop,
      FlyoutPlacementMode.leftCenter,
      FlyoutPlacementMode.leftBottom,
      FlyoutPlacementMode.topLeft,
      FlyoutPlacementMode.bottomLeft,
    ].contains(configuration.preferredMode);
    final isCenterPreferred = [
      FlyoutPlacementMode.topCenter,
      FlyoutPlacementMode.bottomCenter,
    ].contains(configuration.preferredMode);
    final isRightPreferred = [
      FlyoutPlacementMode.rightTop,
      FlyoutPlacementMode.rightCenter,
      FlyoutPlacementMode.rightBottom,
      FlyoutPlacementMode.topRight,
      FlyoutPlacementMode.bottomRight,
    ].contains(configuration.preferredMode);

    final bas = FlyoutPlacementMode.bottomCenter
        ._getAvailableSpace(targetOffset, rootSize, margin)
        .biggest;

    if (bas.height >= availableSpace) {
      if (isLeftPreferred) return FlyoutPlacementMode.bottomLeft;
      if (isCenterPreferred) return FlyoutPlacementMode.bottomCenter;
      if (isRightPreferred) return FlyoutPlacementMode.bottomRight;
    }

    final tas = FlyoutPlacementMode.topCenter
        ._getAvailableSpace(targetOffset, rootSize, margin)
        .biggest;

    if (tas.height >= availableSpace) {
      if (isLeftPreferred) return FlyoutPlacementMode.topLeft;
      if (isCenterPreferred) return FlyoutPlacementMode.topCenter;
      if (isRightPreferred) return FlyoutPlacementMode.topRight;
    }

    return configuration.preferredMode;
  }
}

extension on double {
  /// If negative, 0 is returned
  double _ensurePositive() => clampDouble(this, 0, double.infinity);
}

/// Configuration for automatic flyout placement.
///
/// When using [FlyoutPlacementMode.auto], this configuration determines
/// how the flyout position is calculated based on available space.
class FlyoutAutoConfiguration {
  /// The amount of necessary available space.
  ///
  /// If not provided, it falls back to the flyout size.
  final double? autoAvailableSpace;

  /// Whether the flyout should be displayed horizontally.
  ///
  /// If true, [preferredMode] must be either .left or .right.
  final bool horizontal;

  /// The preferred placement mode when auto-positioning.
  final FlyoutPlacementMode preferredMode;

  /// Creates the configuration for flyout auto mode.
  FlyoutAutoConfiguration({
    required this.preferredMode,
    this.autoAvailableSpace,
    bool? horizontal,
  }) : assert(preferredMode != FlyoutPlacementMode.auto),
       assert(
         !(horizontal != null && horizontal) || preferredMode.isHorizontal,
         'If the mode horizontal, preferredMode must either be left or right',
       ),
       assert(autoAvailableSpace == null || !autoAvailableSpace.isNegative),
       horizontal =
           horizontal ??
           FlyoutPlacementMode.horizontalPlacements.contains(preferredMode);
}

/// A delegate for computing the layout of a flyout to be displayed according to
/// a target specified in the global coordinate system.
class _FlyoutPositionDelegate extends SingleChildLayoutDelegate {
  _FlyoutPositionDelegate({
    required this.targetOffset,
    required this.targetSize,
    required this.placementMode,
    required this.margin,
    required this.shouldConstrainToRootBounds,
    required this.forceAvailableSpace,
  });

  final Offset targetOffset;
  final Size targetSize;
  final FlyoutPlacementMode placementMode;
  final double margin;
  final bool shouldConstrainToRootBounds;
  final bool forceAvailableSpace;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    if (forceAvailableSpace) {
      final availableSpace = placementMode
          ._getAvailableSpace(targetOffset, constraints.biggest, margin)
          .biggest;

      return BoxConstraints(
        maxWidth: math.min(availableSpace.width, constraints.biggest.width),
        maxHeight: math.min(availableSpace.height, constraints.biggest.height),
      );
    } else if (placementMode == FlyoutPlacementMode.full) {
      return BoxConstraints(
        minHeight: constraints.biggest.height - margin,
        minWidth: constraints.biggest.width - margin,
        maxWidth: constraints.biggest.width - margin,
        maxHeight: constraints.biggest.height - margin,
      );
    }

    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size rootSize, Size flyoutSize) {
    double clampHorizontal(double x) {
      if (!shouldConstrainToRootBounds) return x;

      final max = rootSize.width - flyoutSize.width - margin;

      return clampDouble(
        x,
        clampDouble(margin, double.negativeInfinity, max),
        max,
      );
    }

    double clampVertical(double y) {
      if (!shouldConstrainToRootBounds) return y;

      return clampDouble(
        y,
        margin,
        (rootSize.height - flyoutSize.height - margin).clamp(
          margin,
          rootSize.height - margin,
        ),
      );
    }

    final topY = clampVertical(
      targetOffset.dy - targetSize.height - flyoutSize.height,
    );

    final bottomY = clampVertical(targetOffset.dy);

    final horizontalTopY = clampVertical(topY + flyoutSize.height);
    final horizontalY = clampVertical(
      targetOffset.dy - targetSize.height / 2 - flyoutSize.height / 2,
    );
    final horizontalBottomY = clampVertical(bottomY - flyoutSize.height);

    final centerX = clampHorizontal(
      (targetOffset.dx + targetSize.width / 2) - (flyoutSize.width / 2.0),
    );

    switch (placementMode) {
      case FlyoutPlacementMode.bottomLeft:
        return Offset(clampHorizontal(targetOffset.dx), bottomY);
      case FlyoutPlacementMode.topLeft:
        return Offset(clampHorizontal(targetOffset.dx), topY);
      case FlyoutPlacementMode.bottomRight:
        return Offset(
          clampHorizontal(
            targetOffset.dx + targetSize.width - flyoutSize.width,
          ),
          bottomY,
        );
      case FlyoutPlacementMode.topRight:
        return Offset(
          clampHorizontal(
            targetOffset.dx + targetSize.width - flyoutSize.width,
          ),
          topY,
        );
      case FlyoutPlacementMode.bottomCenter:
        return Offset(centerX, bottomY);
      case FlyoutPlacementMode.topCenter:
        return Offset(centerX, topY);
      case FlyoutPlacementMode.leftTop:
        return Offset(
          clampHorizontal(targetOffset.dx - flyoutSize.width),
          horizontalTopY,
        );
      case FlyoutPlacementMode.leftCenter:
        return Offset(
          clampHorizontal(targetOffset.dx - flyoutSize.width),
          horizontalY,
        );
      case FlyoutPlacementMode.leftBottom:
        return Offset(
          clampHorizontal(targetOffset.dx - flyoutSize.width),
          horizontalBottomY,
        );
      case FlyoutPlacementMode.rightTop:
        return Offset(
          clampHorizontal(targetOffset.dx + targetSize.width),
          horizontalTopY,
        );
      case FlyoutPlacementMode.rightCenter:
        return Offset(
          clampHorizontal(targetOffset.dx + targetSize.width),
          horizontalY,
        );
      case FlyoutPlacementMode.rightBottom:
        return Offset(
          clampHorizontal(targetOffset.dx + targetSize.width),
          horizontalBottomY,
        );
      case FlyoutPlacementMode.full:
        return Offset(margin, margin);
      case FlyoutPlacementMode.auto:
        // This should not be reached
        return targetOffset;
    }
  }

  @override
  bool shouldRelayout(covariant _FlyoutPositionDelegate oldDelegate) {
    return targetOffset != oldDelegate.targetOffset ||
        placementMode != oldDelegate.placementMode;
  }
}

/// A builder function for creating flyout transition animations.
///
/// The [animation] drives the transition, [placement] indicates where the
/// flyout is positioned, and [child] is the flyout content to animate.
typedef FlyoutTransitionBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      FlyoutPlacementMode placement,
      Widget child,
    );

/// Controls the display and dismissal of flyouts.
///
/// A [FlyoutController] manages the lifecycle of flyout popups. Attach it to
/// a [FlyoutTarget] and use [showFlyout] to display content.
///
/// {@tool snippet}
/// This example shows how to use a flyout controller:
///
/// ```dart
/// final controller = FlyoutController();
///
/// FlyoutTarget(
///   controller: controller,
///   child: Button(
///     child: Text('Show flyout'),
///     onPressed: () {
///       controller.showFlyout<void>(
///         builder: (context) => FlyoutContent(
///           child: Text('Flyout content'),
///         ),
///       );
///     },
///   ),
/// )
/// ```
/// {@end-tool}
///
/// Remember to [dispose] the controller when it's no longer needed.
///
/// See also:
///
///  * [FlyoutTarget], the widget that flyouts attach to
///  * [Flyout], for displaying contextual UI
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/dialogs-and-flyouts/flyouts>
class FlyoutController with ChangeNotifier, WidgetsBindingObserver {
  /// Creates a flyout controller.
  FlyoutController() {
    WidgetsBinding.instance.addObserver(this);
  }

  _FlyoutTargetState? _attachState;

  /// Whether this flyout controller is attached to any [FlyoutTarget]
  bool get isAttached => _attachState != null;

  /// The state of the attached [FlyoutTarget]
  State<FlyoutTarget> get attachState {
    _ensureAttached();
    return _attachState!;
  }

  /// Attaches this controller to a [FlyoutTarget] widget.
  ///
  /// If already attached, the current state is detached and replaced by the
  /// provided [state]
  void _attach(_FlyoutTargetState state) {
    if (_attachState == state) return;
    if (isAttached) _detach();

    _attachState = state;
  }

  void _detach() {
    _ensureAttached();
    _attachState = null;
  }

  /// Makes sure the controller is attached to a [FlyoutTarget]. Usually used
  /// when [_attachState] is necessary
  void _ensureAttached() {
    assert(isAttached, 'This controller must be attached to a FlyoutTarget');
  }

  /// Whether the flyout is open
  ///
  /// See also:
  ///
  ///  * [showFlyout], which opens the flyout
  bool get isOpen => _route != null;

  PageRouteBuilder<void>? _route;

  /// Make sure the flyout is open.
  void _ensureOpen() {
    assert(isOpen, 'The flyout must be open');
  }

  NavigatorState? _currentNavigator;

  /// Shows a flyout.
  ///
  /// [builder] builds the flyout with the given context. Usually a [FlyoutContent]
  /// is used
  ///
  /// {@template fluent_ui.flyouts.barrierDismissible}
  /// If [barrierDismissible] is true, tapping outside of the flyout will close
  /// it.
  /// {@endtemplate}
  ///
  /// [barrierColor] is the color of the barrier.
  ///
  /// {@template fluent_ui.flyouts.dismissWithEsc}
  /// When [dismissWithEsc] is true, the flyout can be dismissed by pressing the
  /// ESC key.
  /// {@endtemplate}
  ///
  /// {@template fluent_ui.flyouts.dismissOnPointerMoveAway}
  /// If [dismissOnPointerMoveAway] is enabled, the flyout is dismissed when the
  /// cursor moves away from either the target or the flyout. It's disabled by
  /// default.
  /// {@endtemplate}
  ///
  /// [placementMode] describes where the flyout will be placed. Defaults to auto
  ///
  /// If [placementMode] is auto, [autoModeConfiguration] is taken in consideration
  /// to determine the correct placement mode
  ///
  /// [forceAvailableSpace] determines whether the flyout size should be forced
  /// the available space according to the attached target. It's useful when the
  /// flyout is large but can not be on top of the target. Defaults to false
  ///
  /// [shouldConstrainToRootBounds], when true, the flyout is limited to the
  /// bounds of the closest [Navigator]. If false, the flyout may overflow the
  /// screen on all sides. Defaults to `true`
  ///
  /// [additionalOffset] is the offset of the flyout around the attached target.
  /// This value can not be negative.
  ///
  /// [horizontalOffset] is the horizontal offset of the flyout around the
  /// attached target. Defaults to 0.0.
  ///
  /// [margin] is the margin of the flyout to the root bounds
  ///
  /// If there isn't a [Navigator] in the tree, a [navigatorKey] can be used to
  /// display the flyout. If null, [Navigator.of] is used.
  ///
  /// [transitionBuilder] builds the transition. By default, a slide-fade transition
  /// is used on vertical directions; and a fade transition in horizontal directions.
  /// The default fade animation can not be disabled.
  ///
  /// [transitionDuration] configures the duration of the transition animation.
  /// By default, [FluentThemeData.fastAnimationDuration] is used. Set to [Duration.zero]
  /// to disable transitions at all.
  ///
  /// [reverseTransitionDuration] configures the duration of the reverse transition
  /// animation. By default, [transitionDuration] is used. Set to [Duration.zero]
  /// to disable transitions at all.
  ///
  /// [transitionCurve] configures the curve of the transition animation.
  ///
  /// [position] lets you position the flyout anywhere on the screen, making it
  /// possible to create context menus. If provided, [placementMode] is ignored.
  ///
  /// [barrierRecognizer] is a gesture recognizer that will be added to the
  /// barrier. It's useful when the flyout is used as a context menu and the
  /// barrier should be dismissed when the user clicks outside of the flyout.
  /// If this is provided, [barrierDismissible] is ignored.
  ///
  /// [buildTarget] is a flag that determines whether the target should be built
  /// or not. This helps when the target needs to be tappable, like the
  /// [CommandBar] or [MenuBar] widgets. Any context dependencies of the target
  /// must be available globally. Defaults to false.
  Future<T?> showFlyout<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    bool dismissWithEsc = true,
    bool dismissOnPointerMoveAway = false,
    FlyoutPlacementMode placementMode = FlyoutPlacementMode.auto,
    FlyoutAutoConfiguration? autoModeConfiguration,
    bool forceAvailableSpace = false,
    bool shouldConstrainToRootBounds = true,
    double additionalOffset = 8.0,
    double horizontalOffset = 0.0,
    double margin = 8.0,
    Color? barrierColor,
    NavigatorState? navigatorKey,
    FlyoutTransitionBuilder? transitionBuilder,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    Curve transitionCurve = Curves.linear,
    Offset? position,
    RouteSettings? settings,
    GestureRecognizer? barrierRecognizer,
    bool buildTarget = false,
  }) async {
    _ensureAttached();
    assert(_attachState!.mounted);

    final context = _attachState!.context;
    assert(debugCheckHasFluentTheme(context));

    final theme = FluentTheme.of(context);
    transitionDuration ??= theme.fastAnimationDuration;
    reverseTransitionDuration ??= transitionDuration;

    _currentNavigator = navigatorKey ?? Navigator.of(context);

    final Offset targetOffset;
    final Size targetSize;
    final Rect targetRect;

    final navigatorBox =
        _currentNavigator!.context.findRenderObject()! as RenderBox;

    final targetBox = context.findRenderObject()! as RenderBox;
    targetSize = targetBox.size;
    targetOffset =
        targetBox.localToGlobal(Offset.zero, ancestor: navigatorBox) +
        Offset(horizontalOffset, targetSize.height);
    targetRect =
        targetBox.localToGlobal(Offset.zero, ancestor: navigatorBox) &
        targetSize;

    final flyoutKey = GlobalKey();
    _route = PageRouteBuilder<T>(
      opaque: false,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      settings: settings,
      fullscreenDialog: true,
      pageBuilder: (context, animation, secondary) {
        transitionBuilder ??= (context, animation, placementMode, flyout) {
          switch (placementMode) {
            case FlyoutPlacementMode.topCenter:
            case FlyoutPlacementMode.topLeft:
            case FlyoutPlacementMode.topRight:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: flyout,
              );
            case FlyoutPlacementMode.bottomCenter:
            case FlyoutPlacementMode.bottomLeft:
            case FlyoutPlacementMode.bottomRight:
            default:
              return ClipRect(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.15),
                    end: Offset.zero,
                  ).animate(animation),
                  child: flyout,
                ),
              );
          }
        };

        return _FlyoutPage(
          navigator: _currentNavigator ?? Navigator.of(context),
          targetRect: targetRect,
          attachState: _attachState,
          targetOffset: targetOffset,
          targetSize: targetSize,
          flyoutKey: flyoutKey,
          navigatorBox: navigatorBox,
          barrierColor: barrierColor,
          barrierRecognizer: barrierRecognizer,
          barrierDismissible: barrierDismissible,
          dismissWithEsc: dismissWithEsc,
          dismissOnPointerMoveAway: dismissOnPointerMoveAway,
          placementMode: placementMode,
          autoModeConfiguration: autoModeConfiguration,
          forceAvailableSpace: forceAvailableSpace,
          shouldConstrainToRootBounds: shouldConstrainToRootBounds,
          additionalOffset: additionalOffset,
          margin: margin,
          transitionBuilder: transitionBuilder!,
          animation: CurvedAnimation(curve: transitionCurve, parent: animation),
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          position: position,
          builder: builder,
          buildTarget: buildTarget,
        );
      },
    );
    notifyListeners();
    final result = await _currentNavigator!.push<T>(
      _route! as PageRouteBuilder<T>,
    );

    _route = _currentNavigator = null;
    if (context.mounted) {
      notifyListeners();
    }

    return result;
  }

  /// Closes the flyout.
  ///
  /// The flyout must be open, otherwise an error is thrown.
  ///
  /// If any other route is pushed above the Flyout, this route is likely to
  /// be closed. It is a good practice to close the flyout before pushing new
  /// routes.
  ///
  /// See also:
  ///
  ///   * [forceClose], which forcefully closes the flyout without completing
  ///     the transition.
  void close<T>([T? result]) {
    _ensureAttached();
    _ensureOpen();
    if (_route == null) return; // safe for release
    _currentNavigator!.maybePop(result);
    _route = _currentNavigator = null;
  }

  /// Forcefully closes the flyout.
  ///
  /// The flyout must be open, otherwise an error is thrown.
  ///
  /// If any other route is pushed above the Flyout, this route is likely to
  /// be closed. It is a good practice to close the flyout before pushing new
  /// routes.
  ///
  /// The flyout will be removed from the navigator stack without completing the
  /// transition.
  ///
  /// See also:
  ///
  ///   * [close], which closes the flyout completing the transition.
  void forceClose() {
    _ensureAttached();
    _ensureOpen();
    if (_route == null) return; // safe for release
    _currentNavigator!.removeRoute(_route!);
    _route = _currentNavigator = null;
  }

  @override
  void didChangeMetrics() {
    if (isOpen) close<void>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// This is a hacky way to calculate the automatic flyout mode and pass it to
/// the [transitionBuilder] callback.
///
/// First, it renders the flyout with a [CustomSingleChildLayout] and, with a
/// callback, gets the parsed mode. Then, it rebuilds only the actual flyout
/// widget using a [StatefulBuilder] and a [GlobalKey], passing the parsed mode
/// to the [transitionBuilder] callback.
class _FlyoutPage extends StatelessWidget {
  const _FlyoutPage({
    required this.navigator,
    required this.targetRect,
    required _FlyoutTargetState? attachState,
    required this.targetOffset,
    required this.targetSize,
    required this.flyoutKey,
    required this.navigatorBox,
    required this.barrierColor,
    required this.barrierRecognizer,
    required this.barrierDismissible,
    required this.dismissWithEsc,
    required this.dismissOnPointerMoveAway,
    required this.placementMode,
    required this.autoModeConfiguration,
    required this.forceAvailableSpace,
    required this.shouldConstrainToRootBounds,
    required this.additionalOffset,
    required this.margin,
    required this.transitionBuilder,
    required this.animation,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    required this.position,
    required this.builder,
    required this.buildTarget,
  }) : _attachState = attachState;

  final NavigatorState navigator;
  final Rect targetRect;
  final _FlyoutTargetState? _attachState;
  final Offset targetOffset;
  final Size targetSize;
  final GlobalKey<State<StatefulWidget>> flyoutKey;
  final RenderBox navigatorBox;
  final Color? barrierColor;
  final GestureRecognizer? barrierRecognizer;
  final bool barrierDismissible;
  final bool dismissWithEsc;
  final bool dismissOnPointerMoveAway;
  final FlyoutPlacementMode placementMode;
  final FlyoutAutoConfiguration? autoModeConfiguration;
  final bool forceAvailableSpace;
  final bool shouldConstrainToRootBounds;
  final double additionalOffset;
  final double margin;
  final FlyoutTransitionBuilder transitionBuilder;
  final Animation<double> animation;
  final Duration? transitionDuration;
  final Duration? reverseTransitionDuration;
  final Offset? position;
  final WidgetBuilder builder;
  final bool buildTarget;

  @override
  Widget build(BuildContext context) {
    return MenuInfoProvider(
      builder: (context, rootSize, menus, keys) {
        assert(menus.length == keys.length);

        final barrier = ColoredBox(
          color: barrierColor ?? Colors.black.withValues(alpha: 0.3),
        );

        FlyoutPlacementMode getAutoPlacementMode(Size flyoutSize) {
          final defaultPreferred = (position == null
              ? FlyoutPlacementMode.topCenter
              : FlyoutPlacementMode.bottomLeft);
          final preferredMode =
              autoModeConfiguration?.preferredMode ?? defaultPreferred;

          return FlyoutPlacementMode.auto._assignAutoMode(
            position ?? targetOffset,
            rootSize.biggest,
            margin,
            FlyoutAutoConfiguration(
              preferredMode: preferredMode,
              horizontal: autoModeConfiguration?.horizontal,
              autoAvailableSpace: () {
                if (autoModeConfiguration?.autoAvailableSpace == null) {
                  if (autoModeConfiguration?.horizontal ?? false) {
                    return flyoutSize.width;
                  } else {
                    return flyoutSize.height;
                  }
                }
                return autoModeConfiguration?.autoAvailableSpace;
              }(),
            ),
          );
        }

        Widget buildFlyout(FlyoutPlacementMode placementMode) {
          return Flyout(
            rootFlyout: flyoutKey,
            additionalOffset: additionalOffset,
            margin: margin,
            transitionDuration: transitionDuration!,
            reverseTransitionDuration: reverseTransitionDuration!,
            root: navigator,
            menuKey: null,
            transitionBuilder: transitionBuilder,
            placementMode: placementMode,
            builder: (context) {
              final Widget flyout = Padding(
                key: flyoutKey,
                padding: placementMode._getAdditionalOffsetPosition(
                  position == null ? additionalOffset : 0.0,
                ),
                child: builder(context),
              );

              return transitionBuilder(
                context,
                animation,
                placementMode,
                flyout,
              );
            },
          );
        }

        Widget box = Stack(
          children: [
            if (barrierRecognizer != null)
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) {
                    barrierRecognizer!.addPointer(event);
                  },
                  child: barrier,
                ),
              )
            else if (barrierDismissible)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: barrierDismissible ? navigator.pop : null,
                  child: barrier,
                ),
              ),
            if (buildTarget)
              Positioned.fromRect(
                rect: targetRect,
                child: _attachState!.build(context),
              ),
            Positioned.fill(
              child: SafeArea(
                child: CustomSingleChildLayout(
                  delegate: _FlyoutPositionDelegate(
                    targetOffset: position ?? targetOffset,
                    targetSize: position == null ? targetSize : Size.zero,
                    placementMode: placementMode == FlyoutPlacementMode.auto
                        ? getAutoPlacementMode(
                            Size.zero,
                          ) // A bit of a hack for the first pass
                        : placementMode,
                    margin: margin,
                    shouldConstrainToRootBounds: shouldConstrainToRootBounds,
                    forceAvailableSpace: forceAvailableSpace,
                  ),
                  child: Builder(
                    builder: (context) {
                      if (placementMode != FlyoutPlacementMode.auto) {
                        return buildFlyout(placementMode);
                      }
                      // Re-calculate with the actual flyout size
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final flyoutSize = constraints.biggest;
                          final realPlacementMode = getAutoPlacementMode(
                            flyoutSize,
                          );
                          return buildFlyout(realPlacementMode);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            ...menus,
          ],
        );

        if (dismissOnPointerMoveAway) {
          box = MouseRegion(
            onHover: (hover) {
              if (flyoutKey.currentContext == null) return;

              final navigatorBox =
                  navigator.context.findRenderObject()! as RenderBox;

              // the flyout box needs to be fetched at each [onHover] because the
              // flyout size may change (a MenuFlyout, for example)
              final flyoutBox =
                  flyoutKey.currentContext!.findRenderObject()! as RenderBox;
              final flyoutRect =
                  flyoutBox.localToGlobal(Offset.zero, ancestor: navigatorBox) &
                  flyoutBox.size;
              final menusRects = keys.map((key) {
                if (key.currentContext == null) return Rect.zero;

                final menuBox =
                    key.currentContext!.findRenderObject()! as RenderBox;
                return menuBox.localToGlobal(
                      Offset.zero,
                      ancestor: navigatorBox,
                    ) &
                    menuBox.size;
              });

              if (!flyoutRect.contains(hover.position) &&
                  !targetRect.contains(hover.position) &&
                  !menusRects.any((rect) => rect.contains(hover.position))) {
                navigator.pop();
              }
            },
            child: box,
          );
        }

        if (dismissWithEsc) {
          box = Actions(
            actions: {DismissIntent: _DismissAction(navigator.pop)},
            child: FocusScope(autofocus: true, child: box),
          );
        }

        return FadeTransition(
          opacity: CurvedAnimation(curve: Curves.ease, parent: animation),
          child: box,
        );
      },
    );
  }
}

class _DismissAction extends DismissAction {
  _DismissAction(this.onDismiss);

  final VoidCallback onDismiss;

  @override
  void invoke(covariant DismissIntent intent) {
    onDismiss();
  }
}

/// See also:
///
///  * [FlyoutController], the controller that displays a flyout attached to the
///    given [child]
class FlyoutTarget extends StatefulWidget {
  /// The controller that displays a flyout attached to the given [child]
  final FlyoutController controller;

  /// The flyout target widget. Flyouts are displayed attached to this
  final Widget child;

  /// Creates a flyout target
  const FlyoutTarget({
    required this.controller,
    required this.child,
    super.key,
  });

  @override
  State<FlyoutTarget> createState() => _FlyoutTargetState();
}

class _FlyoutTargetState extends State<FlyoutTarget> {
  @override
  Widget build(BuildContext context) {
    widget.controller._attach(this);
    return widget.child;
  }
}
