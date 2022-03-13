import 'package:fluent_ui/fluent_ui.dart';

class Others extends StatefulWidget {
  const Others({Key? key}) : super(key: key);

  @override
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> {
  final _expanderKey = GlobalKey<ExpanderState>();

  int currentIndex = 0;

  final flyoutController = FlyoutController();

  bool checked = false;

  final items = [
    TreeViewItem(
      content: const Text('Work Documents'),
      value: 'work_docs',
      lazy: true,
      children: [
        TreeViewItem(
          content: const Text('XYZ Functional Spec'),
          value: 'xyz_functional_spec',
        ),
        TreeViewItem(
          content: const Text('Feature Schedule'),
          value: 'feature_schedule',
        ),
        TreeViewItem(
          content: const Text('Overall Project Plan'),
          value: 'overall_project_plan',
        ),
        TreeViewItem(
          content: const Text('Feature Resources Allocation'),
          value: 'feature_resources_alloc',
        ),
      ],
    ),
    TreeViewItem(
      content: const Text('Personal Documents'),
      value: 'personal_docs',
      children: [
        TreeViewItem(
          content: const Text('Home Remodel'),
          value: 'home_remodel',
          children: [
            TreeViewItem(
              content: const Text('Contractor Contact Info'),
              value: 'contr_cont_inf',
            ),
            TreeViewItem(
              content: const Text('Paint Color Scheme'),
              value: 'paint_color_scheme',
            ),
            TreeViewItem(
              content: const Text('Flooring weedgrain type'),
              value: 'flooring_weedgrain_type',
            ),
            TreeViewItem(
              content: const Text('Kitchen cabinet style'),
              value: 'kitch_cabinet_style',
            ),
          ],
        ),
        TreeViewItem(
          content: const Text('Tax Documents'),
          value: 'tax_docs',
          children: [
            TreeViewItem(content: const Text('2017'), value: "tax_2017"),
            TreeViewItem(content: const Text('2018'), value: "tax_2018"),
            TreeViewItem(content: const Text('2019'), value: "tax_2019"),
            TreeViewItem(content: const Text('2020'), value: "tax_2020"),
            TreeViewItem(content: const Text('2021'), value: "tax_2021"),
            TreeViewItem(content: const Text('Current Year'), value: "tax_cur"),
          ],
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    flyoutController.dispose();
    super.dispose();
  }

  DateTime date = DateTime.now();

  late List<Tab> tabs;
  late List<TreeViewItem> lazy;

  @override
  void initState() {
    super.initState();
    tabs = List.generate(3, (index) {
      late Tab tab;
      tab = Tab(
        text: Text('Document $index'),
        onClosed: () {
          _handleTabClosed(tab);
        },
      );
      return tab;
    });
    lazy = [
      TreeViewItem(
        content: const Text('Work Documents'),
        lazy: true,
        children: [],
        onInvoked: (item) async {
          if (item.children.isNotEmpty) return;
          setState(() => item.loading = true);
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            item
              ..loading = false
              ..children.addAll([
                TreeViewItem(content: const Text('XYZ Functional Spec')),
                TreeViewItem(content: const Text('Feature Schedule')),
                TreeViewItem(content: const Text('Overall Project Plan')),
                TreeViewItem(
                    content: const Text('Feature Resources Allocation')),
              ]);
          });
        },
      ),
      TreeViewItem(
        content: const Text('Personal Documents'),
        lazy: true,
        children: [
          TreeViewItem(
            content: const Text('Home Remodel'),
            children: [
              TreeViewItem(content: const Text('Contractor Contact Info')),
              TreeViewItem(content: const Text('Paint Color Scheme')),
              TreeViewItem(content: const Text('Flooring weedgrain type')),
              TreeViewItem(content: const Text('Kitchen cabinet style')),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Others')),
      children: [
        const SizedBox(height: 10.0),
        Card(
          child: Expander(
            key: _expanderKey,
            leading: RadioButton(
              checked: false,
              onChanged: (v) {},
            ),
            header: const Text('Info bars'),
            trailing: ToggleSwitch(
              checked: true,
              onChanged: (v) {},
            ),
            content: Column(
              children: List.generate(InfoBarSeverity.values.length, (index) {
                final severity = InfoBarSeverity.values[index];
                final titles = [
                  'Long title',
                  'Short title',
                ];
                final descs = [
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book',
                  'Short desc',
                ];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InfoBar(
                    title: Text(titles[index.isEven ? 0 : 1]),
                    content: Text(descs[index.isEven ? 0 : 1]),
                    isLong: InfoBarSeverity.values.indexOf(severity).isEven,
                    severity: severity,
                    action: () {
                      if (index == 0) {
                        return Tooltip(
                          message: 'This is a tooltip',
                          child: Button(
                            child: const Text(
                              'Hover this button to see a tooltip',
                            ),
                            onPressed: () {
                              debugPrint('pressed button with tooltip');
                            },
                          ),
                        );
                      } else {
                        if (index == 3) {
                          return Flyout(
                            controller: flyoutController,
                            contentWidth: 450,
                            content: const FlyoutContent(
                              child: Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'),
                            ),
                            child: Button(
                              child: const Text('Open flyout'),
                              onPressed: () {
                                flyoutController.open = true;
                              },
                            ),
                          );
                        }
                      }
                    }(),
                    onClose: () => _expanderKey.currentState?.open = false,
                  ),
                );
              }),
            ),
          ),
        ),
        InfoLabel(
          label: 'Progress indicators',
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(children: const [
                Padding(
                  padding: EdgeInsets.all(6),
                  child: ProgressBar(value: 50),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: ProgressRing(value: 85),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: ProgressBar(),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: ProgressRing(),
                ),
              ]),
            ),
          ),
        ),
        InfoLabel(
          label: 'Reorderable list view',
          child: Card(
            child: ReorderableListView(
              shrinkWrap: true,
              onReorder: (a, b) => debugPrint('reorder $a to $b'),
              children: const [
                ListTile(
                  key: ValueKey('a'),
                  title: Text('This is an list tile'),
                ),
                ListTile(
                  key: ValueKey('b'),
                  title: Text('This is a second list tile'),
                ),
              ],
            ),
          ),
        ),
        // Row(children: [
        //   CalendarView(
        //     onDateChanged: _handleDateChanged,
        //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
        //     lastDate: DateTime.now().add(Duration(days: 365 * 100)),
        //     initialDate: date,
        //     currentDate: date,
        //     onDisplayedMonthChanged: (date) {
        //       setState(() => this.date = date);
        //     },
        //   ),
        //   CalendarView(
        //     onDateChanged: _handleDateChanged,
        //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
        //     lastDate: DateTime.now().add(Duration(days: 365 * 100)),
        //     initialDate: date,
        //     currentDate: date,
        //     onDisplayedMonthChanged: (date) {
        //       setState(() => this.date = date);
        //     },
        //     initialCalendarMode: DatePickerMode.year,
        //   ),
        // ]),
        const SizedBox(height: 10),
        InfoLabel(
          label: 'TabView',
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).accentColor.resolve(context),
              border: Border.all(
                  color: FluentTheme.of(context).accentColor, width: 1.0),
            ),
            child: TabView(
              currentIndex: currentIndex,
              onChanged: _handleTabChanged,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Tab item = tabs.removeAt(oldIndex);
                  tabs.insert(newIndex, item);
                  if (currentIndex == newIndex) {
                    currentIndex = oldIndex;
                  } else if (currentIndex == oldIndex) {
                    currentIndex = newIndex;
                  }
                });
              },
              onNewPressed: () {
                setState(() {
                  late Tab tab;
                  tab = Tab(
                    text: Text('Document ${tabs.length}'),
                    onClosed: () {
                      _handleTabClosed(tab);
                    },
                  );
                  tabs.add(tab);
                });
              },
              tabs: tabs,
              bodies: List.generate(
                tabs.length,
                (index) => Container(
                  color: Colors.accentColors[index.clamp(
                    0,
                    Colors.accentColors.length - 1,
                  )],
                  child: Stack(children: [
                    const Positioned.fill(child: FlutterLogo()),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 250.0,
                        height: 200.0,
                        child: Acrylic(
                          child: Center(
                            child: Text(
                              'A C R Y L I C',
                              style:
                                  FluentTheme.of(context).typography.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        Wrap(
          // scrollDirection: Axis.horizontal,
          children: [
            InfoLabel(
              label: 'Simple and Scrollable',
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 380,
                  maxHeight: 380,
                  maxWidth: 350,
                ),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: FluentTheme.of(context).inactiveColor),
                ),
                child: TreeView(items: items, shrinkWrap: false),
              ),
            ),
            InfoLabel(
              label: 'Single Selection and Scrollable',
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 380,
                  maxHeight: 380,
                  maxWidth: 350,
                ),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: FluentTheme.of(context).inactiveColor),
                ),
                child: TreeView(
                  selectionMode: TreeViewSelectionMode.single,
                  shrinkWrap: false,
                  items: items,
                  onItemInvoked: (item) async =>
                      debugPrint('onItemInvoked: $item'),
                  onSelectionChanged: (selectedItems) async => debugPrint(
                      'onSelectionChanged: ${selectedItems.map((i) => i.value)}'),
                ),
              ),
            ),
            InfoLabel(
              label: 'Multiple Selection and Scrollable',
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 380,
                  maxHeight: 380,
                  maxWidth: 350,
                ),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: FluentTheme.of(context).inactiveColor),
                ),
                child: TreeView(
                  selectionMode: TreeViewSelectionMode.multiple,
                  shrinkWrap: false,
                  items: items,
                  onItemInvoked: (item) async =>
                      debugPrint('onItemInvoked: $item'),
                  onSelectionChanged: (selectedItems) async => debugPrint(
                      'onSelectionChanged: ${selectedItems.map((i) => i.value)}'),
                ),
              ),
            ),
            InfoLabel(
              label: 'Lazy View - Load nodes only when opened',
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 380,
                  maxWidth: 350,
                ),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: FluentTheme.of(context).inactiveColor),
                ),
                child: TreeView(
                  items: lazy,
                  onItemInvoked: (item) async =>
                      debugPrint('onItemInvoked: $item'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleTabChanged(int index) {
    setState(() => currentIndex = index);
  }

  void _handleTabClosed(Tab tab) {
    setState(() {
      tabs.remove(tab);
      if (currentIndex > tabs.length - 1) currentIndex--;
    });
  }

  // void _handleDateChanged(DateTime date) {

  // }

}
