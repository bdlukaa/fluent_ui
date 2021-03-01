import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart' as m;

class TextBox extends StatefulWidget {
  const TextBox({Key key}) : super(key: key);

  @override
  _TextBoxState createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  FocusNode _focus = FocusNode();
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() {});
    });
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    m.AlertDialog();
    return Container(
      decoration: BoxDecoration(
        color: context.theme.activeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: m.TextField(
        controller: controller,
        focusNode: _focus,
        maxLines: null,
        decoration: m.InputDecoration(
          focusedBorder: m.OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: context.theme.accentColor),
          ),
          border: m.OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: context.theme.inactiveColor),
          ),
          fillColor: context.theme.activeColor,
          contentPadding: EdgeInsets.all(8),
        ),
      ),
    );
  }
}
