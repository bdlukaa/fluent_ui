import 'package:fluent_ui/fluent_ui.dart';

class Forms extends StatelessWidget {
  const Forms({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 250,
          child: TextBox(),
        ),
      ],
    );
  }
}