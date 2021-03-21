import 'package:fluent_ui/fluent_ui.dart';

class Pickers extends StatefulWidget {
  Pickers({Key? key}) : super(key: key);

  @override
  _PickersState createState() => _PickersState();
}

class _PickersState extends State<Pickers> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarView(),
      ],
    );
  }
}
