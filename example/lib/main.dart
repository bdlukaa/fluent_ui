import 'package:fluent_ui/fluent_ui.dart';

import 'screens/forms.dart';
import 'screens/inputs.dart';

final appKey = GlobalKey<_MyAppState>();

void main() {
  runApp(MyApp(key: appKey));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

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
        accentColor: Colors.green,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.mode,
    required this.onThemeChange,
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
        menu: NavigationPanelMenuItem(
            icon: Icon(Icons.navigation_regular),
            label: Text(
              'Showcase',
            )),
        currentIndex: index,
        items: [
          NavigationPanelSectionHeader(
              header: Text('Cool Navigation Panel Header')),
          NavigationPanelItem(
            icon: Icon(Icons.radio_button_filled),
            label: Text('Inputs'),
          ),
          NavigationPanelItem(
            icon: Icon(Icons.text_align_center_filled),
            label: Text('Forms'),
          ),
          NavigationPanelTileSeparator(),
          NavigationPanelItem(
            icon: Icon(Icons.time_picker_regular),
            label: Text('Pickers'),
          ),
          NavigationPanelItem(
            icon: Icon(Icons.none_regular),
            label: Text('Others'),
          ),
        ],
        onChanged: (i) => setState(() => index = i),
      ),
      body: AnimatedSwitcher(
        duration:
            context.theme!.animationDuration ?? Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              child: child,
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(index),
          index: index,
          children: [
            _Panel(
              title: 'Inputs showcase',
              child: InputsPage(),
            ),
            _Panel(
              title: 'Forms showcase',
              child: Forms(),
            ),
            _Panel(
              title: 'Pickers',
              child: SizedBox(),
            ),
            _Panel(
              title: 'Others',
              child: SizedBox(),
            ),
          ],
        ),
      ),
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
        Text(
          title!,
          style: cardTitleTextStyle,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: child,
        ),
      ],
    );
  }
}
