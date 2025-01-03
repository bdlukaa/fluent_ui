import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(
      child: Placeholder(), // Build your extension here
    );
  }
}