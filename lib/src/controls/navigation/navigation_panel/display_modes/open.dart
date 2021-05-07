import 'package:fluent_ui/fluent_ui.dart';

const kOpenNavigationPanelWidth = 320.0;

class OpenNavigationPanel extends StatelessWidget {
  const OpenNavigationPanel({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.compact,
    this.onMenuTapped,
    this.menu,
    this.bottom,
    this.useAcrylic = true,
    required this.scrollController,
  }) : super(key: key);

  final void Function()? onMenuTapped;

  final bool compact;
  final int currentIndex;

  final NavigationPanelMenuItem? menu;
  final List<NavigationPanelItem> items;
  final NavigationPanelItem? bottom;

  final bool useAcrylic;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final itens = ([...this.items]
      ..removeWhere((e) => e.runtimeType != NavigationPanelItem));
    return Acrylic(
      enabled: useAcrylic,
      child: Column(children: [
        if (menu != null)
          Padding(
            padding: EdgeInsets.only(bottom: 22),
            child: NavigationPanelMenu(
              item: menu!,
              compact: false,
              onTap: onMenuTapped,
            ),
          ),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            child: ListView(controller: scrollController, children: [
              ...List.generate(items.length, (index) {
                final item = items[index];
                // Use this to avoid overflow when animation is happening
                return () {
                  if (item is NavigationPanelSectionHeader)
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: AnimatedDefaultTextStyle(
                        style: context.theme.typography.base ??
                            const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                        duration: context.theme.mediumAnimationDuration,
                        curve: context.theme.animationCurve,
                        child: item.label!,
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    );
                  else if (item is NavigationPanelTileSeparator) {
                    return Divider();
                  }
                  final index = itens.indexOf(item);
                  return NavigationPanelItemTile(
                    item: item,
                    selected: currentIndex == index,
                    onTap: item.onTapped,
                    compact: false,
                  );
                }();
              }),
            ]),
          ),
        ),
        if (bottom != null)
          Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: NavigationPanelItemTile(
              item: bottom!,
              selected: currentIndex == itens.length,
              compact: false,
              onTap: bottom!.onTapped,
            ),
          ),
      ]),
    );
  }
}
