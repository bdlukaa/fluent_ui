import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/link.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/home.dart';
import 'screens/settings.dart';

import 'routes/forms.dart' deferred as forms;
import 'routes/inputs.dart' deferred as inputs;
import 'routes/navigation.dart' deferred as navigation;
import 'routes/surfaces.dart' deferred as surfaces;
import 'routes/theming.dart' deferred as theming;

import 'theme.dart';
import 'widgets/deferred_widget.dart';

const String appTitle = 'Fluent UI Showcase for Flutter';

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

  // if it's not on the web, windows or android, load the accent color
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  setPathUrlStrategy();

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(const Size(755, 545));
      await windowManager.setMinimumSize(const Size(350, 600));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }

  runApp(const MyApp());

  DeferredWidget.preload(forms.loadLibrary);
  DeferredWidget.preload(inputs.loadLibrary);
  DeferredWidget.preload(navigation.loadLibrary);
  DeferredWidget.preload(surfaces.loadLibrary);
  DeferredWidget.preload(theming.loadLibrary);
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
          color: appTheme.color,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          theme: ThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          locale: appTheme.locale,
          builder: (context, child) {
            return Directionality(
              textDirection: appTheme.textDirection,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!,
              ),
            );
          },
          initialRoute: '/',
          routes: {'/': (context) => const MyHomePage()},
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

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  bool value = false;

  int index = 0;

  final viewKey = GlobalKey();

  final key = GlobalKey();
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  void resetSearch() => searchController.clear();
  String get searchValue => searchController.text;
  final List<NavigationPaneItem> originalItems = [
    PaneItem(
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
      body: const HomePage(),
    ),
    PaneItemHeader(header: const Text('Inputs')),
    PaneItem(
      icon: const Icon(FluentIcons.button_control),
      title: const Text('Button'),
      body: DeferredWidget(
        inputs.loadLibrary,
        () => inputs.ButtonPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.checkbox_composite),
      title: const Text('Checkbox'),
      body: DeferredWidget(
        inputs.loadLibrary,
        () => inputs.CheckBoxPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.slider),
      title: const Text('Slider'),
      body: DeferredWidget(
        inputs.loadLibrary,
        () => inputs.SliderPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.toggle_left),
      title: const Text('ToggleSwitch'),
      body: DeferredWidget(
        inputs.loadLibrary,
        () => inputs.ToggleSwitchPage(),
      ),
    ),
    PaneItemHeader(header: const Text('Form')),
    PaneItem(
      icon: const Icon(FluentIcons.text_field),
      title: const Text('TextBox'),
      body: DeferredWidget(
        forms.loadLibrary,
        () => forms.TextBoxPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.page_list),
      title: const Text('AutoSuggestBox'),
      body: DeferredWidget(
        forms.loadLibrary,
        () => forms.AutoSuggestBoxPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.combobox),
      title: const Text('ComboBox'),
      body: DeferredWidget(
        forms.loadLibrary,
        () => forms.ComboBoxPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.time_picker),
      title: const Text('TimePicker'),
      body: DeferredWidget(
        forms.loadLibrary,
        () => forms.TimePickerPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.date_time),
      title: const Text('DatePicker'),
      body: DeferredWidget(
        forms.loadLibrary,
        () => forms.DatePickerPage(),
      ),
    ),
    PaneItemHeader(header: const Text('Navigation')),
    PaneItem(
      icon: const Icon(FluentIcons.navigation_flipper),
      title: const Text('NavigationView'),
      body: DeferredWidget(
        navigation.loadLibrary,
        () => navigation.NavigationViewPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.table_header_row),
      title: const Text('TabView'),
      body: DeferredWidget(
        navigation.loadLibrary,
        () => navigation.TabViewPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.bulleted_tree_list),
      title: const Text('TreeView'),
      body: DeferredWidget(
        navigation.loadLibrary,
        () => navigation.TreeViewPage(),
      ),
    ),
    PaneItemHeader(header: const Text('Surfaces')),
    PaneItem(
      icon: const Icon(FluentIcons.un_set_color),
      title: const Text('Acrylic'),
      body: DeferredWidget(
        surfaces.loadLibrary,
        () => surfaces.AcrylicPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.customize_toolbar),
      title: const Text('CommandBar'),
      body: DeferredWidget(
        surfaces.loadLibrary,
        () => surfaces.CommandBarsPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.comment_urgent),
      title: const Text('ContentDialog'),
      body: DeferredWidget(
        surfaces.loadLibrary,
        () => surfaces.ContentDialogPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.expand_all),
      title: const Text('Expander'),
      body: DeferredWidget(
        surfaces.loadLibrary,
        () => surfaces.ExpanderPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.info_solid),
      title: const Text('InfoBar'),
      body: DeferredWidget(
        surfaces.loadLibrary,
        () => surfaces.InfoBarsPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.progress_ring_dots),
      title: const Text('Progress Indicators'),
      body: DeferredWidget(
        surfaces.loadLibrary,
        () => surfaces.ProgressIndicatorsPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.tiles),
      title: const Text('Tiles'),
      body: DeferredWidget(
        surfaces.loadLibrary,
        () => surfaces.TilesPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.hint_text),
      title: const Text('Tooltip'),
      body: DeferredWidget(
        surfaces.loadLibrary,
        () => surfaces.TooltipPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.pop_expand),
      title: const Text('Flyout'),
      body: DeferredWidget(
        surfaces.loadLibrary,
        () => surfaces.FlyoutPage(),
      ),
    ),
    PaneItemHeader(header: const Text('Theming')),
    PaneItem(
      icon: const Icon(FluentIcons.color_solid),
      title: const Text('Colors'),
      body: DeferredWidget(
        theming.loadLibrary,
        () => theming.ColorsPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.font_color_a),
      title: const Text('Typography'),
      body: DeferredWidget(
        theming.loadLibrary,
        () => theming.TypographyPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.icon_sets_flag),
      title: const Text('Icons'),
      body: DeferredWidget(
        theming.loadLibrary,
        () => theming.IconsPage(),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.focus),
      title: const Text('Reveal Focus'),
      body: DeferredWidget(
        theming.loadLibrary,
        () => theming.RevealFocusPage(),
      ),
    ),
  ];
  final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.settings),
      title: const Text('Settings'),
      body: Settings(),
    ),
    _LinkPaneItemAction(
      icon: const Icon(FluentIcons.open_source),
      title: const Text('Source code'),
      link: 'https://github.com/bdlukaa/fluent_ui',
      body: const SizedBox.shrink(),
    ),
    // TODO: mobile widgets, Scrollbar, BottomNavigationBar, RatingBar
  ];
  late List<NavigationPaneItem> items = originalItems;

  @override
  void initState() {
    windowManager.addListener(this);
    searchController.addListener(() {
      setState(() {
        if (searchValue.isEmpty) {
          items = originalItems;
        } else {
          items = [...originalItems, ...footerItems]
              .whereType<PaneItem>()
              .where((item) {
                assert(item.title is Text);
                final text = (item.title as Text).data!;
                return text.toLowerCase().contains(searchValue.toLowerCase());
              })
              .toList()
              .cast<NavigationPaneItem>();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: () {
          if (kIsWeb) {
            return const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(appTitle),
            );
          }
          return const DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(appTitle),
            ),
          );
        }(),
        actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: ToggleSwitch(
              content: const Text('Dark Mode'),
              checked: FluentTheme.of(context).brightness.isDark,
              onChanged: (v) {
                if (v) {
                  appTheme.mode = ThemeMode.dark;
                } else {
                  appTheme.mode = ThemeMode.light;
                }
              },
            ),
          ),
          if (!kIsWeb) const WindowButtons(),
        ]),
      ),
      pane: NavigationPane(
        selected: () {
          // if not searching, return the current index
          if (searchValue.isEmpty) return index;

          final indexOnScreen = items.indexOf(
            [...originalItems, ...footerItems]
                .whereType<PaneItem>()
                .elementAt(index),
          );
          if (indexOnScreen.isNegative) return null;
          return indexOnScreen;
        }(),
        onChanged: (i) {
          // If searching, the values will have different indexes
          if (searchValue.isNotEmpty) {
            final equivalentIndex = [...originalItems, ...footerItems]
                .whereType<PaneItem>()
                .toList()
                .indexOf(items[i] as PaneItem);
            i = equivalentIndex;
          }
          resetSearch();
          setState(() => index = i);
        },
        header: SizedBox(
          height: kOneLineTileHeight,
          child: ShaderMask(
            shaderCallback: (rect) {
              final color = appTheme.color.resolveFromReverseBrightness(
                theme.brightness,
                level: theme.brightness == Brightness.light ? 0 : 2,
              );
              return LinearGradient(
                colors: [
                  color,
                  color,
                ],
              ).createShader(rect);
            },
            child: const FlutterLogo(
              style: FlutterLogoStyle.horizontal,
              size: 80.0,
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
            default:
              return const StickyNavigationIndicator();
          }
        }(),
        items: items,
        autoSuggestBox: TextBox(
          key: key,
          controller: searchController,
          placeholder: 'Search',
          focusNode: searchFocusNode,
        ),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: searchValue.isNotEmpty ? [] : footerItems,
      ),
      onOpenSearch: () {
        searchFocusNode.requestFocus();
      },
    );
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
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
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = FluentTheme.of(context);

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
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
    int? itemIndex,
  }) {
    return Link(
      uri: Uri.parse(link),
      builder: (context, followLink) => super.build(
        context,
        selected,
        followLink,
        displayMode: displayMode,
        showTextOnTop: showTextOnTop,
        itemIndex: itemIndex,
        autofocus: autofocus,
      ),
    );
  }
}
