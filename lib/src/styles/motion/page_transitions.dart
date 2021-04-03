import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class EntrancePageTransition extends StatelessWidget {
  const EntrancePageTransition({
    Key? key,
    required this.child,
    required this.animation,
    this.vertical = true,
    this.reverse = false,
  }) : super(key: key);

  final Widget child;
  final Animation<double> animation;
  final bool vertical;
  final bool reverse;

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
      'reverse',
      value: reverse,
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
    return SlideTransition(
      child: FadeTransition(
        child: child,
        opacity: animation,
      ),
      position: Tween<Offset>(
        begin: vertical
            ? Offset(0, animation.value + (reverse ? -1 : 1))
            : Offset(animation.value + (reverse ? -1 : 1), 0),
        end: Offset.zero,
      ).animate(animation),
    );
  }
}

class DrillInPageTransition extends StatelessWidget {
  const DrillInPageTransition({
    Key? key,
    required this.child,
    required this.animation,
  }) : super(key: key);

  final Widget child;
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
        child: child,
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
      ),
    );
  }
}

class HorizontalSlidePageTransition extends StatelessWidget {
  const HorizontalSlidePageTransition({
    Key? key,
    required this.child,
    required this.animation,
    this.fromLeft = true,
  }) : super(key: key);

  final Widget child;
  final Animation<double> animation;
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
      ifFalse: 'fromRight',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final offsetTween = () {
      if (fromLeft)
        return Tween<Offset>(
          begin: Offset(-1, 0),
          end: Offset.zero,
        );
      else {
        return Tween<Offset>(
          begin: Offset(1, 0),
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

class SuppressPageTransition extends StatelessWidget {
  const SuppressPageTransition({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
