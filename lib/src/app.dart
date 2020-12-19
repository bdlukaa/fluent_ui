import 'package:flutter/cupertino.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Add the fluent theme to your application.
///
/// Simple usage:
/// ```dart
/// FluentTheme(
///   child: MaterialApp(),
/// )
/// ```
class FluentApp extends StatelessWidget {
  const FluentApp({
    Key key,
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
    this.darkTheme,
    this.theme,
    this.themeMode,
  })  : routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        backButtonDispatcher = null,
        super(key: key);

  FluentApp.router({
    Key key,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.routeInformationProvider,
    @required this.routeInformationParser,
    @required this.routerDelegate,
    BackButtonDispatcher backButtonDispatcher,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    @required this.color,
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
        assert(title != null),
        assert(color != null),
        assert(supportedLocales != null && supportedLocales.isNotEmpty),
        assert(showPerformanceOverlay != null),
        assert(checkerboardRasterCacheImages != null),
        assert(checkerboardOffscreenLayers != null),
        assert(showSemanticsDebugger != null),
        assert(debugShowCheckedModeBanner != null),
        assert(debugShowWidgetInspector != null),
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

  final ThemeData theme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;

  final GlobalKey<NavigatorState> navigatorKey;

  final RouteFactory onGenerateRoute;

  final InitialRouteListFactory onGenerateInitialRoutes;

  final PageRouteFactory pageRouteBuilder;

  final RouteInformationParser<Object> routeInformationParser;

  final RouterDelegate<Object> routerDelegate;

  final BackButtonDispatcher backButtonDispatcher;

  final RouteInformationProvider routeInformationProvider;

  final Widget home;

  final Map<String, WidgetBuilder> routes;

  final RouteFactory onUnknownRoute;

  final String initialRoute;

  final List<NavigatorObserver> navigatorObservers;

  final TransitionBuilder builder;

  final String title;

  final GenerateAppTitle onGenerateTitle;

  final Color color;

  final Locale locale;

  final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates;

  final LocaleListResolutionCallback localeListResolutionCallback;

  final LocaleResolutionCallback localeResolutionCallback;

  final Iterable<Locale> supportedLocales;

  final bool showPerformanceOverlay;

  final bool checkerboardRasterCacheImages;

  final bool checkerboardOffscreenLayers;

  final bool showSemanticsDebugger;

  final bool debugShowWidgetInspector;

  final InspectorSelectButtonBuilder inspectorSelectButtonBuilder;

  final bool debugShowCheckedModeBanner;

  final Map<LogicalKeySet, Intent> shortcuts;

  final Map<Type, Action<Intent>> actions;

  static bool showPerformanceOverlayOverride = false;

  static bool debugShowWidgetInspectorOverride = false;

  static bool debugAllowBannerOverride = true;

  bool get _usesRouter => routerDelegate != null;
  @override
  Widget build(BuildContext context) {
    return _buildApp(context);
  }

  ThemeData _themeData(BuildContext context) {
    final mode = themeMode ?? ThemeMode.system;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final useDarkTheme = mode == ThemeMode.dark ||
        (mode == ThemeMode.system && platformBrightness == Brightness.dark);

    final data = (useDarkTheme ? darkTheme ?? theme : theme) ??
        ThemeData.fallback(
          context,
          useDarkTheme ? Brightness.dark : Brightness.light,
        );
    return data.build(context);
  }

  Widget _builder(BuildContext context, Widget child) {
    return Theme(
        data: _themeData(context), child: _themeData(context).provider(child));
  }

  Widget _buildApp(BuildContext context) {
    final fluentColor = color ?? Colors.blue;

    /// This is the fallback text style
    final textStyle = TextStyle(
      color: _themeData(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    );
    if (_usesRouter) {
      return WidgetsApp.router(
        key: GlobalObjectKey(this),
        routeInformationProvider: routeInformationProvider,
        routeInformationParser: routeInformationParser,
        routerDelegate: routerDelegate,
        backButtonDispatcher: backButtonDispatcher,
        builder: _builder,
        title: title,
        onGenerateTitle: onGenerateTitle,
        textStyle: textStyle,
        color: fluentColor,
        locale: locale,
        localizationsDelegates: _localizationsDelegates,
        localeResolutionCallback: localeResolutionCallback,
        localeListResolutionCallback: localeListResolutionCallback,
        supportedLocales: supportedLocales,
        showPerformanceOverlay: showPerformanceOverlay,
        checkerboardRasterCacheImages: checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: checkerboardOffscreenLayers,
        showSemanticsDebugger: showSemanticsDebugger,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        inspectorSelectButtonBuilder: _inspectorSelectButtonBuilder,
        shortcuts: shortcuts,
        actions: actions,
      );
    }

    return WidgetsApp(
      key: GlobalObjectKey(this),
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return MaterialPageRoute<T>(settings: settings, builder: builder);
      },
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onUnknownRoute: onUnknownRoute,
      builder: _builder,
      title: title,
      onGenerateTitle: onGenerateTitle,
      textStyle: textStyle,
      color: fluentColor,
      locale: locale,
      localizationsDelegates: _localizationsDelegates,
      localeResolutionCallback: localeResolutionCallback,
      localeListResolutionCallback: localeListResolutionCallback,
      supportedLocales: supportedLocales,
      showPerformanceOverlay: showPerformanceOverlay,
      checkerboardRasterCacheImages: checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: checkerboardOffscreenLayers,
      showSemanticsDebugger: showSemanticsDebugger,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      inspectorSelectButtonBuilder: _inspectorSelectButtonBuilder,
      shortcuts: shortcuts,
      actions: actions,
    );
  }

  Iterable<LocalizationsDelegate<dynamic>> get _localizationsDelegates sync* {
    if (localizationsDelegates != null) yield* localizationsDelegates;
    yield DefaultMaterialLocalizations.delegate;
    yield DefaultCupertinoLocalizations.delegate;
  }

  Widget _inspectorSelectButtonBuilder(
      BuildContext context, VoidCallback onPressed) {
    return SizedBox();
  }
}
