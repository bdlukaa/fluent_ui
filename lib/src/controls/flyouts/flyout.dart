import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

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
  left,

  /// Preferred location is to the right of the target element.
  right,

  /// Preferred location is above the target element.
  topCenter,

  /// Preferred location is above the target element, with the left edge of
  /// flyout aligned with left edge of the target element.
  topLeft,

  /// Preferred location is above the target element, with the right edge of
  /// flyout aligned with right edge of the target element.
  topRight;

  /// Resolves this placement with the current text [direction]
  ///
  /// Basic usage:
  /// ```dart
  /// controller.showFlyout(
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
        return this;
      case FlyoutPlacementMode.bottomLeft:
        return isRtl ? FlyoutPlacementMode.bottomRight : this;
      case FlyoutPlacementMode.topLeft:
        return isRtl ? FlyoutPlacementMode.topRight : this;
      case FlyoutPlacementMode.left:
        return isRtl ? FlyoutPlacementMode.right : this;
      case FlyoutPlacementMode.bottomRight:
        return isRtl ? FlyoutPlacementMode.bottomLeft : this;
      case FlyoutPlacementMode.topRight:
        return isRtl ? FlyoutPlacementMode.topLeft : this;
      case FlyoutPlacementMode.right:
        return isRtl ? FlyoutPlacementMode.left : this;
      case FlyoutPlacementMode.auto:
      default:
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
      case FlyoutPlacementMode.left:
        return EdgeInsets.only(right: additionalOffset);
      case FlyoutPlacementMode.right:
        return EdgeInsets.only(left: additionalOffset);
      case FlyoutPlacementMode.auto:
      default:
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
      case FlyoutPlacementMode.bottomCenter:
      case FlyoutPlacementMode.bottomLeft:
      case FlyoutPlacementMode.bottomRight:
        return BoxConstraints(
          maxWidth: rootSize.width._ensurePositive(),
          maxHeight:
              (rootSize.height - margin - targetOffset.dy)._ensurePositive(),
        );
      case FlyoutPlacementMode.topCenter:
      case FlyoutPlacementMode.topLeft:
      case FlyoutPlacementMode.topRight:
        return BoxConstraints(
          maxWidth: rootSize.width._ensurePositive(),
          maxHeight: targetOffset.dy._ensurePositive(),
        );
      case FlyoutPlacementMode.left:
        return BoxConstraints(
          maxWidth: targetOffset.dx._ensurePositive(),
          maxHeight: rootSize.height._ensurePositive(),
        );
      case FlyoutPlacementMode.right:
        return BoxConstraints(
          maxWidth: (rootSize.width - targetOffset.dx)._ensurePositive(),
          maxHeight: rootSize.height._ensurePositive(),
        );
      case FlyoutPlacementMode.auto:
      default:
        throw Exception(
          'Can not find the available space of auto mode',
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

    // as = available space

    final availableSpace = configuration.autoAvailableSpace!;

    if (configuration.horizontal) {
      final las = FlyoutPlacementMode.left
          ._getAvailableSpace(targetOffset, rootSize, margin)
          .biggest;
      final ras = FlyoutPlacementMode.right
          ._getAvailableSpace(targetOffset, rootSize, margin)
          .biggest;

      if (las.width >= availableSpace && ras.width >= availableSpace) {
        return configuration.preferredMode;
      } else if (las.width >= availableSpace) {
        return FlyoutPlacementMode.left;
      } else if (ras.width >= availableSpace) {
        return FlyoutPlacementMode.right;
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
      FlyoutPlacementMode.left,
      FlyoutPlacementMode.topLeft,
      FlyoutPlacementMode.bottomLeft,
    ].contains(configuration.preferredMode);
    final isCenterPreferred = [
      FlyoutPlacementMode.topCenter,
      FlyoutPlacementMode.bottomCenter
    ].contains(configuration.preferredMode);
    final isRightPreferred = [
      FlyoutPlacementMode.right,
      FlyoutPlacementMode.topRight,
      FlyoutPlacementMode.bottomRight
    ].contains(configuration.preferredMode);

    final bas = FlyoutPlacementMode.bottomCenter
        ._getAvailableSpace(
          targetOffset,
          rootSize,
          margin,
        )
        .biggest;

    if (bas.height >= availableSpace) {
      if (isLeftPreferred) return FlyoutPlacementMode.bottomLeft;
      if (isCenterPreferred) return FlyoutPlacementMode.bottomCenter;
      if (isRightPreferred) return FlyoutPlacementMode.bottomRight;
    }

    final tas = FlyoutPlacementMode.topCenter
        ._getAvailableSpace(
          targetOffset,
          rootSize,
          margin,
        )
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

class FlyoutAutoConfiguration {
  /// The amount of necessary available space.
  ///
  /// If not provided, it falls back to the flyout size
  final double? autoAvailableSpace;

  /// Whether the flyout should be displayed horizontally
  ///
  /// If true, [preferredMode] must be either .left or .right
  final bool horizontal;

  /// The preferred mode
  final FlyoutPlacementMode preferredMode;

  /// The configuration for flyout auto mode
  FlyoutAutoConfiguration({
    this.autoAvailableSpace,
    bool? horizontal,
    required this.preferredMode,
  })  : assert(preferredMode != FlyoutPlacementMode.auto),
        assert(
          horizontal != null && horizontal
              ? preferredMode == FlyoutPlacementMode.left ||
                  preferredMode == FlyoutPlacementMode.right
              : true,
          'If the mode horizontal, preferredMode must either be left or right',
        ),
        assert(autoAvailableSpace == null || !autoAvailableSpace.isNegative),
        horizontal = horizontal ??
            [FlyoutPlacementMode.left, FlyoutPlacementMode.right]
                .contains(preferredMode);
}

/// A delegate for computing the layout of a flyout to be displayed according to
/// a target specified in the global coordinate system.
class _FlyoutPositionDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate for computing the layout of a flyout.
  ///
  /// The arguments must not be null.
  _FlyoutPositionDelegate({
    required this.targetOffset,
    required this.targetSize,
    required this.autoModeConfiguration,
    required this.placementMode,
    required this.defaultPreferred,
    required this.margin,
    required this.shouldConstrainToRootBounds,
    required this.forceAvailableSpace,
  });

  final Offset targetOffset;
  final Size targetSize;

  final FlyoutAutoConfiguration? autoModeConfiguration;
  final FlyoutPlacementMode placementMode;
  final FlyoutPlacementMode defaultPreferred;
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
    }

    return constraints.loosen();
  }

  FlyoutPlacementMode? autoPlacementMode;

  @override
  Offset getPositionForChild(Size rootSize, Size flyoutSize) {
    autoPlacementMode = placementMode;

    if (autoPlacementMode == FlyoutPlacementMode.auto) {
      final preferredMode =
          autoModeConfiguration?.preferredMode ?? defaultPreferred;

      autoPlacementMode = autoPlacementMode!._assignAutoMode(
        targetOffset,
        rootSize,
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

    final horizontalY = clampVertical(
      targetOffset.dy - targetSize.height - flyoutSize.height / 4,
    );

    final centerX = clampHorizontal(
      (targetOffset.dx + targetSize.width / 2) - (flyoutSize.width / 2.0),
    );

    switch (autoPlacementMode!) {
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
      case FlyoutPlacementMode.left:
        return Offset(
          clampHorizontal(
            targetOffset.dx - flyoutSize.width,
          ),
          horizontalY,
        );
      case FlyoutPlacementMode.right:
        return Offset(
          clampHorizontal(
            targetOffset.dx + targetSize.width,
          ),
          horizontalY,
        );
      case FlyoutPlacementMode.auto:
      default:
        return targetOffset;
    }
  }

  @override
  bool shouldRelayout(_FlyoutPositionDelegate oldDelegate) {
    return targetOffset != oldDelegate.targetOffset ||
        placementMode != oldDelegate.placementMode;
  }
}

typedef FlyoutTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  FlyoutPlacementMode placement,
  Widget child,
);

