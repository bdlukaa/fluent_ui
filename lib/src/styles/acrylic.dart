import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';

class Acrylic extends StatelessWidget {
  const Acrylic({
    Key? key,
    this.color,
    this.filter,
    this.child,
    this.opacity = 0.8,
    this.width,
    this.height,
    this.padding,
    this.margin,
  }) : super(key: key);

  final Color? color;
  final double opacity;
  final ImageFilter? filter;

  final Widget? child;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final color = (this.color ?? context.theme!.navigationPanelBackgroundColor);
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: AnimatedContainer(
            width: width,
            height: height,
            padding: padding,
            duration: context.theme!.fastAnimationDuration ?? Duration.zero,
            curve: context.theme!.animationCurve ?? standartCurve,
            color: color?.withOpacity(opacity),
            child: child,
          ),
        ),
      ),
    );
  }
}
