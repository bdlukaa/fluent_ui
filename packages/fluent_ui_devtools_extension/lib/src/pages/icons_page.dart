import 'package:devtools_app_shared/ui.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart';

class IconsPage extends StatefulWidget {
  IconsPage({super.key});

  @override
  State<IconsPage> createState() => _IconsPageState();
}

class _IconsPageState extends State<IconsPage> {
  final List<MapEntry<String, IconData>> icons =
      FluentIcons.allIcons.entries.toList();
  final TextEditingController iconSearchController = TextEditingController();

  List<MapEntry<String, IconData>> get displayIcons {
    return icons
        .where((icon) => icon.key.contains(iconSearchController.text))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fluent Icons"),
        actions: [
          SizedBox(
              width: 250,
              child: DevToolsClearableTextField(
                labelText: "Search",
                controller: iconSearchController,
                onChanged: (p0) {
                  setState(() {});
                },
              ))
        ],
      ),
      body: RoundedOutlinedBorder(
        child: GridView.builder(
            itemCount: displayIcons.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                maxCrossAxisExtent: 250),
            itemBuilder: (context, index) {
              MapEntry<String, IconData> icon = displayIcons.elementAt(index);
              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Icon(icon.value), Text(icon.key)]);
            }),
      ),
    );
  }
}
