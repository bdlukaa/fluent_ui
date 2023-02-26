import 'package:example/screens/home.dart';
import 'package:example/screens/settings.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/link.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

import 'routes/popups.dart' deferred as popups;
import 'routes/forms.dart' deferred as forms;
import 'routes/inputs.dart' deferred as inputs;
import 'routes/navigation.dart' deferred as navigation;
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

  Future.wait([
    DeferredWidget.preload(popups.loadLibrary),
    DeferredWidget.preload(forms.loadLibrary),
    DeferredWidget.preload(inputs.loadLibrary),
    DeferredWidget.preload(navigation.loadLibrary),
    DeferredWidget.preload(surfaces.loadLibrary),
    DeferredWidget.preload(theming.loadLibrary),
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // private navigators

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
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
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          theme: FluentThemeData(
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
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
          /*initialRoute: '/',
          routes: {'/': (context) => const MyHomePage()},*/
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.widget, required this.shellContext})
      : super(key: key);
  final Widget widget;
  final BuildContext? shellContext;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  bool value = false;

  // int index = 0;

  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  final List<NavigationPaneItem> originalItems = [
    PaneItem(
        key: const Key('/'),
        icon: const Icon(FluentIcons.home),
        title: const Text('Home'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/') {
            router.pushNamed('home');
          }
        }),
    PaneItemHeader(header: const Text('Inputs')),
    PaneItem(
        key: const Key('/inputs/buttons'),
        icon: const Icon(FluentIcons.button_control),
        title: const Text('Button'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/inputs/buttons') {
            router.pushNamed('inputs_buttons');
          }
        }),
    PaneItem(
        key: const Key('/inputs/checkbox'),
        icon: const Icon(FluentIcons.checkbox_composite),
        title: const Text('Checkbox'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/inputs/checkbox') {
            router.pushNamed('inputs_checkbox');
          }
        }),
    PaneItem(
        key: const Key('/inputs/slider'),
        icon: const Icon(FluentIcons.slider),
        title: const Text('Slider'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/inputs/slider') {
            router.pushNamed('inputs_slider');
          }
        }),
    PaneItem(
        key: const Key('/inputs/toggle_switch'),
        icon: const Icon(FluentIcons.toggle_left),
        title: const Text('ToggleSwitch'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/inputs/toggle_switch') {
            router.pushNamed('inputs_toggle_switch');
          }
        }),
    PaneItemHeader(header: const Text('Form')),
    PaneItem(
        key: const Key('/forms/text_box'),
        icon: const Icon(FluentIcons.text_field),
        title: const Text('TextBox'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/forms/text_box') {
            router.pushNamed('forms_text_box');
          }
        }),
    PaneItem(
        key: const Key('/forms/auto_suggest_box'),
        icon: const Icon(FluentIcons.page_list),
        title: const Text('AutoSuggestBox'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/forms/auto_suggest_box') {
            router.pushNamed('forms_auto_suggest_box');
          }
        }),
    PaneItem(
        key: const Key('/forms/combobox'),
        icon: const Icon(FluentIcons.combobox),
        title: const Text('ComboBox'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/forms/combobox') {
            router.pushNamed('forms_combobox');
          }
        }),
    PaneItem(
        key: const Key('/forms/time_picker'),
        icon: const Icon(FluentIcons.time_picker),
        title: const Text('TimePicker'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/forms/time_picker') {
            router.pushNamed('forms_time_picker');
          }
        }),
    PaneItem(
        key: const Key('/forms/date_picker'),
        icon: const Icon(FluentIcons.date_time),
        title: const Text('DatePicker'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/forms/date_picker') {
            router.pushNamed('forms_date_picker');
          }
        }),
    PaneItemHeader(header: const Text('Navigation')),
    PaneItem(
        key: const Key('/navigation/nav_view'),
        icon: const Icon(FluentIcons.navigation_flipper),
        title: const Text('NavigationView'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/navigation/nav_view') {
            router.pushNamed('navigation_nav_view');
          }
        }),
    PaneItem(
        key: const Key('/navigation/tab_view'),
        icon: const Icon(FluentIcons.table_header_row),
        title: const Text('TabView'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/navigation/tab_view') {
            router.pushNamed('navigation_tab_view');
          }
        }),
    PaneItem(
        key: const Key('/navigation/tree_view'),
        icon: const Icon(FluentIcons.bulleted_tree_list),
        title: const Text('TreeView'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/navigation/tree_view') {
            router.pushNamed('navigation_tree_view');
          }
        }),
    PaneItemHeader(header: const Text('Surfaces')),
    PaneItem(
        key: const Key('/surfaces/acrylic'),
        icon: const Icon(FluentIcons.un_set_color),
        title: const Text('Acrylic'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/surfaces/acrylic') {
            router.pushNamed('surfaces_acrylic');
          }
        }),
    PaneItem(
        key: const Key('/surfaces/command_bar'),
        icon: const Icon(FluentIcons.customize_toolbar),
        title: const Text('CommandBar'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/surfaces/command_bar') {
            router.pushNamed('surfaces_command_bar');
          }
        }),
    PaneItem(
        key: const Key('/surfaces/expander'),
        icon: const Icon(FluentIcons.expand_all),
        title: const Text('Expander'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/surfaces/expander') {
            router.pushNamed('surfaces_expander');
          }
        }),
    PaneItem(
        key: const Key('/surfaces/info_bar'),
        icon: const Icon(FluentIcons.info_solid),
        title: const Text('InfoBar'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/surfaces/info_bar') {
            router.pushNamed('surfaces_info_bar');
          }
        }),
    PaneItem(
        key: const Key('/surfaces/progress_indicators'),
        icon: const Icon(FluentIcons.progress_ring_dots),
        title: const Text('Progress Indicators'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/surfaces/progress_indicators') {
            router.pushNamed('surfaces_progress_indicators');
          }
        }),
    PaneItem(
        key: const Key('/surfaces/tiles'),
        icon: const Icon(FluentIcons.tiles),
        title: const Text('Tiles'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/surfaces/tiles') {
            router.pushNamed('surfaces_tiles');
          }
        }),
    PaneItemHeader(header: const Text('Popups')),
    PaneItem(
        key: const Key('/popups/content_dialog'),
        icon: const Icon(FluentIcons.comment_urgent),
        title: const Text('ContentDialog'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/popups/content_dialog') {
            router.pushNamed('popups_content_dialog');
          }
        }),
    PaneItem(
        key: const Key('/popups/tooltip'),
        icon: const Icon(FluentIcons.hint_text),
        title: const Text('Tooltip'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/popups/tooltip') {
            router.pushNamed('popups_tooltip');
          }
        }),
    PaneItem(
        key: const Key('/popups/flyout'),
        icon: const Icon(FluentIcons.pop_expand),
        title: const Text('Flyout'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/popups/flyout') {
            router.pushNamed('popups_flyout');
          }
        }),
    PaneItemHeader(header: const Text('Theming')),
    PaneItem(
        key: const Key('/theming/colors'),
        icon: const Icon(FluentIcons.color_solid),
        title: const Text('Colors'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/theming/colors') {
            router.pushNamed('theming_colors');
          }
        }),
    PaneItem(
        key: const Key('/theming/typography'),
        icon: const Icon(FluentIcons.font_color_a),
        title: const Text('Typography'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/theming/typography') {
            router.pushNamed('theming_typography');
          }
        }),
    PaneItem(
        key: const Key('/theming/icons'),
        icon: const Icon(FluentIcons.icon_sets_flag),
        title: const Text('Icons'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/theming/icons') {
            router.pushNamed('theming_icons');
          }
        }),
    PaneItem(
        key: const Key('/theming/reveal_focus'),
        icon: const Icon(FluentIcons.focus),
        title: const Text('Reveal Focus'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/theming/reveal_focus') {
            router.pushNamed('theming_reveal_focus');
          }
        }),
  ];
  final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
        key: const Key('/settings'),
        icon: const Icon(FluentIcons.settings),
        title: const Text('Settings'),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/settings') {
            router.pushNamed('settings');
          }
        }),
    _LinkPaneItemAction(
      icon: const Icon(FluentIcons.open_source),
      title: const Text('Source code'),
      link: 'https://github.com/bdlukaa/fluent_ui',
      body: const SizedBox.shrink(),
    ),
    // TODO: mobile widgets, Scrollbar, BottomNavigationBar, RatingBar
  ];

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

  int _calculateSelectedIndex(BuildContext context) {
    final location = router.location;
    int indexOriginal = originalItems
        .where((element) => element.key != null)
        .toList()
        .indexWhere((element) => element.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = footerItems
          .where((element) => element.key != null)
          .toList()
          .indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
      }
      return originalItems
              .where((element) => element.key != null)
              .toList()
              .length +
          indexFooter;
    } else {
      return indexOriginal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    if (widget.shellContext != null) {
      if (router.canPop() == false) {
        setState(() {});
      }
    }
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: () {
          if (kIsWeb) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(children: [
                if (widget.shellContext != null)
                  if (router.canPop())
                    GestureDetector(
                      onDoubleTap: () {
                        context.pop();
                        setState(() {});
                      },
                      child: RotatedBox(
                        quarterTurns: Directionality.of(
                                  context,
                                ) ==
                                TextDirection.ltr
                            ? 0
                            : 2,
                        child: IconButton(
                          iconButtonMode: IconButtonMode.large,
                          onPressed: () {
                            context.pop();
                            setState(() {});
                          },
                          icon: const Icon(
                            FluentIcons.back,
                          ),
                        ),
                      ),
                    ),
                const Text(appTitle)
              ]),
            );
          }
          return DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  if (widget.shellContext != null)
                    if (router.canPop())
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onDoubleTap: () {
                            context.pop();
                            setState(() {});
                          },
                          child: RotatedBox(
                            quarterTurns: Directionality.of(
                                      context,
                                    ) ==
                                    TextDirection.ltr
                                ? 0
                                : 2,
                            child: IconButton(
                              iconButtonMode: IconButtonMode.large,
                              onPressed: () {
                                context.pop();
                                setState(() {});
                              },
                              icon: const Icon(
                                FluentIcons.back,
                              ),
                            ),
                          ),
                        ),
                      ),
                  const Text(appTitle)
                ],
              ),
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
      paneBodyBuilder: (wdgt) {
        return widget.widget;
      },
      pane: NavigationPane(
        selected: _calculateSelectedIndex(context),
        /* onChanged: (i) {
          setState(() => index = i);
        },*/
        header: SizedBox(
          height: kOneLineTileHeight,
          child: ShaderMask(
            shaderCallback: (rect) {
              final color = appTheme.color.defaultBrushFor(
                theme.brightness,
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
        items: originalItems,
        autoSuggestBox: AutoSuggestBox(
          key: searchKey,
          focusNode: searchFocusNode,
          controller: searchController,
          unfocusedColor: Colors.transparent,
          items: originalItems.whereType<PaneItem>().map((item) {
            assert(item.title is Text);
            final text = (item.title as Text).data!;
            return AutoSuggestBoxItem(
              label: text,
              value: text,
              onSelected: () {
                //TODO: 'AutoSuggestBoxItem' Not work
                /*
                final itemIndex = NavigationPane(
                  items: originalItems,
                ).effectiveIndexOf(item);
                print('itemIndex');
                print(itemIndex);

                setState(() => {});
                await Future.delayed(const Duration(milliseconds: 17));
                searchController.clear();*/
              },
            );
          }).toList(),
          trailingIcon: IgnorePointer(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(FluentIcons.search),
            ),
          ),
          placeholder: 'Search',
        ),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: footerItems,
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
    final FluentThemeData theme = FluentTheme.of(context);

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

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, widget) {
        return MyHomePage(
          widget: widget,
          shellContext: _shellNavigatorKey.currentContext,
        );
      },
      routes: [
        /// Home
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),

        /// Settings
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => Settings(),
        ),

        /// /// Input
        /// Buttons
        GoRoute(
          path: '/inputs/buttons',
          name: 'inputs_buttons',
          builder: (context, state) => DeferredWidget(
            inputs.loadLibrary,
            () => inputs.ButtonPage(),
          ),
        ),

        /// Checkbox
        GoRoute(
          path: '/inputs/checkbox',
          name: 'inputs_checkbox',
          builder: (context, state) => DeferredWidget(
            inputs.loadLibrary,
            () => inputs.CheckBoxPage(),
          ),
        ),

        /// Slider
        GoRoute(
          path: '/inputs/slider',
          name: 'inputs_slider',
          builder: (context, state) => DeferredWidget(
            inputs.loadLibrary,
            () => inputs.SliderPage(),
          ),
        ),

        /// ToggleSwitch
        GoRoute(
          path: '/inputs/toggle_switch',
          name: 'inputs_toggle_switch',
          builder: (context, state) => DeferredWidget(
            inputs.loadLibrary,
            () => inputs.ToggleSwitchPage(),
          ),
        ),

        /// /// Form
        /// TextBox
        GoRoute(
          path: '/forms/text_box',
          name: 'forms_text_box',
          builder: (context, state) => DeferredWidget(
            forms.loadLibrary,
            () => forms.TextBoxPage(),
          ),
        ),

        /// AutoSuggestBox
        GoRoute(
          path: '/forms/auto_suggest_box',
          name: 'forms_auto_suggest_box',
          builder: (context, state) => DeferredWidget(
            forms.loadLibrary,
            () => forms.AutoSuggestBoxPage(),
          ),
        ),

        /// ComboBox
        GoRoute(
          path: '/forms/combobox',
          name: 'forms_combobox',
          builder: (context, state) => DeferredWidget(
            forms.loadLibrary,
            () => forms.ComboBoxPage(),
          ),
        ),

        /// TimePicker
        GoRoute(
          path: '/forms/time_picker',
          name: 'forms_time_picker',
          builder: (context, state) => DeferredWidget(
            forms.loadLibrary,
            () => forms.TimePickerPage(),
          ),
        ),

        /// DatePicker
        GoRoute(
          path: '/forms/date_picker',
          name: 'forms_date_picker',
          builder: (context, state) => DeferredWidget(
            forms.loadLibrary,
            () => forms.DatePickerPage(),
          ),
        ),

        /// /// Navigation
        /// NavigationView
        GoRoute(
          path: '/navigation/navigation_view',
          name: 'navigation_nav_view',
          builder: (context, state) => DeferredWidget(
            navigation.loadLibrary,
            () => navigation.NavigationViewPage(),
          ),
        ),

        /// TabView
        GoRoute(
          path: '/navigation/tab_view',
          name: 'navigation_tab_view',
          builder: (context, state) => DeferredWidget(
            navigation.loadLibrary,
            () => navigation.TabViewPage(),
          ),
        ),

        /// TreeView
        GoRoute(
          path: '/navigation/tree_view',
          name: 'navigation_tree_view',
          builder: (context, state) => DeferredWidget(
            navigation.loadLibrary,
            () => navigation.TreeViewPage(),
          ),
        ),

        /// /// Surfaces
        /// Acrylic
        GoRoute(
          path: '/surfaces/acrylic',
          name: 'surfaces_acrylic',
          builder: (context, state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.AcrylicPage(),
          ),
        ),

        /// CommandBar
        GoRoute(
          path: '/surfaces/command_bar',
          name: 'surfaces_command_bar',
          builder: (context, state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.CommandBarsPage(),
          ),
        ),

        /// Expander
        GoRoute(
          path: '/surfaces/expander',
          name: 'surfaces_expander',
          builder: (context, state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.ExpanderPage(),
          ),
        ),

        /// InfoBar
        GoRoute(
          path: '/surfaces/info_bar',
          name: 'surfaces_info_bar',
          builder: (context, state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.InfoBarsPage(),
          ),
        ),

        /// Progress Indicators
        GoRoute(
          path: '/surfaces/progress_indicators',
          name: 'surfaces_progress_indicators',
          builder: (context, state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.ProgressIndicatorsPage(),
          ),
        ),

        /// Tiles
        GoRoute(
          path: '/surfaces/tiles',
          name: 'surfaces_tiles',
          builder: (context, state) => DeferredWidget(
            surfaces.loadLibrary,
            () => surfaces.TilesPage(),
          ),
        ),

        /// Popups
        /// ContentDialog
        GoRoute(
          path: '/popups/content_dialog',
          name: 'popups_content_dialog',
          builder: (context, state) => DeferredWidget(
            surfaces.loadLibrary,
            () => popups.ContentDialogPage(),
          ),
        ),

        /// Tooltip
        GoRoute(
          path: '/popups/tooltip',
          name: 'popups_tooltip',
          builder: (context, state) => DeferredWidget(
            surfaces.loadLibrary,
            () => popups.TooltipPage(),
          ),
        ),

        /// Flyout
        GoRoute(
          path: '/popups/flyout',
          name: 'popups_flyout',
          builder: (context, state) => DeferredWidget(
            surfaces.loadLibrary,
            () => popups.Flyout2Screen(),
          ),
        ),

        /// /// Theming
        /// Colors
        GoRoute(
          path: '/theming/colors',
          name: 'theming_colors',
          builder: (context, state) => DeferredWidget(
            theming.loadLibrary,
            () => theming.ColorsPage(),
          ),
        ),

        /// Typography
        GoRoute(
          path: '/theming/typography',
          name: 'theming_typography',
          builder: (context, state) => DeferredWidget(
            theming.loadLibrary,
            () => theming.TypographyPage(),
          ),
        ),

        /// Icons
        GoRoute(
          path: '/theming/icons',
          name: 'theming_icons',
          builder: (context, state) => DeferredWidget(
            theming.loadLibrary,
            () => theming.IconsPage(),
          ),
        ),

        /// Reveal Focus
        GoRoute(
          path: '/theming/reveal_focus',
          name: 'theming_reveal_focus',
          builder: (context, state) => DeferredWidget(
            theming.loadLibrary,
            () => theming.RevealFocusPage(),
          ),
        ),
      ],
    ),
  ],
);
