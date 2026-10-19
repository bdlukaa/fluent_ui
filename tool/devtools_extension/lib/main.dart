import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'icon_browser.dart';

void main() => runApp(const FluentUiDevToolsExtension());

class FluentUiDevToolsExtension extends StatelessWidget {
  const FluentUiDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return DevToolsExtension(
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        theme: FluentThemeData(brightness: Brightness.light),
        darkTheme: FluentThemeData(brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home: const IconBrowser(),
      ),
    );
  }
}
