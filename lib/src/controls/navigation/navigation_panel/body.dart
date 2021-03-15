part of 'navigation_panel.dart';

class NavigationPanelBody extends StatelessWidget {
  const NavigationPanelBody({
    Key? key,
    required this.index,
    required this.children,
    this.transitionBuilder,
  }) : super(key: key);

  final List<Widget> children;
  final int index;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration:
          context.theme!.mediumAnimationDuration ?? Duration(milliseconds: 300),
      layoutBuilder: (child, children) {
        return SizedBox(child: child);
      },
      transitionBuilder: (child, animation) {
        if (transitionBuilder != null)
          return transitionBuilder!(child, animation);
        return DrillInPageTransition(
          child: child,
          animation: animation,
        );
      },
      child: IndexedStack(
        key: ValueKey<int>(index),
        index: index,
        children: children,
      ),
    );
  }
}
