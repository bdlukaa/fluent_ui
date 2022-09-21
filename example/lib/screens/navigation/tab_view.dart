import 'dart:math';

import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TabViewPage extends StatefulWidget {
  const TabViewPage({Key? key}) : super(key: key);

  @override
  State<TabViewPage> createState() => _TabViewPageState();
}

class _TabViewPageState extends State<TabViewPage> with PageMixin {
  int currentIndex = 0;
  List<Tab>? tabs;

  TabWidthBehavior tabWidthBehavior = TabWidthBehavior.equal;
  CloseButtonVisibilityMode closeButtonVisibilityMode =
      CloseButtonVisibilityMode.always;
  bool showScrollButtons = true;
  bool wheelScroll = false;

  Tab generateTab(int index) {
    late Tab tab;
    tab = Tab(
      text: Text('Document $index'),
      semanticLabel: 'Document #$index',
      icon: const FlutterLogo(),
      body: Container(
        color:
            Colors.accentColors[Random().nextInt(Colors.accentColors.length)],
      ),
      onClosed: () {
        setState(() {
          tabs!.remove(tab);

          if (currentIndex > 0) currentIndex--;
        });
      },
    );
    return tab;
  }

  @override
  Widget build(BuildContext context) {
    tabs ??= List.generate(3, generateTab);
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('TabView')),
      children: [
        const Text(
          'The TabView control is a way to display a set of tabs and their '
          'respective content. TabViews are useful for displaying several pages '
          '(or documents) of content while giving a user the capability to '
          'rearrange, open, or close new tabs.',
        ),
        subtitle(
          content: const Text(
            'A TabView with support for adding, closing and rearraging tabs',
          ),
        ),
        Card(
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 150,
                child: InfoLabel(
                  label: 'Tab width behavior',
                  child: ComboBox<TabWidthBehavior>(
                    isExpanded: true,
                    value: tabWidthBehavior,
                    items: TabWidthBehavior.values.map((behavior) {
                      return ComboBoxItem(
                        child: Text(behavior.name),
                        value: behavior,
                      );
                    }).toList(),
                    onChanged: (behavior) {
                      if (behavior != null) {
                        setState(() => tabWidthBehavior = behavior);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: InfoLabel(
                  label: 'Close button visbility',
                  child: ComboBox<CloseButtonVisibilityMode>(
                    isExpanded: true,
                    value: closeButtonVisibilityMode,
                    items: CloseButtonVisibilityMode.values.map((mode) {
                      return ComboBoxItem(
                        child: Text(mode.name),
                        value: mode,
                      );
                    }).toList(),
                    onChanged: (mode) {
                      if (mode != null) {
                        setState(() => closeButtonVisibilityMode = mode);
                      }
                    },
                  ),
                ),
              ),
              Checkbox(
                checked: showScrollButtons,
                onChanged: (v) => setState(() => showScrollButtons = v!),
                content: const Text('Show scroll buttons'),
              ),
              Checkbox(
                checked: wheelScroll,
                onChanged: (v) => setState(() => wheelScroll = v!),
                content: const Text('Wheel scroll'),
              ),
            ],
          ),
        ),
        CardHighlight(
          child: SizedBox(
            height: 400,
            child: TabView(
              tabs: tabs!,
              currentIndex: currentIndex,
              onChanged: (index) => setState(() => currentIndex = index),
              tabWidthBehavior: tabWidthBehavior,
              closeButtonVisibility: closeButtonVisibilityMode,
              showScrollButtons: showScrollButtons,
              wheelScroll: wheelScroll,
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
          // TODO: TabView snippets
          codeSnippet: '''''',
        ),
      ],
    );
  }
}
