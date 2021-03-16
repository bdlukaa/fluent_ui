import 'package:fluent_ui/fluent_ui.dart';

const kCompactNavigationPanelWidth = 50.0;
const kOpenNavigationPanelWidth = 320.0;

class CompactOpenNavigationPanel extends StatelessWidget {
  const CompactOpenNavigationPanel({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.compact,
    this.onMenuTapped,
    this.menu,
    this.bottom,
  }) : super(key: key);

  final void Function()? onMenuTapped;

  final bool compact;
  final int currentIndex;

  final NavigationPanelMenuItem? menu;
  final List<NavigationPanelItem> items;
  final NavigationPanelItem? bottom;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final itens = ([...this.items]
      ..removeWhere((e) => e.runtimeType != NavigationPanelItem));
    if (compact)
      return Acrylic(
        width: kCompactNavigationPanelWidth,
        child: Column(children: [
          if (menu != null)
            Padding(
              padding: EdgeInsets.only(bottom: 22),
              child: NavigationPanelMenu(
                item: menu!,
                compact: true,
                onTap: onMenuTapped,
              ),
            ),
          Expanded(
            child: ListView(children: [
              ...List.generate(items.length, (index) {
                final item = items[index];
                if (item is NavigationPanelSectionHeader) return SizedBox();
                // Use this to avoid overflow when animation is happening
                return () {
                  if (item is NavigationPanelSectionHeader)
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: DefaultTextStyle(
                        style: context.theme!.typography?.base ??
                            const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                        child: item.label!,
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
                    compact: true,
                  );
                }();
              }),
            ]),
          ),
          if (bottom != null)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: NavigationPanelItemTile(
                item: bottom!,
                selected: false,
                compact: true,
                onTap: bottom!.onTapped,
              ),
            ),
        ]),
      );
    else
      return Acrylic(
        width: kOpenNavigationPanelWidth,
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
            child: ListView(children: [
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
                        style: context.theme!.typography?.base ??
                            const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                        duration: context.theme!.mediumAnimationDuration ??
                            Duration.zero,
                        curve: context.theme!.animationCurve ?? standartCurve,
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
          if (bottom != null)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: NavigationPanelItemTile(
                item: bottom!,
                selected: false,
                compact: false,
                onTap: bottom!.onTapped,
              ),
            ),
        ]),
      );
  }
}
