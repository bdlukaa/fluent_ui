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
    await windowManager.waitUntilReadyToShow();

    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setMinimumSize(const Size(500, 600));
    await windowManager.show();
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
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
  final Widget child;
  final BuildContext? shellContext;

  const MyHomePage({
    super.key,
    required this.child,
    required this.shellContext,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  static final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  static final searchKey = GlobalKey(debugLabel: 'Search Bar Key');

  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  late final paneItems = <NavigationPaneItem>[
    _buildPaneItem(
      route: '/',
      title: 'Home',
      icon: const Icon(FluentIcons.home),
    ),
    PaneItemHeader(header: const Text('Inputs')),
    _buildPaneItem(
      route: '/inputs/buttons',
      title: 'Button',
      icon: const Icon(FluentIcons.button_control),
    ),
    _buildPaneItem(
      route: '/inputs/checkbox',
      title: 'Checkbox',
      icon: const Icon(FluentIcons.checkbox_composite),
    ),
    _buildPaneItem(
      route: '/inputs/slider',
      title: 'Slider',
      icon: const Icon(FluentIcons.slider),
    ),
    _buildPaneItem(
      route: '/inputs/toggle_switch',
      title: 'ToggleSwitch',
      icon: const Icon(FluentIcons.toggle_left),
    ),
    PaneItemHeader(header: const Text('Form')),
    _buildPaneItem(
      route: '/forms/text_box',
      title: 'TextBox',
      icon: const Icon(FluentIcons.text_field),
    ),
    _buildPaneItem(
      route: '/forms/auto_suggest_box',
      title: 'AutoSuggestBox',
      icon: const Icon(FluentIcons.page_list),
    ),
    _buildPaneItem(
      route: '/forms/combobox',
      title: 'ComboBox',
      icon: const Icon(FluentIcons.combobox),
    ),
    _buildPaneItem(
      route: '/forms/numberbox',
      title: 'NumberBox',
      icon: const Icon(FluentIcons.number),
    ),
    _buildPaneItem(
      route: '/forms/passwordbox',
      title: 'PasswordBox',
      icon: const Icon(FluentIcons.password_field),
    ),
    _buildPaneItem(
      route: '/forms/time_picker',
      title: 'TimePicker',
      icon: const Icon(FluentIcons.time_picker),
    ),
    _buildPaneItem(
      route: '/forms/date_picker',
      title: 'DatePicker',
      icon: const Icon(FluentIcons.date_time),
    ),
    PaneItemHeader(header: const Text('Navigation')),
    _buildPaneItem(
      route: '/navigation/navigation_view',
      title: 'NavigationView',
      icon: const Icon(FluentIcons.navigation_flipper),
    ),
    _buildPaneItem(
      route: '/navigation/tab_view',
      title: 'TabView',
      icon: const Icon(FluentIcons.table_header_row),
    ),
    _buildPaneItem(
      route: '/navigation/tree_view',
      title: 'TreeView',
      icon: const Icon(FluentIcons.bulleted_tree_list),
    ),
    _buildPaneItem(
      route: '/navigation/breadcrumb_bar',
      title: 'BreadcrumbBar',
      icon: const Icon(FluentIcons.breadcrumb),
    ),
    PaneItemHeader(header: const Text('Surfaces')),
    _buildPaneItem(
      route: '/surfaces/acrylic',
      title: 'Acrylic',
      icon: const Icon(FluentIcons.un_set_color),
    ),
    _buildPaneItem(
      route: '/surfaces/command_bar',
      title: 'CommandBar',
      icon: const Icon(FluentIcons.customize_toolbar),
    ),
    _buildPaneItem(
      route: '/surfaces/expander',
      title: 'Expander',
      icon: const Icon(FluentIcons.expand_all),
    ),
    _buildPaneItem(
      route: '/surfaces/info_bar',
      title: 'InfoBar',
      icon: const Icon(FluentIcons.info_solid),
    ),
    _buildPaneItem(
      route: '/surfaces/progress_indicators',
      title: 'Progress Indicators',
      icon: const Icon(FluentIcons.progress_ring_dots),
    ),
    _buildPaneItem(
      route: '/surfaces/tiles',
      title: 'Tiles',
      icon: const Icon(FluentIcons.tiles),
    ),
    PaneItemHeader(header: const Text('Popups')),
    _buildPaneItem(
      route: '/popups/content_dialog',
      title: 'ContentDialog',
      icon: const Icon(FluentIcons.comment_urgent),
    ),
    _buildPaneItem(
      route: '/popups/tooltip',
      title: 'Tooltip',
      icon: const Icon(FluentIcons.hint_text),
    ),
    _buildPaneItem(
      route: '/popups/flyout',
      title: 'Flyout',
      icon: const Icon(FluentIcons.pop_expand),
    ),
    PaneItemHeader(header: const Text('Theming')),
    _buildPaneItem(
      route: '/theming/colors',
      title: 'Colors',
      icon: const Icon(FluentIcons.color_solid),
    ),
    _buildPaneItem(
      route: '/theming/typography',
      title: 'Typography',
      icon: const Icon(FluentIcons.font_color_a),
    ),
    _buildPaneItem(
      route: '/theming/icons',
      title: 'Icons',
      icon: const Icon(FluentIcons.icon_sets_flag),
    ),
    _buildPaneItem(
      route: '/theming/reveal_focus',
      title: 'Reveal Focus',
      icon: const Icon(FluentIcons.focus),
    ),
    // TODO: Scrollbar, RatingBar
  ];

  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    _buildPaneItem(
      route: '/settings',
      title: 'Settings',
      icon: const Icon(FluentIcons.settings),
    ),
    _LinkPaneItemAction(
      title: const Text('Source code'),
      link: 'https://github.com/bdlukaa/fluent_ui',
      icon: const Icon(FluentIcons.open_source),
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

  PaneItem _buildPaneItem({
    required String route,
    required Widget icon,
    required String title,
  }) =>
      PaneItem(
        key: ValueKey(route),
        icon: icon,
        title: Text(title),
        body: const SizedBox.shrink(),
        onTap: () {
          if (GoRouterState.of(context).uri.toString() != route) {
            context.go(route);
          }
        },
      );

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = paneItems
        .followedBy(footerItems)
        .where((item) => item.key is ValueKey)
        .toList(growable: false)
        .indexWhere((item) {
      final key = item.key;
      return key is ValueKey && key.value == location;
    });

    return index >= 0 ? index : 0;
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
              unselectedIconColor: ButtonState.resolveWith((states) {
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
      paneBodyBuilder: (PaneItem? item, Widget? _) => widget.child,
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
        items: paneItems,
        autoSuggestBox: Builder(builder: (context) {
          return AutoSuggestBox(
            key: searchKey,
            focusNode: searchFocusNode,
            controller: searchController,
            unfocusedColor: Colors.transparent,
            // also need to include sub items from [PaneItemExpander] items
            items: paneItems.followedBy(footerItems).expand<PaneItem>((item) {
              if (item is PaneItemExpander) {
                return item.items.whereType<PaneItem>();
              } else if (item is PaneItem) {
                return [item];
              }
              return [];
            }).map((item) {
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
    super.title,
  }) : super(body: const SizedBox.shrink());

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
    routes: [
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
