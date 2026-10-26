import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:windows_task_manger/root_layout.dart';

class TaskMangerApp extends StatelessWidget {
  const TaskMangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(
      builder:
          (context, accent) => FluentApp(
            title: 'Task Manager',
            theme: FluentThemeData(
              navigationPaneTheme: NavigationPaneThemeData(),
              brightness: Brightness.light,
              accentColor: accent.toAccentColor(),
            ),
            darkTheme: FluentThemeData(
              brightness: Brightness.dark,
              accentColor: accent.toAccentColor(),
            ),
            home: RootLayout(),
          ),
    );
  }
}

extension on SystemAccentColor {
  AccentColor toAccentColor() {
    return AccentColor.swatch({
      'darkest': darkest,
      'darker': darker,
      'dark': dark,
      'normal': accent,
      'light': light,
      'lighter': lighter,
      'lightest': lightest,
    });
  }
}
