import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:fluent_ui_devtools_extension/src/pages/icons_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DevToolsExtension(
      child: IconsPage(),
    );
  }
}
