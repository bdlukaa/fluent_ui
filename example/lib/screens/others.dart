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
      for (final severity in InfoBarSeverity.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InfoBar(
            title: Text('This is a title'),
            content: Text('This is a long content lol content let'),
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
        ),
    ]);
  }
}
