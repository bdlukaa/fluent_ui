import 'package:example/screens/others.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'screens/forms.dart';
import 'screens/inputs.dart';
import 'screens/settings.dart';
import 'theme.dart';

void main() {
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
          style: Style(),
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
          icon: Icon(Icons.navigation),
          label: Text('Showcase'),
        ),
        currentIndex: index,
        items: [
          NavigationPanelSectionHeader(
            header: Text('Cool Navigation Panel Header'),
          ),
          NavigationPanelItem(
            icon: Icon(Icons.checkbox_checked),
            label: Text('Inputs'),
            onTapped: () => setState(() => index = 0),
          ),
          NavigationPanelItem(
            icon: Icon(Icons.text_align_center_filled),
            label: Text('Forms'),
            onTapped: () => setState(() => index = 1),
          ),
          NavigationPanelTileSeparator(),
          NavigationPanelItem(
            icon: Icon(Icons.time_picker),
            label: Text('Pickers'),
            onTapped: () => setState(() => index = 2),
          ),
          NavigationPanelItem(
            icon: Icon(Icons.none),
            label: Text('Others'),
            onTapped: () => setState(() => index = 3),
          ),
        ],
        bottom: NavigationPanelItem(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
          onTapped: () => setState(() => index = 4),
        ),
      ),
      body: NavigationPanelBody(index: index, children: [
        _Panel(title: 'Inputs showcase', child: InputsPage()),
        _Panel(title: 'Forms showcase', child: Forms()),
        _Panel(title: 'Pickers', child: SizedBox()),
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
        Text(title!, style: context.theme!.typography?.subtitle),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: child,
        ),
      ],
    );
  }
}
