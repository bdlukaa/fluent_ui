import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_icons/fluentui_icons.dart';

import 'screens/forms.dart';
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
      left: NavigationPanel(
        top: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(FluentSystemIcons.ic_fluent_navigation_regular),
            // SizedBox(width: 6),
            // Text('Showcase', style: TextStyle(
            //   fontWeight: FontWeight.bold,
            //   fontSize: 16,
            // )),
          ],
        ),
        currentIndex: index,
        items: [
          NavigationPanelItem(
            icon: Icon(FluentSystemIcons.ic_fluent_radio_button_filled),
            label: Text('Inputs'),
          ),
          NavigationPanelItem(
            icon: Icon(FluentSystemIcons.ic_fluent_text_align_center_filled),
            label: Text('Forms'),
          ),
          NavigationPanelItem(
            icon: Icon(FluentSystemIcons.ic_fluent_time_picker_regular),
            label: Text('Pickers'),
          ),
          NavigationPanelItem(
            icon: Icon(FluentSystemIcons.ic_fluent_none_regular),
            label: Text('Others'),
          ),
        ],
        onChanged: (i) => setState(() => index = i),
      ),
      body: IndexedStack(
        index: index,
        children: [
          ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              Text(
                'Inputs showcase',
                style: cardTitleTextStyle.copyWith(color: Colors.white),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: InputsPage(),
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              Text(
                'Forms showcase',
                style: cardTitleTextStyle.copyWith(color: Colors.white),
              ),
              Forms(),
            ],
          ),
          SizedBox(),
          SizedBox(),
        ],
      ),
    );
  }
}
