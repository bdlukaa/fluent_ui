import 'package:fluent_ui/fluent_ui.dart';

class Others extends StatelessWidget {
  const Others({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Acrylic(
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
    ]);
  }
}
