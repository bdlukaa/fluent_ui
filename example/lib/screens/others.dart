import 'package:fluent_ui/fluent_ui.dart';

class Others extends StatelessWidget {
  const Others({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Acrylic(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(children: [
          Text('Surfaces', style: context.theme!.typography?.subtitle),
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
    ]);
  }
}
