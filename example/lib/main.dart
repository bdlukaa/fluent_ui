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

final _appTheme = AppTheme();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appTheme,
      builder: (context, child) {
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
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.child,
    required this.shellContext,
  });

  final Widget child;
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

  late final List<NavigationPaneItem> originalItems = [
    PaneItem(
      key: const ValueKey('/'),
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
      body: const SizedBox.shrink(),
    ),
    PaneItemHeader(header: const Text('Inputs')),
    PaneItem(
      key: const ValueKey('/inputs/buttons'),
      icon: const Icon(FluentIcons.button_control),
      title: const Text('Button'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/inputs/checkbox'),
      icon: const Icon(FluentIcons.checkbox_composite),
      title: const Text('Checkbox'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/inputs/slider'),
      icon: const Icon(FluentIcons.slider),
      title: const Text('Slider'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/inputs/toggle_switch'),
      icon: const Icon(FluentIcons.toggle_left),
      title: const Text('ToggleSwitch'),
      body: const SizedBox.shrink(),
    ),
    PaneItemHeader(header: const Text('Form')),
    PaneItem(
      key: const ValueKey('/forms/text_box'),
      icon: const Icon(FluentIcons.text_field),
      title: const Text('TextBox'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/forms/auto_suggest_box'),
      icon: const Icon(FluentIcons.page_list),
      title: const Text('AutoSuggestBox'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/forms/combobox'),
      icon: const Icon(FluentIcons.combobox),
      title: const Text('ComboBox'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/forms/numberbox'),
      icon: const Icon(FluentIcons.number),
      title: const Text('NumberBox'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/forms/passwordbox'),
      icon: const Icon(FluentIcons.password_field),
      title: const Text('PasswordBox'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/forms/time_picker'),
      icon: const Icon(FluentIcons.time_picker),
      title: const Text('TimePicker'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/forms/date_picker'),
      icon: const Icon(FluentIcons.date_time),
      title: const Text('DatePicker'),
      body: const SizedBox.shrink(),
    ),
    PaneItemHeader(header: const Text('Navigation')),
    PaneItem(
      key: const ValueKey('/navigation/navigation_view'),
      icon: const Icon(FluentIcons.navigation_flipper),
      title: const Text('NavigationView'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/navigation/tab_view'),
      icon: const Icon(FluentIcons.table_header_row),
      title: const Text('TabView'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/navigation/tree_view'),
      icon: const Icon(FluentIcons.bulleted_tree_list),
      title: const Text('TreeView'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/navigation/breadcrumb_bar'),
      icon: const Icon(FluentIcons.breadcrumb),
      title: const Text('BreadcrumbBar'),
      body: const SizedBox.shrink(),
    ),
    PaneItemHeader(header: const Text('Surfaces')),
    PaneItem(
      key: const ValueKey('/surfaces/acrylic'),
      icon: const Icon(FluentIcons.un_set_color),
      title: const Text('Acrylic'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/surfaces/command_bar'),
      icon: const Icon(FluentIcons.customize_toolbar),
      title: const Text('CommandBar'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/surfaces/expander'),
      icon: const Icon(FluentIcons.expand_all),
      title: const Text('Expander'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/surfaces/info_bar'),
      icon: const Icon(FluentIcons.info_solid),
      title: const Text('InfoBar'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/surfaces/progress_indicators'),
      icon: const Icon(FluentIcons.progress_ring_dots),
      title: const Text('Progress Indicators'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/surfaces/tiles'),
      icon: const Icon(FluentIcons.tiles),
      title: const Text('Tiles'),
      body: const SizedBox.shrink(),
    ),
    PaneItemHeader(header: const Text('Popups')),
    PaneItem(
      key: const ValueKey('/popups/content_dialog'),
      icon: const Icon(FluentIcons.comment_urgent),
      title: const Text('ContentDialog'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/popups/tooltip'),
      icon: const Icon(FluentIcons.hint_text),
      title: const Text('Tooltip'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/popups/flyout'),
      icon: const Icon(FluentIcons.pop_expand),
      title: const Text('Flyout'),
      body: const SizedBox.shrink(),
    ),
    PaneItemHeader(header: const Text('Theming')),
    PaneItem(
      key: const ValueKey('/theming/colors'),
      icon: const Icon(FluentIcons.color_solid),
      title: const Text('Colors'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/theming/typography'),
      icon: const Icon(FluentIcons.font_color_a),
      title: const Text('Typography'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/theming/icons'),
      icon: const Icon(FluentIcons.icon_sets_flag),
      title: const Text('Icons'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/theming/reveal_focus'),
      icon: const Icon(FluentIcons.focus),
      title: const Text('Reveal Focus'),
      body: const SizedBox.shrink(),
    ),
    // TODO: Scrollbar, RatingBar
  ].map<NavigationPaneItem>((e) {
    PaneItem buildPaneItem(PaneItem item) {
      return PaneItem(
        key: item.key,
        icon: item.icon,
        title: item.title,
        body: item.body,
        onTap: () {
          final path = (item.key as ValueKey).value;
          if (GoRouterState.of(context).uri.toString() != path) {
            context.go(path);
          }
          item.onTap?.call();
        },
      );
    }

    if (e is PaneItemExpander) {
      return PaneItemExpander(
        key: e.key,
        icon: e.icon,
        title: e.title,
        body: e.body,
        items: e.items.map((item) {
          if (item is PaneItem) return buildPaneItem(item);
          return item;
        }).toList(),
      );
    }
    if (e is PaneItem) return buildPaneItem(e);
    return e;
  }).toList();
  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey('/settings'),
      icon: const Icon(FluentIcons.settings),
      title: const Text('Settings'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != '/settings') {
          context.go('/settings');
        }
      },
    ),
    _LinkPaneItemAction(
      icon: const Icon(FluentIcons.open_source),
      title: const Text('Source code'),
      link: 'https://github.com/bdlukaa/fluent_ui',
      body: const SizedBox.shrink(),
    ),
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
    final location = GoRouterState.of(context).uri.toString();
    int indexOriginal = originalItems
        .where((item) => item.key != null)
        .toList()
        .indexWhere((item) => item.key == Key(location));

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
    final localizations = FluentLocalizations.of(context);

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
        leading: () {
          final enabled = widget.shellContext != null && router.canPop();

          final onPressed = enabled
              ? () {
                  if (router.canPop()) {
                    context.pop();
                    setState(() {});
                  }
                }
              : null;
          return NavigationPaneTheme(
            data: NavigationPaneTheme.of(context).merge(NavigationPaneThemeData(
              unselectedIconColor: WidgetStateProperty.resolveWith((states) {
                if (states.isDisabled) {
                  return ButtonThemeData.buttonColor(context, states);
                }
                return ButtonThemeData.uncheckedInputColor(
                  FluentTheme.of(context),
                  states,
                ).basedOnLuminance();
              }),
            )),
            child: Builder(
              builder: (context) => PaneItem(
                icon: const Center(child: Icon(FluentIcons.back, size: 12.0)),
                title: Text(localizations.backButtonTooltip),
                body: const SizedBox.shrink(),
                enabled: enabled,
              ).build(
                context,
                false,
                onPressed,
                displayMode: PaneDisplayMode.compact,
              ),
            ),
          );
        }(),
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
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
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
          ),
          if (!kIsWeb) const WindowButtons(),
        ]),
      ),
      paneBodyBuilder: (item, child) {
        final name =
            item?.key is ValueKey ? (item!.key as ValueKey).value : null;
        return FocusTraversalGroup(
          key: ValueKey('body$name'),
          child: widget.child,
        );
      },
      pane: NavigationPane(
        selected: _calculateSelectedIndex(context),
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
        autoSuggestBox: Builder(builder: (context) {
          return AutoSuggestBox(
            key: searchKey,
            focusNode: searchFocusNode,
            controller: searchController,
            unfocusedColor: Colors.transparent,
            // also need to include sub items from [PaneItemExpander] items
            items: <PaneItem>[
              ...originalItems
                  .whereType<PaneItemExpander>()
                  .expand<PaneItem>((item) {
                return [
                  item,
                  ...item.items.whereType<PaneItem>(),
                ];
              }),
              ...originalItems
                  .where(
                    (item) => item is PaneItem && item is! PaneItemExpander,
                  )
                  .cast<PaneItem>(),
            ].map((item) {
              assert(item.title is Text);
              final text = (item.title as Text).data!;
              return AutoSuggestBoxItem(
                label: text,
                value: text,
                onSelected: () {
                  item.onTap?.call();
                  searchController.clear();
                  searchFocusNode.unfocus();
                  final view = NavigationView.of(context);
                  if (view.compactOverlayOpen) {
                    view.compactOverlayOpen = false;
                  } else if (view.minimalPaneOpen) {
                    view.minimalPaneOpen = false;
                  }
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
          );
        }),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: footerItems,
      ),
      onOpenSearch: searchFocusNode.requestFocus,
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
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
      builder: (context, followLink) => Semantics(
        link: true,
        child: super.build(
          context,
          selected,
          followLink,
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
final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    builder: (context, state, child) {
      return MyHomePage(
        shellContext: _shellNavigatorKey.currentContext,
        child: child,
      );
    },
    routes: <GoRoute>[
      /// Home
      GoRoute(path: '/', builder: (context, state) => const HomePage()),

      /// Settings
      GoRoute(path: '/settings', builder: (context, state) => const Settings()),

      /// /// Input
      /// Buttons
      GoRoute(
        path: '/inputs/buttons',
        builder: (context, state) => DeferredWidget(
          inputs.loadLibrary,
          () => inputs.ButtonPage(),
        ),
      ),

      /// Checkbox
      GoRoute(
        path: '/inputs/checkbox',
        builder: (context, state) => DeferredWidget(
          inputs.loadLibrary,
          () => inputs.CheckBoxPage(),
        ),
      ),

      /// Slider
      GoRoute(
        path: '/inputs/slider',
        builder: (context, state) => DeferredWidget(
          inputs.loadLibrary,
          () => inputs.SliderPage(),
        ),
      ),

      /// ToggleSwitch
      GoRoute(
        path: '/inputs/toggle_switch',
        builder: (context, state) => DeferredWidget(
          inputs.loadLibrary,
          () => inputs.ToggleSwitchPage(),
        ),
      ),

      /// /// Form
      /// TextBox
      GoRoute(
        path: '/forms/text_box',
        builder: (context, state) => DeferredWidget(
          forms.loadLibrary,
          () => forms.TextBoxPage(),
        ),
      ),

      /// AutoSuggestBox
      GoRoute(
        path: '/forms/auto_suggest_box',
        builder: (context, state) => DeferredWidget(
          forms.loadLibrary,
          () => forms.AutoSuggestBoxPage(),
        ),
      ),

      /// ComboBox
      GoRoute(
        path: '/forms/combobox',
        builder: (context, state) => DeferredWidget(
          forms.loadLibrary,
          () => forms.ComboBoxPage(),
        ),
      ),

      /// NumberBox
      GoRoute(
        path: '/forms/numberbox',
        builder: (context, state) => DeferredWidget(
          forms.loadLibrary,
          () => forms.NumberBoxPage(),
        ),
      ),

      GoRoute(
        path: '/forms/passwordbox',
        builder: (context, state) => DeferredWidget(
          forms.loadLibrary,
          () => forms.PasswordBoxPage(),
        ),
      ),

      /// TimePicker
      GoRoute(
        path: '/forms/time_picker',
        builder: (context, state) => DeferredWidget(
          forms.loadLibrary,
          () => forms.TimePickerPage(),
        ),
      ),

      /// DatePicker
      GoRoute(
        path: '/forms/date_picker',
        builder: (context, state) => DeferredWidget(
          forms.loadLibrary,
          () => forms.DatePickerPage(),
        ),
      ),

      /// /// Navigation
      /// NavigationView
      GoRoute(
        path: '/navigation/navigation_view',
        builder: (context, state) => DeferredWidget(
          navigation.loadLibrary,
          () => navigation.NavigationViewPage(),
        ),
      ),
      GoRoute(
        path: '/navigation_view',
        builder: (context, state) => DeferredWidget(
          navigation.loadLibrary,
          () => navigation.NavigationViewShellRoute(),
        ),
      ),

      /// TabView
      GoRoute(
        path: '/navigation/tab_view',
        builder: (context, state) => DeferredWidget(
          navigation.loadLibrary,
          () => navigation.TabViewPage(),
        ),
      ),

      /// TreeView
      GoRoute(
        path: '/navigation/tree_view',
        builder: (context, state) => DeferredWidget(
          navigation.loadLibrary,
          () => navigation.TreeViewPage(),
        ),
      ),

      /// BreadcrumbBar
      GoRoute(
        path: '/navigation/breadcrumb_bar',
        builder: (context, state) => DeferredWidget(
          navigation.loadLibrary,
          () => navigation.BreadcrumbBarPage(),
        ),
      ),

      /// /// Surfaces
      /// Acrylic
      GoRoute(
        path: '/surfaces/acrylic',
        builder: (context, state) => DeferredWidget(
          surfaces.loadLibrary,
          () => surfaces.AcrylicPage(),
        ),
      ),

      /// CommandBar
      GoRoute(
        path: '/surfaces/command_bar',
        builder: (context, state) => DeferredWidget(
          surfaces.loadLibrary,
          () => surfaces.CommandBarsPage(),
        ),
      ),

      /// Expander
      GoRoute(
        path: '/surfaces/expander',
        builder: (context, state) => DeferredWidget(
          surfaces.loadLibrary,
          () => surfaces.ExpanderPage(),
        ),
      ),

      /// InfoBar
      GoRoute(
        path: '/surfaces/info_bar',
        builder: (context, state) => DeferredWidget(
          surfaces.loadLibrary,
          () => surfaces.InfoBarsPage(),
        ),
      ),

      /// Progress Indicators
      GoRoute(
        path: '/surfaces/progress_indicators',
        builder: (context, state) => DeferredWidget(
          surfaces.loadLibrary,
          () => surfaces.ProgressIndicatorsPage(),
        ),
      ),

      /// Tiles
      GoRoute(
        path: '/surfaces/tiles',
        builder: (context, state) => DeferredWidget(
          surfaces.loadLibrary,
          () => surfaces.TilesPage(),
        ),
      ),

      /// Popups
      /// ContentDialog
      GoRoute(
        path: '/popups/content_dialog',
        builder: (context, state) => DeferredWidget(
          surfaces.loadLibrary,
          () => popups.ContentDialogPage(),
        ),
      ),

      /// Tooltip
      GoRoute(
        path: '/popups/tooltip',
        builder: (context, state) => DeferredWidget(
          surfaces.loadLibrary,
          () => popups.TooltipPage(),
        ),
      ),

      /// Flyout
      GoRoute(
        path: '/popups/flyout',
        builder: (context, state) => DeferredWidget(
          surfaces.loadLibrary,
          () => popups.Flyout2Screen(),
        ),
      ),

      /// /// Theming
      /// Colors
      GoRoute(
        path: '/theming/colors',
        builder: (context, state) => DeferredWidget(
          theming.loadLibrary,
          () => theming.ColorsPage(),
        ),
      ),

      /// Typography
      GoRoute(
        path: '/theming/typography',
        builder: (context, state) => DeferredWidget(
          theming.loadLibrary,
          () => theming.TypographyPage(),
        ),
      ),

      /// Icons
      GoRoute(
        path: '/theming/icons',
        builder: (context, state) => DeferredWidget(
          theming.loadLibrary,
          () => theming.IconsPage(),
        ),
      ),

      /// Reveal Focus
      GoRoute(
        path: '/theming/reveal_focus',
        builder: (context, state) => DeferredWidget(
          theming.loadLibrary,
          () => theming.RevealFocusPage(),
        ),
      ),
    ],
  ),
]);
