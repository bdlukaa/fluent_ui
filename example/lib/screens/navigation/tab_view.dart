import 'dart:math';

import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TabViewPage extends ScrollablePage {
  int currentIndex = 0;
  List<Tab>? tabs;
  List<Widget>? bodies;

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('TabView'));
  }

  Tab generateTab(int index) {
    late Tab tab;
    tab = Tab(
      text: Text('Document $index'),
      semanticLabel: 'Document #$index',
      onClosed: () {
        setState(() {
          final closedIndex = tabs!.indexOf(tab);
          tabs!.remove(tab);
          bodies!.removeAt(closedIndex);
          if (currentIndex >= closedIndex && currentIndex > 0) {
            currentIndex--;
          }
        });
      },
    );
    return tab;
  }

  Widget generateBody(index) {
    return Container(
      color: Colors.accentColors[Random().nextInt(Colors.accentColors.length)],
    );
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    tabs ??= List.generate(3, generateTab);
    bodies ??= List.generate(3, generateBody);
    return [
      const Text(
        'A control that displays a collection of tabs that can be used to display several documents.',
      ),
      subtitle(
          content: const Text(
              'A TabView with support for adding, closing and rearraging tabs')),
      Card(
        child: SizedBox(
          height: 400,
          child: TabView(
            tabs: tabs!,
            bodies: bodies!,
            currentIndex: currentIndex,
            onChanged: (index) => setState(() => currentIndex = index),
            onNewPressed: () {
              setState(() {
                final index = tabs!.length;
                tabs!.add(generateTab(index));
                bodies!.add(generateBody(index));
              });
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = tabs!.removeAt(oldIndex);
                final body = bodies!.removeAt(oldIndex);

                tabs!.insert(newIndex, item);
                bodies!.insert(newIndex, body);

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
