import 'package:fluent_ui/fluent_ui.dart';

class Others extends StatefulWidget {
  const Others({Key? key}) : super(key: key);

  @override
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> {
  int currentIndex = 0;

  int tabs = 3;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Acrylic(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(children: [
          Text('Surfaces', style: context.theme.typography?.subtitle),
          Tooltip(
            message: 'This is a tooltip',
            child: Button(
              text: Text('Button with tooltip'),
              onPressed: () {},
            ),
          ),
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
              text: Text('This is an action'),
              onPressed: () => print('action pressed'),
            ),
            onClose: () {
              print('closed');
            },
          ),
        );
      }),
      ListTile(
        leading: CircleAvatar(),
        title: Text('ListTile Title'),
        subtitle: Text('ListTile Subtitle'),
      ),
      Row(children: [
        Container(padding: EdgeInsets.all(6), child: ProgressBar(value: 50)),
        Container(
          margin: EdgeInsets.all(10),
          child: ProgressRing(value: 85),
        ),
      ]),
      SizedBox(
        height: 600,
        child: TabView(
          currentIndex: currentIndex,
          onChanged: (index) => setState(() => currentIndex = index),
          onNewPressed: () {
            setState(() => tabs++);
          },
          tabs: List.generate(tabs, (index) {
            return Tab(
              text: Text('Tab $index'),
              closeIcon: Tooltip(
                message: 'Close tab',
                child: IconButton(
                  icon: Icon(Icons.pane_close),
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
            (index) => Container(
              color: index.isEven ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    ]);
  }
}
