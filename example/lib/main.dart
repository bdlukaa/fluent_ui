import 'package:example/screens/home.dart';
import 'package:example/screens/settings.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/link.dart';
import 'package:window_manager/window_manager.dart';

import 'routes/forms.dart' deferred as forms;
import 'routes/inputs.dart' deferred as inputs;
import 'routes/navigation.dart' deferred as navigation;
import 'routes/popups.dart' deferred as popups;
import 'routes/surfaces.dart' deferred as surfaces;
import 'routes/theming.dart' deferred as theming;
import 'theme.dart';
import 'widgets/deferred_widget.dart';

const String appTitle = 'Win UI for Flutter Gallery';

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
  // main_test.main();
  // return;
  WidgetsFlutterBinding.ensureInitialized();

  // if it's not on the web, windows or android, load the accent color
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.hideWindowControls();
    }
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setMinimumSize(const Size(500, 600));
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }

  await Future.wait([
    DeferredWidget.preload(popups.loadLibrary),
    DeferredWidget.preload(forms.loadLibrary),
    DeferredWidget.preload(inputs.loadLibrary),
    DeferredWidget.preload(navigation.loadLibrary),
    DeferredWidget.preload(surfaces.loadLibrary),
    DeferredWidget.preload(theming.loadLibrary),
  ]);

  runApp(const MyApp());
}

