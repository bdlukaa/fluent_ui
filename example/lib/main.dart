import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'screens/colors.dart';
import 'screens/forms.dart';
import 'screens/inputs.dart';
import 'screens/others.dart';
import 'screens/settings.dart';

import 'theme.dart';

const String appTitle = 'Fluent UI Showcase for Flutter';

late bool darkMode;

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

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
  if (isDesktop)
    doWhenWindowReady(() {
      final win = appWindow;
      win.minSize = Size(500, 500);
      win.size = Size(755, 545);
      win.alignment = Alignment.center;
      win.title = appTitle;
      win.show();
    });
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
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {'/': (_) => MyHomePage()},
          navigatorObservers: [ClearFocusOnPush()],
          theme: ThemeData(
            accentColor: appTheme.color,
            brightness: appTheme.mode == ThemeMode.system
                ? darkMode
                    ? Brightness.dark
                    : Brightness.light
                : appTheme.mode == ThemeMode.dark
                    ? Brightness.dark
                    : Brightness.light,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
        );
      },
    );
  }
}

// This is the current solution for this. See https://github.com/flutter/flutter/issues/48464
class ClearFocusOnPush extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final focus = FocusManager.instance.primaryFocus;
    focus?.unfocus();
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

  final colorsController = ScrollController();
  final settingsController = ScrollController();

  @override
  void dispose() {
    colorsController.dispose();
    settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
      appBar: NavigationAppBar(
        height: !kIsWeb ? appWindow.titleBarHeight : 31.0,
        title: () {
          if (kIsWeb) return Text(appTitle);
          return MoveWindow(
            child: Align(alignment: Alignment.center, child: Text(appTitle)),
          );
        }(),
        actions: kIsWeb
            ? null
            : MoveWindow(
                child: Row(children: [Spacer(), WindowButtons()]),
              ),
      ),
      useAcrylic: false,
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        header: FlutterLogo(),
        displayMode: appTheme.displayMode,
        onDisplayModeRequested: (mode) {
          appTheme.displayMode = mode;
        },
        items: [
          PaneItemHeader(header: Text('User Interaction')),
          PaneItem(icon: Icon(Icons.input), title: 'Inputs'),
          PaneItem(icon: Icon(Icons.format_align_center), title: 'Forms'),
          PaneItemSeparator(),
          PaneItemHeader(header: Text('Extra Widgets')),
          PaneItem(icon: Icon(Icons.miscellaneous_services), title: 'Others'),
          PaneItem(icon: Icon(Icons.color_lens_outlined), title: 'Colors'),
        ],
        autoSuggestBox: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AutoSuggestBox(
            controller: TextEditingController(),
            items: ['Item 1', 'Item 2', 'Item 3', 'Item 4'],
          ),
        ),
        autoSuggestBoxReplacement: Icon(Icons.search),
        footerItems: [
          PaneItemSeparator(),
          PaneItem(icon: Icon(Icons.settings), title: 'Settings'),
        ],
      ),
      content: NavigationBody(index: index, children: [
        InputsPage(),
        Forms(),
        Others(),
        ColorsPage(controller: colorsController),
        Settings(controller: settingsController),
      ]),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final ThemeData theme = FluentTheme.of(context);
    final buttonColors = WindowButtonColors(
      iconNormal: theme.inactiveColor,
      iconMouseDown: theme.inactiveColor,
      iconMouseOver: theme.inactiveColor,
      mouseOver: ButtonThemeData.buttonColor(theme, ButtonStates.hovering),
      mouseDown: ButtonThemeData.buttonColor(theme, ButtonStates.pressing),
    );
    final closeButtonColors = WindowButtonColors(
      mouseOver: Colors.red,
      mouseDown: Colors.red.dark,
      iconNormal: theme.inactiveColor,
      iconMouseOver: Colors.red.basedOnLuminance(),
      iconMouseDown: Colors.red.dark.basedOnLuminance(),
    );
    return Row(children: [
      MinimizeWindowButton(colors: buttonColors),
      MaximizeWindowButton(colors: buttonColors),
      CloseWindowButton(colors: closeButtonColors),
    ]);
  }
}
