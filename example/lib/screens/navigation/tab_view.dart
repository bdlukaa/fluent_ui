import 'dart:math';

import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TabViewPage extends ScrollablePage {
  int currentIndex = 0;
  List<Tab>? tabs;

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('TabView'));
  }

  Tab generateTab(int index) {
    late Tab tab;
    tab = Tab(
      text: Text('Document $index'),
      semanticLabel: 'Document #$index',
      body: Container(
        color:
            Colors.accentColors[Random().nextInt(Colors.accentColors.length)],
      ),
      onClosed: () {
        setState(() {
          final tabIndex = tabs!.indexOf(tab);
          tabs!.remove(tab);

          if (tabIndex == currentIndex && currentIndex > 0) {
            currentIndex--;
          }
        });
      },
    );
    return tab;
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    tabs ??= List.generate(3, generateTab);
    return [
      const Text(
        'A control that displays a collection of tabs that can be used to display several documents.',
      ),
      subtitle(
        content: const Text(
            'A TabView with support for adding, closing and rearraging tabs'),
      ),
      Card(
        child: SizedBox(
          height: 400,
          child: TabView(
            tabs: tabs!,
            currentIndex: currentIndex,
            onChanged: (index) => setState(() => currentIndex = index),
            onNewPressed: () {
              setState(() {
                final index = tabs!.length + 1;
                final tab = generateTab(index);
                tabs!.add(tab);
              });
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = tabs!.removeAt(oldIndex);
                tabs!.insert(newIndex, item);

                if (currentIndex == newIndex) {
                  currentIndex = oldIndex;
                } else if (currentIndex == oldIndex) {
                  currentIndex = newIndex;
                }
              });
            },
          ),
        ),
      ),
    ];
  }
}
