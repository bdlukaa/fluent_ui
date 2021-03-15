import 'package:fluent_ui/fluent_ui.dart';

class EntrancePageTransition extends StatelessWidget {
  const EntrancePageTransition({
    Key? key,
    required this.child,
    required this.animation,
  }) : super(key: key);

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      child: FadeTransition(
        child: child,
        opacity: animation,
      ),
      position: Tween<Offset>(
        begin: Offset(0, animation.value - 1),
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
