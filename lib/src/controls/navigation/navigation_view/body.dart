part of 'view.dart';

// class NavigationPanelBody extends StatelessWidget {
//   const NavigationPanelBody({
//     Key? key,
//     required this.index,
//     required this.children,
//     this.transitionBuilder,
//     this.animationCurve,
//     this.animationDuration,
//   }) : super(key: key);

//   final List<Widget> children;
//   final int index;
//   final AnimatedSwitcherTransitionBuilder? transitionBuilder;

//   final Curve? animationCurve;
//   final Duration? animationDuration;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSwitcher(
//       switchInCurve:
//           animationCurve ?? context.maybeTheme?.animationCurve ?? Curves.linear,
//       duration: animationDuration ??
//           context.maybeTheme?.fastAnimationDuration ??
//           Duration(milliseconds: 300),
//       layoutBuilder: (child, children) {
//         return SizedBox(child: child);
//       },
//       transitionBuilder: (child, animation) {
//         if (transitionBuilder != null)
//           return transitionBuilder!(child, animation);
//         return DrillInPageTransition(
//           child: child,
//           animation: animation,
//         );
//       },
//       child: SizedBox(
//         key: ValueKey<int>(index),
//         child: children[index],
//       ),
//     );
//   }
// }
