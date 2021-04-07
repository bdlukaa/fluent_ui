import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

import 'screens/forms.dart';
import 'screens/inputs.dart';
import 'screens/others.dart';
import 'screens/settings.dart';

import 'theme.dart';

late bool darkMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The platforms the plugin support (01/04/2021 - DD/MM/YYYY):
  //   - Windows
  //   - Web
  //   - Android
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.android ||
      kIsWeb) {
    darkMode = await SystemTheme.darkMode;
    await SystemTheme.accentInstance.load();
  } else {
    darkMode = true;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          title: 'Fluent ui app showcase',
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (_) => MyHomePage(),
          },
          style: Style(
            accentColor: SystemTheme.accentInstance.accent,
            brightness: appTheme.mode == ThemeMode.system
                ? darkMode
                    ? Brightness.dark
                    : Brightness.light
                : null,
            focusStyle: FocusStyle(
              glowFactor:
                  is10footScreen(ui.window.physicalSize.width) ? 2.0 : 0.0,
            ),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool value = false;

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      left: NavigationPanel(
        menu: NavigationPanelMenuItem(
          icon: Icon(Icons.dehaze),
          label: Text('Showcase'),
        ),
        currentIndex: index,
        items: [
          NavigationPanelSectionHeader(
            header: Text('Cool Navigation Panel Header'),
          ),
          NavigationPanelItem(
            icon: Icon(Icons.input),
            label: Text('Inputs'),
            onTapped: () => setState(() => index = 0),
          ),
          NavigationPanelItem(
            icon: Icon(Icons.format_align_center),
            label: Text('Forms'),
            onTapped: () => setState(() => index = 1),
          ),
          NavigationPanelTileSeparator(),
          NavigationPanelItem(
            icon: Icon(Icons.miscellaneous_services),
            label: Text('Others'),
            onTapped: () => setState(() => index = 2),
          ),
        ],
        bottom: NavigationPanelItem(
          // selected: index == 3,
          icon: Icon(Icons.settings),
          label: Text('Settings'),
          onTapped: () => setState(() => index = 3),
        ),
      ),
      body: NavigationPanelBody(index: index, children: [
        _Panel(title: 'Inputs showcase', child: InputsPage()),
        _Panel(title: 'Forms showcase', child: Forms()),
        _Panel(title: 'Others', child: Others()),
        _Panel(title: 'Settings', child: Settings()),
      ]),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    Key? key,
    this.title,
    this.child,
  }) : super(key: key);

  final String? title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Text(title!, style: context.theme.typography?.subtitle),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: child,
        ),
      ],
    );
  }
}