final _appTheme = AppTheme();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appTheme,
      builder: (final context, final child) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
            fontFamily: kIsWeb ? 'Segoe UI' : null,
          ),
          theme: FluentThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
            fontFamily: kIsWeb ? 'Segoe UI' : null,
          ),
          locale: appTheme.locale,
          builder: (final context, final child) {
            return Directionality(
              textDirection: appTheme.textDirection,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor:
                      appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!,
              ),
            );
          },
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  bool value = false;

  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  int _index = 0;

  @override
  Widget build(final BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    return NavigationView(
      key: viewKey,
      titleBar: TitleBar(
        icon: const FlutterLogo(),
        title: const Text(appTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
            child: Builder(
              builder: (context) {
                final allItems = NavigationView.dataOf(context).pane!.allItems
                    .where(
                      (i) =>
                          i is PaneItem &&
                          i is! PaneItemExpander &&
                          i.body != null &&
                          i.enabled,
                    )
                    .cast<PaneItem>();
                return AutoSuggestBox<PaneItem>(
                  onSelected: (item) {
                    NavigationView.dataOf(context).pane?.changeTo(item.value!);
                  },
                  items: [
                    for (final item in allItems)
                      AutoSuggestBoxItem<PaneItem>(
                        value: item,
                        label: (item.title! as Text).data!,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        endHeader: Tooltip(
          message: 'Toggle theme',
          child: ToggleButton(
            checked: theme.brightness == Brightness.dark,
            onChanged: (final v) {
              if (v) {
                appTheme.mode = ThemeMode.dark;
              } else {
                appTheme.mode = ThemeMode.light;
              }
            },
            child: const Icon(WindowsIcons.lightbulb),
          ),
        ),
        captionControls: const WindowButtons(),
        onDragStarted: !kIsWeb ? windowManager.startDragging : null,
      ),
      pane: NavigationPane(
        selected: _index,
        onChanged: (index) {
          debugPrint('Changed to $index');
          setState(() => _index = index);
        },
        header: SizedBox(
          height: kOneLineTileHeight,
          child: ShaderMask(
            shaderCallback: (final rect) {
              final color = appTheme.color.defaultBrushFor(theme.brightness);
              return LinearGradient(colors: [color, color]).createShader(rect);
            },
            child: const FlutterLogo(
              style: FlutterLogoStyle.horizontal,
              size: 80,
              textColor: Colors.white,
              duration: Duration.zero,
            ),
          ),
        ),
        displayMode: appTheme.displayMode,
        indicator: () {
          switch (appTheme.indicator) {
            case NavigationIndicators.end:
              return const EndNavigationIndicator();
            case NavigationIndicators.sticky:
              return const StickyNavigationIndicator();
          }
        }(),

        items: [
          PaneItem(
            icon: const WindowsIcon(WindowsIcons.home),
            title: const Text('Home'),
            body: const HomePage(),
          ),
          PaneItemHeader(header: const Text('Controls')),
          PaneItemExpander(
            icon: const WindowsIcon(WindowsIcons.button_a),
            title: const Text('Basic input'),
            items: [
              PaneItem(title: const Text('Button'), body: inputs.ButtonPage()),
              PaneItem(
                title: const Text('Checkbox'),
                body: inputs.CheckBoxPage(),
              ),
              PaneItem(title: const Text('Slider'), body: inputs.SliderPage()),
              PaneItem(
                title: const Text('ToggleSwitch'),
                body: inputs.ToggleSwitchPage(),
              ),
              PaneItem(
                title: const Text('ComboBox'),
                body: forms.ComboBoxPage(),
              ),
              PaneItem(
                title: const Text('ColorPicker'),
                body: forms.ColorPickerPage(),
              ),
            ],
          ),
          PaneItemExpander(
            icon: const WindowsIcon(WindowsIcons.date_time),
            title: const Text('Date & time'),
            items: [
              PaneItem(
                title: const Text('DatePicker'),
                body: forms.DatePickerPage(),
              ),
              PaneItem(
                title: const Text('TimePicker'),
                body: forms.TimePickerPage(),
              ),
              PaneItem(
                title: const Text('CalendarView'),
                body: forms.CalendarViewPage(),
              ),
              PaneItem(
                title: const Text('CalendarDatePicker'),
                body: forms.CalendarDatePickerPage(),
              ),
            ],
          ),
          PaneItemExpander(
            icon: const WindowsIcon(WindowsIcons.chat_bubbles),
            title: const Text('Dialogs & flyouts'),
            items: [
              PaneItem(
                title: const Text('ContentDialog'),
                body: popups.ContentDialogPage(),
              ),
              PaneItem(
                title: const Text('Flyout'),
                body: popups.Flyout2Screen(),
              ),
              PaneItem(
                title: const Text('TeachingTip'),
                body: popups.TeachingTipPage(),
              ),
              PaneItem(
                title: const Text('Tooltip'),
                body: popups.TooltipPage(),
              ),
              PaneItem(
                title: const Text('MenuBar'),
                body: popups.MenuBarPage(),
              ),
            ],
          ),
          PaneItemExpander(
            icon: const WindowsIcon(WindowsIcons.text_navigate),
            title: const Text('Navigation'),
            items: [
              PaneItem(
                title: const Text('Breadcrumb Bar'),
                body: navigation.BreadcrumbBarPage(),
              ),
              PaneItem(
                title: const Text('Navigation View'),
                body: navigation.NavigationViewPage(),
              ),
              PaneItem(
                title: const Text('Tab View'),
                body: navigation.TabViewPage(),
              ),
              PaneItem(
                title: const Text('Tree View'),
                body: navigation.TreeViewPage(),
              ),
              PaneItem(
                title: const Text('Command Bar'),
                body: surfaces.CommandBarsPage(),
              ),
            ],
          ),
          PaneItemExpander(
            icon: const WindowsIcon(WindowsIcons.surface_hub),
            title: const Text('Surfaces & Layout'),
            items: [
              PaneItem(
                title: const Text('Acrylic'),
                body: surfaces.AcrylicPage(),
              ),
              // PaneItem(
              //   title: const Text('Mica'),
              //   //  body: surfaces.AcrylicPage()
              // ),
              PaneItem(title: const Text('Tiles'), body: surfaces.TilesPage()),
              PaneItem(
                title: const Text('Expander'),
                body: surfaces.ExpanderPage(),
              ),
            ],
          ),

          PaneItemExpander(
            icon: const WindowsIcon(WindowsIcons.app_icon_default),
            title: const Text('Styles & Icons'),
            items: [
              PaneItem(
                title: const Text('Windows Icons'),
                body: theming.IconsPage(set: WindowsIcons.allIcons),
              ),
              PaneItem(
                title: const Text('Fluent Icons'),
                body: theming.IconsPage(set: FluentIcons.allIcons),
              ),
              PaneItem(
                title: const Text('Typography'),
                body: theming.TypographyPage(),
              ),
              PaneItem(title: const Text('Colors'), body: theming.ColorsPage()),
            ],
          ),
          PaneItemExpander(
            icon: const WindowsIcon(WindowsIcons.progress_ring_dots),
            title: const Text('Status & info'),
            items: [
              PaneItem(
                title: const Text('InfoBar'),
                body: surfaces.InfoBarsPage(),
              ),
              PaneItem(
                title: const Text('InfoBadge'),
                body: surfaces.InfoBadgePage(),
              ),
              PaneItem(
                title: const Text('ProgressRing'),
                body: surfaces.ProgressRingPage(),
              ),
              PaneItem(
                title: const Text('ProgressBar'),
                body: surfaces.ProgressBarPage(),
              ),
              PaneItem(
                title: const Text('RatingBar'),
                body: inputs.RatingBarPage(),
              ),
            ],
          ),
          PaneItemExpander(
            icon: const WindowsIcon(WindowsIcons.text_edit),
            title: const Text('Text'),
            items: [
              PaneItem(
                title: const Text('AutoSuggestBox'),
                body: forms.AutoSuggestBoxPage(),
              ),
              PaneItem(
                title: const Text('NumberBox'),
                body: forms.NumberBoxPage(),
              ),
              PaneItem(
                title: const Text('PasswordBox'),
                body: forms.PasswordBoxPage(),
              ),
              PaneItem(title: const Text('TextBox'), body: forms.TextBoxPage()),
            ],
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const WindowsIcon(WindowsIcons.settings),
            title: const Text('Settings'),
            body: const Settings(),
          ),
          _LinkPaneItemAction(
            icon: const WindowsIcon(WindowsIcons.code),
            title: const Text('Source code'),
            link: 'https://github.com/bdlukaa/fluent_ui',
          ),
        ],
      ),
      onOpenSearch: searchFocusNode.requestFocus,
    );
  }

  @override
  Future<void> onWindowClose() async {
    final isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('Confirm close'),
            content: const Text('Are you sure you want to close this window?'),
            actions: [
              FilledButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              Button(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _LinkPaneItemAction extends PaneItem {
  _LinkPaneItemAction({required super.icon, required this.link, super.title});

  final String link;

  @override
  Widget build({
    required BuildContext context,
    required bool selected,
    required VoidCallback? onPressed,
    required PaneDisplayMode? displayMode,
    required int itemIndex,
    bool? autofocus,
    bool showTextOnTop = true,
    int depth = 0,
  }) {
    return Link(
      uri: Uri.parse(link),
      builder: (final context, final followLink) => Semantics(
        link: true,
        child: super.build(
          context: context,
          selected: selected,
          onPressed: followLink,
          displayMode: displayMode,
          showTextOnTop: showTextOnTop,
          itemIndex: itemIndex,
          autofocus: autofocus,
        ),
      ),
    );
  }
}
