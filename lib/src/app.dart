import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;

class FluentApp extends StatefulWidget {
  const FluentApp({
    Key? key,
    this.navigatorKey,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.initialRoute,
    this.pageRouteBuilder,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowWidgetInspector = false,
    this.debugShowCheckedModeBanner = true,
    this.inspectorSelectButtonBuilder,
    this.shortcuts,
    this.actions,
    this.style,
    this.darkStyle,
    this.themeMode,
  })  : routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        backButtonDispatcher = null,
        super(key: key);

  FluentApp.router({
    Key? key,
    this.style,
    this.darkStyle,
    this.themeMode,
    this.routeInformationProvider,
    required this.routeInformationParser,
    required this.routerDelegate,
    BackButtonDispatcher? backButtonDispatcher,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    required Color this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowWidgetInspector = false,
    this.debugShowCheckedModeBanner = true,
    this.inspectorSelectButtonBuilder,
    this.shortcuts,
    this.actions,
  })  : assert(routeInformationParser != null && routerDelegate != null,
            'The routeInformationParser and routerDelegate cannot be null.'),
        assert(supportedLocales.isNotEmpty),
        navigatorObservers = null,
        backButtonDispatcher =
            backButtonDispatcher ?? RootBackButtonDispatcher(),
        navigatorKey = null,
        onGenerateRoute = null,
        pageRouteBuilder = null,
        home = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        routes = null,
        initialRoute = null,
        super(key: key);

  final Style? style;
  final Style? darkStyle;
  final ThemeMode? themeMode;

  final GlobalKey<NavigatorState>? navigatorKey;

  final RouteFactory? onGenerateRoute;

  final InitialRouteListFactory? onGenerateInitialRoutes;

  final PageRouteFactory? pageRouteBuilder;

  final RouteInformationParser<Object>? routeInformationParser;

  final RouterDelegate<Object>? routerDelegate;

  final BackButtonDispatcher? backButtonDispatcher;

  final RouteInformationProvider? routeInformationProvider;

  final Widget? home;

  final Map<String, WidgetBuilder>? routes;

  final RouteFactory? onUnknownRoute;

  final String? initialRoute;

  final List<NavigatorObserver>? navigatorObservers;

  final TransitionBuilder? builder;

  final String title;

  final GenerateAppTitle? onGenerateTitle;

  final Color? color;

  final Locale? locale;

  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  final LocaleListResolutionCallback? localeListResolutionCallback;

  final LocaleResolutionCallback? localeResolutionCallback;

  final Iterable<Locale> supportedLocales;

  final bool showPerformanceOverlay;

  final bool checkerboardRasterCacheImages;

  final bool checkerboardOffscreenLayers;

  final bool showSemanticsDebugger;

  final bool debugShowWidgetInspector;

  final InspectorSelectButtonBuilder? inspectorSelectButtonBuilder;

  final bool debugShowCheckedModeBanner;

  final Map<LogicalKeySet, Intent>? shortcuts;

  final Map<Type, Action<Intent>>? actions;

  static bool showPerformanceOverlayOverride = false;

  static bool debugShowWidgetInspectorOverride = false;

  static bool debugAllowBannerOverride = true;

  @override
  _FluentAppState createState() => _FluentAppState();
}

class _FluentAppState extends State<FluentApp> {
  bool get _usesRouter => widget.routerDelegate != null;

  @override
  Widget build(BuildContext context) {
    return _buildApp(context);
  }

  Style theme(BuildContext context) {
    final mode = widget.themeMode ?? ThemeMode.system;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final usedarkStyle = mode == ThemeMode.dark ||
        (mode == ThemeMode.system && platformBrightness == Brightness.dark);

    Style data =
        (usedarkStyle ? (widget.darkStyle ?? widget.style) : widget.style) ??
            Style.fallback(usedarkStyle ? Brightness.dark : Brightness.light);
    if (data.brightness == null) {
      data = data.copyWith(Style(
        brightness: usedarkStyle ? Brightness.dark : Brightness.light,
      ));
    }
    return data.build();
  }

  Widget _builder(BuildContext context, Widget? child) {
    final theme = this.theme(context);
    return m.Material(
      child: Theme(
        data: theme,
        child: DefaultTextStyle(
          style: TextStyle(
            color: theme.typography?.body?.color,
          ),
          child: child!,
        ),
      ),
    );
  }

  Widget _buildApp(BuildContext context) {
    final fluentColor = widget.color ?? Colors.blue;
    if (_usesRouter) {
      return m.MaterialApp.router(
        key: GlobalObjectKey(this),
        routeInformationProvider: widget.routeInformationProvider,
        routeInformationParser: widget.routeInformationParser!,
        routerDelegate: widget.routerDelegate!,
        backButtonDispatcher: widget.backButtonDispatcher,
        builder: _builder,
        title: widget.title,
        onGenerateTitle: widget.onGenerateTitle,
        color: fluentColor,
        locale: widget.locale,
        localeResolutionCallback: widget.localeResolutionCallback,
        localeListResolutionCallback: widget.localeListResolutionCallback,
        localizationsDelegates: widget.localizationsDelegates,
        supportedLocales: widget.supportedLocales,
        showPerformanceOverlay: widget.showPerformanceOverlay,
        checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
        showSemanticsDebugger: widget.showSemanticsDebugger,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        shortcuts: widget.shortcuts,
        actions: widget.actions,
      );
    }

    return m.MaterialApp(
      key: GlobalObjectKey(this),
      navigatorKey: widget.navigatorKey,
      navigatorObservers: widget.navigatorObservers!,
      home: widget.home,
      routes: widget.routes!,
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
      onUnknownRoute: widget.onUnknownRoute,
      builder: _builder,
      title: widget.title,
      onGenerateTitle: widget.onGenerateTitle,
      color: fluentColor,
      locale: widget.locale,
      localeResolutionCallback: widget.localeResolutionCallback,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      localizationsDelegates: widget.localizationsDelegates,
      supportedLocales: widget.supportedLocales,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
      showSemanticsDebugger: widget.showSemanticsDebugger,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
    );
  }
}
