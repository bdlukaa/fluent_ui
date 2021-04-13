import 'package:fluent_ui/fluent_ui.dart';

class Others extends StatefulWidget {
  const Others({Key? key}) : super(key: key);

  @override
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> {
  int currentIndex = 0;

  int tabs = 3;

  final flyoutController = FlyoutController();

  bool checked = false;

  @override
  void dispose() {
    flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Acrylic(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(children: [
          Text('Surfaces', style: context.theme.typography?.subtitle),
          Wrap(spacing: 10, runSpacing: 10, children: [
            Tooltip(
              message: 'This is a tooltip',
              child: Button(
                child: Text('Button with tooltip'),
                onPressed: () {
                  print('pressed button with tooltip');
                },
              ),
            ),
            Flyout(
              controller: flyoutController,
              contentWidth: 450,
              content: FlyoutContent(
                child: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'),
              ),
              child: Button(
                child: Text('Open flyout'),
                onPressed: () {
                  flyoutController.open = true;
                },
              ),
            ),
          ]),
        ]),
      ),
      ...List.generate(InfoBarSeverity.values.length, (index) {
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
            action: Button(
              child: Text('This is an action'),
              onPressed: () => print('action pressed'),
            ),
            onClose: () {
              print('closed');
            },
          ),
        );
      }),
      Row(children: [
        Expanded(
          child: ListTile(
            title: Text('ListTile Title'),
            subtitle: Text('ListTile Subtitle'),
          ),
        ),
        Expanded(
          child: TappableListTile(
            leading: CircleAvatar(),
            title: Text('TappableListTile Title'),
            subtitle: Text('TappableListTile Subtitle'),
            onTap: () {
              print('hehehe');
            },
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: CheckboxListTile(
            checked: checked,
            onChanged: (v) => setState(() => checked = v!),
            title: Text('CheckboxListTile title'),
            subtitle: Text('CheckboxListTile subtitle'),
          ),
        ),
        Expanded(
          child: SwitchListTile(
            checked: checked,
            onChanged: (v) => setState(() => checked = v),
            title: Text('SwitchListTile title'),
            subtitle: Text('SwitchListTile subtitle'),
          ),
        ),
        Expanded(
          child: RadioListTile(
            checked: checked,
            onChanged: (v) => setState(() => checked = v),
            title: Text('RadioListTile title'),
            subtitle: Text('RadioListTile subtitle'),
          ),
        ),
      ]),
      Row(children: [
        Container(padding: EdgeInsets.all(6), child: ProgressBar(value: 50)),
        Container(
          margin: EdgeInsets.all(10),
          child: ProgressRing(value: 85),
        ),
      ]),
      Container(
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.accentColor!, width: 1.0),
        ),
        child: TabView(
          currentIndex: currentIndex,
          onChanged: _handleTabChanged,
          onNewPressed: () {
            setState(() => tabs++);
          },
          tabs: List.generate(tabs, (index) {
            return Tab(
              text: Text('Tab $index'),
              closeIcon: Tooltip(
                message: 'Close tab',
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() => tabs--);
                    if (currentIndex > tabs - 1) currentIndex--;
                    if (tabs == 0) currentIndex = 0;
                  },
                ),
              ),
            );
          }),
          bodies: List.generate(
            tabs,
            (index) => Container(color: Colors.accentColors[index]),
          ),
        ),
      ),
    ]);
  }

  void _handleTabChanged(int index) {
    setState(() => currentIndex = index);
  }
}
