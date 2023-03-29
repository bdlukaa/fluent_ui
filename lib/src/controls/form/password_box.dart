import 'package:fluent_ui/fluent_ui.dart';

class PasswordBox extends StatefulWidget {
  final bool? enabled;
  final String? placeholder;
  final bool? obscureText;

  const PasswordBox({
    super.key,
    this.enabled,
    this.placeholder,
    this.obscureText,
  });

  @override
  State<PasswordBox> createState() => _PasswordBoxState();
}

class _PasswordBoxState extends State<PasswordBox> {
  bool obscureText = true;

  @override
  void initState() {
    obscureText = widget.obscureText ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return TextBox(
      enabled: widget.enabled,
      placeholder: widget.placeholder,
      obscureText: obscureText,
      suffix: Listener(
        child: HoverButton(builder: (p0, state) {
          return Icon(FluentIcons.red_eye);
        },),
        onPointerDown: (_){
          print('DOWN');
          setState(() {
            obscureText = false;
          });
        },
        onPointerUp: (_){
          setState(() {
            obscureText = widget.obscureText ?? true;
          });
        },
      ),


      /*suffix: HoverButton(
        onTapDown: (){
          print('DOWN');
        },
        onTapUp: (){
          print('UP');
        },
        onTapCancel: (){
          print('CANCEL');
        },
        builder: (p0, state) {
          return Icon(FluentIcons.red_eye); // todo: half eye icon like WinUI3 ?
          // return IconButton(icon: Icon(FluentIcons.red_eye), onPressed: null,);
        },
      ),*/
    );
  }
}