/// Controls the state of a flyout
class FlyoutController with ChangeNotifier {
  _FlyoutTargetState? _attachState;
  bool _open = false;

  /// Whether this flyout controller is attached to any [FlyoutTarget]
  bool get isAttached => _attachState != null;

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
  bool get isOpen => _open;

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
  /// [additionalOffset] is the offset of the flyout around the attached target
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
  /// to disable transitions at all
  ///
  /// [position] lets you position the flyout anywhere on the screen, making it
  /// possible to create context menus. If provided, [placementMode] is ignored.
  ///
  /// [barrierRecognizer] is a gesture recognizer that will be added to the
  /// barrier. It's useful when the flyout is used as a context menu and the
  /// barrier should be dismissed when the user clicks outside of the flyout.
  /// If this is provided, [barrierDismissible] is ignored.
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
    double margin = 8.0,
    Color? barrierColor,
    NavigatorState? navigatorKey,
    FlyoutTransitionBuilder? transitionBuilder,
    Duration? transitionDuration,
    Offset? position,
    RouteSettings? settings,
    GestureRecognizer? barrierRecognizer,
  }) async {
    _ensureAttached();
    assert(_attachState!.mounted);

    final context = _attachState!.context;
    assert(debugCheckHasFluentTheme(context));

    final theme = FluentTheme.of(context);
    transitionDuration ??= theme.fastAnimationDuration;

    final navigator = navigatorKey ?? Navigator.of(context);

    final Offset targetOffset;
    final Size targetSize;
    final Rect targetRect;

    if (position != null) {
      targetOffset = position;
      targetSize = Size.zero;
      targetRect = Rect.zero;
    } else {
      final navigatorBox = navigator.context.findRenderObject() as RenderBox;

      final targetBox = context.findRenderObject() as RenderBox;
      targetSize = targetBox.size;
      targetOffset = targetBox.localToGlobal(
            Offset.zero,
            ancestor: navigatorBox,
          ) +
          Offset(0, targetSize.height);
      targetRect = targetBox.localToGlobal(
            Offset.zero,
            ancestor: navigatorBox,
          ) &
          targetSize;
    }

    _open = true;
    notifyListeners();

    final flyoutKey = GlobalKey();

    final result = await navigator.push<T>(PageRouteBuilder<T>(
      opaque: false,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: transitionDuration,
      settings: settings,
      fullscreenDialog: true,
      pageBuilder: (context, animation, secondary) {
        transitionBuilder ??= (context, animation, placementMode, flyout) {
          switch (placementMode) {
            case FlyoutPlacementMode.bottomCenter:
            case FlyoutPlacementMode.bottomLeft:
            case FlyoutPlacementMode.bottomRight:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.05),
                  end: const Offset(0, 0),
                ).animate(animation),
                child: flyout,
              );
            case FlyoutPlacementMode.topCenter:
            case FlyoutPlacementMode.topLeft:
            case FlyoutPlacementMode.topRight:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: const Offset(0, 0),
                ).animate(animation),
                child: flyout,
              );
            default:
              return flyout;
          }
        };

        return MenuInfoProvider(
          builder: (context, rootSize, menus, keys) {
            assert(menus.length == keys.length);

            final barrier = ColoredBox(
              color: barrierColor ?? Colors.black.withOpacity(0.3),
            );

            Widget box = Stack(children: [
              if (barrierRecognizer != null)
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (event) {
                      barrierRecognizer.addPointer(event);
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
              Positioned.fill(
                child: SafeArea(
                  child: CustomSingleChildLayout(
                    delegate: _FlyoutPositionDelegate(
                      targetOffset: targetOffset,
                      targetSize: position == null ? targetSize : Size.zero,
                      autoModeConfiguration: autoModeConfiguration,
                      placementMode: placementMode,
                      defaultPreferred: position == null
                          ? FlyoutPlacementMode.topCenter
                          : FlyoutPlacementMode.bottomLeft,
                      margin: margin,
                      shouldConstrainToRootBounds: shouldConstrainToRootBounds,
                      forceAvailableSpace: forceAvailableSpace,
                    ),
                    child: Flyout(
                      rootFlyout: flyoutKey,
                      additionalOffset: additionalOffset,
                      margin: margin,
                      transitionDuration: transitionDuration!,
                      root: navigator,
                      builder: (context) {
                        final parentBox =
                            context.findAncestorRenderObjectOfType<
                                RenderCustomSingleChildLayoutBox>()!;
                        final delegate =
                            parentBox.delegate as _FlyoutPositionDelegate;

                        final realPlacementMode = delegate.autoPlacementMode ??
                            delegate.placementMode;
                        final flyout = Padding(
                          key: flyoutKey,
                          padding:
                              realPlacementMode._getAdditionalOffsetPosition(
                            position == null ? additionalOffset : 0.0,
                          ),
                          child: builder(context),
                        );

                        return transitionBuilder!(
                          context,
                          animation,
                          realPlacementMode,
                          flyout,
                        );
                      },
                    ),
                  ),
                ),
              ),
              ...menus,
            ]);

            if (dismissOnPointerMoveAway) {
              box = MouseRegion(
                onHover: (hover) {
                  if (flyoutKey.currentContext == null) return;

                  final navigatorBox =
                      navigator.context.findRenderObject() as RenderBox;

                  // the flyout box needs to be fetched at each [onHover] because the
                  // flyout size may change (a MenuFlyout, for example)
                  final flyoutBox =
                      flyoutKey.currentContext!.findRenderObject() as RenderBox;
                  final flyoutRect = flyoutBox.localToGlobal(
                        Offset.zero,
                        ancestor: navigatorBox,
                      ) &
                      flyoutBox.size;
                  final menusRects = keys.map((key) {
                    if (key.currentContext == null) return Rect.zero;

                    final menuBox =
                        key.currentContext!.findRenderObject() as RenderBox;
                    return menuBox.localToGlobal(
                          Offset.zero,
                          ancestor: navigatorBox,
                        ) &
                        menuBox.size;
                  });

                  if (!flyoutRect.contains(hover.position) &&
                      !targetRect.contains(hover.position) &&
                      !menusRects
                          .any((rect) => rect.contains(hover.position))) {
                    navigator.pop();
                  }
                },
                child: box,
              );
            }

            if (dismissWithEsc) {
              box = Actions(
                actions: {DismissIntent: _DismissAction(navigator.pop)},
                child: FocusScope(
                  autofocus: true,
                  child: box,
                ),
              );
            }

            return FadeTransition(
              opacity: CurvedAnimation(
                curve: Curves.ease,
                parent: animation,
              ),
              child: box,
            );
          },
        );
      },
    ));

    _open = false;
    notifyListeners();

    return result;
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
    super.key,
    required this.controller,
    required this.child,
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
