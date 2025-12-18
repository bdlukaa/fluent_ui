import 'package:example/screens/home.dart';
import 'package:example/screens/settings.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:go_router/go_router.dart';
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

const String appTitle = 'Win UI for Flutter';

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
        return FluentApp.router(
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
          ),
          theme: FluentThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
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
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.child,
    required this.shellContext,
    super.key,
  });

  final Widget child;
  final BuildContext? shellContext;

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
        endHeader: ToggleButton(
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
                title: const Text('Expander'),
                body: surfaces.ExpanderPage(),
              ),
              PaneItem(
                title: const Text('ComboBox'),
                body: forms.ComboBoxPage(),
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
            title: const Text('Surfaces & Styles'),
            items: [
              PaneItem(
                title: const Text('Acrylic'),
                body: surfaces.AcrylicPage(),
              ),
              PaneItem(
                title: const Text('Mica'),
                //  body: surfaces.AcrylicPage()
              ),
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
                // body: surfaces.InfoBadgePage(),
              ),
              PaneItem(
                title: const Text('ProgressRing'),
                body: surfaces.ProgressIndicatorsPage(),
              ),
              PaneItem(
                title: const Text('ProgressBar'),
                // body: surfaces.ProgressBarPage(),
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
            body: const SizedBox.shrink(),
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
  _LinkPaneItemAction({
    required super.icon,
    required this.link,
    required super.body,
    super.title,
  });

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

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (final context, final state, final child) {
        return MyHomePage(
          shellContext: _shellNavigatorKey.currentContext,
          child: child,
        );
      },
      routes: <GoRoute>[
        /// Home
        GoRoute(
          path: '/',
          builder: (final context, final state) => const HomePage(),
        ),

        /// Settings
        GoRoute(
          path: '/settings',
          builder: (final context, final state) => const Settings(),
        ),

        /// /// Input
        /// Buttons
        GoRoute(
          path: '/inputs/buttons',
          builder: (final context, final state) =>
              DeferredWidget(inputs.loadLibrary, () => inputs.ButtonPage()),
        ),

        /// Checkbox
        GoRoute(
          path: '/inputs/checkbox',
          builder: (final context, final state) =>
              DeferredWidget(inputs.loadLibrary, () => inputs.CheckBoxPage()),
        ),

        /// Slider
        GoRoute(
          path: '/inputs/slider',
          builder: (final context, final state) =>
              DeferredWidget(inputs.loadLibrary, () => inputs.SliderPage()),
        ),

        /// ToggleSwitch
        GoRoute(
          path: '/inputs/toggle_switch',
          builder: (final context, final state) => DeferredWidget(
            inputs.loadLibrary,
            () => inputs.ToggleSwitchPage(),
          ),
        ),

        /// /// Form
        /// TextBox
        GoRoute(
          path: '/forms/text_box',
          builder: (final context, final state) =>
              DeferredWidget(forms.loadLibrary, () => forms.TextBoxPage()),
        ),

        /// AutoSuggestBox
        GoRoute(
          path: '/forms/auto_suggest_box',
          builder: (final context, final state) => DeferredWidget(
            forms.loadLibrary,
            () => forms.AutoSuggestBoxPage(),
          ),
        ),

        /// ComboBox
        GoRoute(
          path: '/forms/combobox',
          builder: (final context, final state) =>
              DeferredWidget(forms.loadLibrary, () => forms.ComboBoxPage()),
        ),

        /// NumberBox
        GoRoute(
          path: '/forms/numberbox',
          builder: (final context, final state) =>
              DeferredWidget(forms.loadLibrary, () => forms.NumberBoxPage()),
        ),

        GoRoute(
          path: '/forms/passwordbox',
          builder: (final context, final state) =>
              DeferredWidget(forms.loadLibrary, () => forms.PasswordBoxPage()),
        ),

        /// TimePicker
        GoRoute(
          path: '/forms/time_picker',
          builder: (final context, final state) =>
              DeferredWidget(forms.loadLibrary, () => forms.TimePickerPage()),
        ),

        /// DatePicker
        GoRoute(
          path: '/forms/date_picker',
          builder: (final context, final state) =>
              DeferredWidget(forms.loadLibrary, () => forms.DatePickerPage()),
        ),

        GoRoute(
          path: '/forms/calendar_view',
          builder: (final context, final state) =>
              DeferredWidget(forms.loadLibrary, () => forms.CalendarViewPage()),
        ),
        GoRoute(
          path: '/forms/calendar_date_picker',
          builder: (final context, final state) => DeferredWidget(
            forms.loadLibrary,
            () => forms.CalendarDatePickerPage(),
          ),
        ),

        /// ColorPicker
        GoRoute(
          path: '/forms/color_picker',
          builder: (final context, final state) =>
              DeferredWidget(forms.loadLibrary, () => forms.ColorPickerPage()),
        ),

        /// /// Navigation
        /// NavigationView
        GoRoute(
          path: '/navigation/navigation_view',
          builder: (final context, final state) => DeferredWidget(
            navigation.loadLibrary,
            () => navigation.NavigationViewPage(),
          ),
        ),
        GoRoute(
          path: '/navigation_view',
          builder: (final context, final state) => DeferredWidget(
            navigation.loadLibrary,
            () => navigation.NavigationViewShellRoute(),
          ),
        ),

        /// TabView
        GoRoute(
          path: '/navigation/tab_view',
          builder: (final context, final state) => DeferredWidget(
            navigation.loadLibrary,
            () => navigation.TabViewPage(),
          ),
        ),

        /// TreeView
        GoRoute(
          path: '/navigation/tree_view',
          builder: (final context, final state) => DeferredWidget(
            navigation.loadLibrary,
            () => navigation.TreeViewPage(),
          ),
        ),

        /// BreadcrumbBar
        GoRoute(
          path: '/navigation/breadcrumb_bar',
          builder: (final context, final state) => DeferredWidget(
            navigation.loadLibrary,
            () => navigation.BreadcrumbBarPage(),
          ),
        ),

        /// /// Surfaces
        /// Acrylic
        GoRoute(
          path: '/surfaces/acrylic',
          builder: (final context, final state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.AcrylicPage(),
          ),
        ),

        /// CommandBar
        GoRoute(
          path: '/surfaces/command_bar',
          builder: (final context, final state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.CommandBarsPage(),
          ),
        ),

        /// Expander
        GoRoute(
          path: '/surfaces/expander',
          builder: (final context, final state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.ExpanderPage(),
          ),
        ),

        /// InfoBar
        GoRoute(
          path: '/surfaces/info_bar',
          builder: (final context, final state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.InfoBarsPage(),
          ),
        ),

        /// Progress Indicators
        GoRoute(
          path: '/surfaces/progress_indicators',
          builder: (final context, final state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.ProgressIndicatorsPage(),
          ),
        ),

        /// Tiles
        GoRoute(
          path: '/surfaces/tiles',
          builder: (final context, final state) =>
              DeferredWidget(surfaces.loadLibrary, () => surfaces.TilesPage()),
        ),

        /// Popups
        /// ContentDialog
        GoRoute(
          path: '/popups/content_dialog',
          builder: (final context, final state) => DeferredWidget(
            surfaces.loadLibrary,
            () => popups.ContentDialogPage(),
          ),
        ),

        /// MenuBar
        GoRoute(
          path: '/popups/menu_bar',
          builder: (final context, final state) =>
              DeferredWidget(surfaces.loadLibrary, () => popups.MenuBarPage()),
        ),

        /// Tooltip
        GoRoute(
          path: '/popups/tooltip',
          builder: (final context, final state) =>
              DeferredWidget(surfaces.loadLibrary, () => popups.TooltipPage()),
        ),

        /// Flyout
        GoRoute(
          path: '/popups/flyout',
          builder: (final context, final state) => DeferredWidget(
            surfaces.loadLibrary,
            () => popups.Flyout2Screen(),
          ),
        ),

        /// Teaching Tip
        GoRoute(
          path: '/popups/teaching_tip',
          builder: (final context, final state) => DeferredWidget(
            surfaces.loadLibrary,
            () => popups.TeachingTipPage(),
          ),
        ),

        /// /// Theming
        /// Colors
        GoRoute(
          path: '/theming/colors',
          builder: (final context, final state) =>
              DeferredWidget(theming.loadLibrary, () => theming.ColorsPage()),
        ),

        /// Typography
        GoRoute(
          path: '/theming/typography',
          builder: (final context, final state) => DeferredWidget(
            theming.loadLibrary,
            () => theming.TypographyPage(),
          ),
        ),

        /// Icons
        GoRoute(
          path: '/theming/icons/windows',
          builder: (final context, final state) => DeferredWidget(
            theming.loadLibrary,
            () => theming.IconsPage(set: WindowsIcons.allIcons),
          ),
        ),

        GoRoute(
          path: '/theming/icons/fluent',
          builder: (final context, final state) => DeferredWidget(
            theming.loadLibrary,
            () => theming.IconsPage(set: FluentIcons.allIcons),
          ),
        ),

        /// Reveal Focus
        GoRoute(
          path: '/theming/reveal_focus',
          builder: (final context, final state) => DeferredWidget(
            theming.loadLibrary,
            () => theming.RevealFocusPage(),
          ),
        ),
      ],
    ),
  ],
);
