import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Entrance is a combination of a slide up animation and a fade in animation
/// for the incoming content. Use page refresh when the user is taken to the top
/// of a navigational stack, such as navigating between tabs or left-nav items.
///
/// ![EntrancePageTransition showcase](https://docs.microsoft.com/en-us/windows/apps/design/motion/images/page-refresh.gif)
class EntrancePageTransition extends StatelessWidget {
  /// Creates an entrance page transition
  const EntrancePageTransition({
    required this.child,
    required this.animation,
    super.key,
    this.vertical = true,
    this.reverse = false,
    this.startFrom = 0.25,
  });

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
    properties
      ..add(
        FlagProperty(
          'vertical',
          value: vertical,
          ifFalse: 'horizontal',
          defaultValue: true,
        ),
      )
      ..add(
        FlagProperty(
          vertical ? 'from top' : 'from left',
          value: reverse,
          ifTrue: vertical ? 'from bottom' : 'from right',
          defaultValue: false,
        ),
      )
      ..add(
        PercentProperty('animationValue', animation.value, ifNull: 'stopped'),
      );
  }

  @override
  Widget build(BuildContext context) {
    final value = animation.value + (reverse ? -startFrom : startFrom);
    return SlideTransition(
      position: Tween<Offset>(
        begin: vertical ? Offset(0, value) : Offset(value, 0),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

/// Use drill when users navigate deeper into an app, such as displaying more
/// information after selecting an item.
///
/// The desired feeling is that the user has gone deeper into the app.
///
/// ![DrillInPageTransition showcase](https://docs.microsoft.com/en-us/windows/apps/design/motion/images/drill.gif)
class DrillInPageTransition extends StatelessWidget {
  /// Creates a drill in page transition.
  const DrillInPageTransition({
    required this.child,
    required this.animation,
    super.key,
  });

  /// The widget to be animated
  final Widget child;

  /// The animation to drive this transition
  final Animation<double> animation;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      PercentProperty('animationValue', animation.value, ifNull: 'stopped'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
        child: child,
      ),
    );
  }
}

/// Use horizontal slide to show that sibling pages appear next to each other.
class HorizontalSlidePageTransition extends StatelessWidget {
  /// Creates a horizontal slide page transition.
  const HorizontalSlidePageTransition({
    required this.child,
    required this.animation,
    super.key,
    this.fromLeft = true,
  });

  /// The widget to be animated
  final Widget child;

  /// The animation to drive this transition
  final Animation<double> animation;

  /// Whether this animation should be done from the left or not
  final bool fromLeft;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        PercentProperty('animationValue', animation.value, ifNull: 'stopped'),
      )
      ..add(
        FlagProperty(
          'fromLeft',
          value: fromLeft,
          defaultValue: true,
          ifFalse: 'from right',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final offsetTween = () {
      if (fromLeft) {
        return Tween<Offset>(begin: const Offset(-0.65, 0), end: Offset.zero);
      } else {
        return Tween<Offset>(begin: const Offset(0.65, 0), end: Offset.zero);
      }
    }();
    return SlideTransition(
      position: offsetTween.animate(animation),
      child: child,
    );
  }
}

/// To avoid playing any animation during navigation, use this animation.
class SuppressPageTransition extends StatelessWidget {
  /// Creates a suppress page transition.
  const SuppressPageTransition({required this.child, super.key});

  /// The widget to be animation
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
