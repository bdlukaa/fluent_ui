import 'package:fluent_ui/fluent_ui.dart';

class Divider extends StatelessWidget {
  const Divider({Key key, this.direction = Axis.vertical}) : super(key: key);

  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }
}
// TODO: finish
class DividerStyle {

  final int thickness;
  final Decoration decoration;
  final EdgeInsetsGeometry margin;

  DividerStyle({this.thickness,this.decoration,this.margin});

}