import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart' as m;

// https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/slider
class Slider extends StatefulWidget {
  Slider({Key key}) : super(key: key);

  @override
  _SliderState createState() => _SliderState();
}

class _SliderState extends State<Slider> {
  @override
  Widget build(BuildContext context) {
    return m.CupertinoSlider(
      value: 30,
      max: 100,
      onChanged: (v) {},
    );
    // return Container(
    // );
  }
}