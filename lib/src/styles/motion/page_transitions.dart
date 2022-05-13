import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Entrance is a combination of a slide up animation and a fade in animation
/// for the incoming content. Use page refresh when the user is taken to the top
/// of a navigational stack, such as navigating between tabs or left-nav items.
///
/// This animation is used by default by [NavigationBody] if display mode is top
class EntrancePageTransition extends StatelessWidget {
  /// Creates an entrance page transition
  const EntrancePageTransition({
    Key? key,
    required this.child,
    required this.animation,
    this.vertical = true,
    this.reverse = false,
    this.startFrom = 0.25,
  }) : super(key: key);

  /// The widget to be animated
  final Widget child;

  /// The animation to drive this transition
  final Animation<double> animation;

  /// Whether the animation should be done vertically or horizontally
  final bool vertical;

  /// Whether the animation should be done from the left or from the right
  final bool reverse;

  /// From where the animation will begin. By default, 0.25 is used.
  ///
  /// If [reverse] is true, `-startFrom` (negative) is used
  final double startFrom;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'vertical',
      value: vertical,
      ifFalse: 'horizontal',
      defaultValue: true,
    ));
    properties.add(FlagProperty(
      vertical ? 'from top' : 'from left',
      value: reverse,
      ifTrue: vertical ? 'from bottom' : 'from right',
      defaultValue: false,
    ));
    properties.add(PercentProperty(
      'animationValue',
      animation.value,
      ifNull: 'stopped',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final value = animation.value + (reverse ? -startFrom : startFrom);
    return SlideTransition(
      position: Tween<Offset>(
        begin: vertical ? Offset(0, value) : Offset(value, 0),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Use drill when users navigate deeper into an app, such as
/// displaying more information after selecting an item.
class DrillInPageTransition extends StatelessWidget {
  /// Creates a drill in page transition.
  const DrillInPageTransition({
    Key? key,
    required this.child,
    required this.animation,
  }) : super(key: key);

  /// The widget to be animated
  final Widget child;

  /// The animation to drive this transition
  final Animation<double> animation;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(PercentProperty(
      'animationValue',
      animation.value,
      ifNull: 'stopped',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }
}

/// Use horizontal slide to show that sibling pages appear
/// next to each other. [NavigationPanel] automatically uses
/// this animation for top nav, but if you are building your
/// own horizontal navigation experience, then you can implement
/// horizontal slide with SlideNavigationTransitionInfo.
class HorizontalSlidePageTransition extends StatelessWidget {
  /// Creates a horizontal slide page transition.
  const HorizontalSlidePageTransition({
    Key? key,
    required this.child,
    required this.animation,
    this.fromLeft = true,
  }) : super(key: key);

  /// The widget to be animated
  final Widget child;

  /// The animation to drive this transition
  final Animation<double> animation;

  /// Whether this animation should be done from the left or not
  final bool fromLeft;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(PercentProperty(
      'animationValue',
      animation.value,
      ifNull: 'stopped',
    ));
    properties.add(FlagProperty(
      'fromLeft',
      value: fromLeft,
      defaultValue: true,
      ifFalse: 'from right',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final offsetTween = () {
      if (fromLeft) {
        return Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        );
      } else {
        return Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        );
      }
    }();
    return SlideTransition(
      position: offsetTween.animate(animation),
      child: child,
    );
  }
}

/// To avoid playing any animation during navigation, use this
/// animation.
class SuppressPageTransition extends StatelessWidget {
  const SuppressPageTransition({Key? key, required this.child})
      : super(key: key);

  /// The widget to be animation
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
