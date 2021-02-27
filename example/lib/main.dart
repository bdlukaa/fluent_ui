import 'package:fluent_ui/fluent_ui.dart';

import 'screens/inputs.dart';

final appKey = GlobalKey<_MyAppState>();

void main() {
  runApp(MyApp(key: appKey));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Fluent ui app showcase',
      themeMode: ThemeMode.light,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => MyHomePage(
              mode: _mode,
              onThemeChange: (mode) {
                setState(() => _mode = mode);
              },
            ),
      },
      style: Style(
        // accentColor: Colors.green,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    @required this.mode,
    @required this.onThemeChange,
  }) : super(key: key);

  final ThemeMode mode;
  final Function(ThemeMode mode) onThemeChange;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool value = false;

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Text(
            'Inputs',
            style: cardTitleTextStyle.copyWith(color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: InputsPage(),
          ),
        ],
      ),
      // left: NavigationPanel(
      //   currentIndex: index,
      //   onChanged: (i) => setState(() => index = i),
      //   items: [
      //     NavigationPanelItem(
      //       icon: Icon(FluentIcons.radio_button_24_filled),
      //       label: Text('Inputs'),
      //     ),
      //     NavigationPanelItem(
      //       icon: Icon(FluentIcons.radio_button_24_filled),
      //       label: Text('Surface'),
      //     ),
      //   ],
      // ),
    );
  }
}
