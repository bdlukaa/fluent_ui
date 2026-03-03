// ignore_for_file: constant_identifier_names

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../widgets/page.dart';

const List<String> accentColorNames = [
  'System',
  'Yellow',
  'Orange',
  'Red',
  'Magenta',
  'Purple',
  'Blue',
  'Teal',
  'Green',
];

bool get kIsWindowEffectsSupported {
  return !kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);
}

const _LinuxWindowEffects = [WindowEffect.disabled, WindowEffect.transparent];

const _WindowsWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.solid,
  WindowEffect.transparent,
  WindowEffect.aero,
  WindowEffect.acrylic,
  WindowEffect.mica,
  WindowEffect.tabbed,
];

const _MacosWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.titlebar,
  WindowEffect.selection,
  WindowEffect.menu,
  WindowEffect.popover,
  WindowEffect.sidebar,
  WindowEffect.headerView,
  WindowEffect.sheet,
  WindowEffect.windowBackground,
  WindowEffect.hudWindow,
  WindowEffect.fullScreenUI,
  WindowEffect.toolTip,
  WindowEffect.contentBackground,
  WindowEffect.underWindowBackground,
  WindowEffect.underPageBackground,
];

List<WindowEffect> get currentWindowEffects {
  if (kIsWeb) return [];

  if (defaultTargetPlatform == TargetPlatform.windows) {
    return _WindowsWindowEffects;
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    return _LinuxWindowEffects;
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    return _MacosWindowEffects;
  }

  return [];
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with PageMixin {
  @override
  Widget build(final BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final appTheme = context.watch<AppTheme>();
    const spacer = SizedBox(height: 10);
    const biggerSpacer = SizedBox(height: 40);

    const supportedLocales = FluentLocalizations.supportedLocales;
    final currentLocale =
        appTheme.locale ?? Localizations.maybeLocaleOf(context);
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Settings')),
      children: [
        Text('Theme mode', style: FluentTheme.of(context).typography.subtitle),
        spacer,
        RadioGroup<ThemeMode>(
          groupValue: appTheme.mode,
          onChanged: (final value) {
            if (value != null) {
              appTheme.mode = value;
              if (kIsWindowEffectsSupported) {
                // some window effects require on [dark] to look good.
                // appTheme.setEffect(WindowEffect.disabled, context);
                appTheme.setEffect(appTheme.windowEffect, context);
              }
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: List.generate(ThemeMode.values.length, (final index) {
              final mode = ThemeMode.values[index];
              return RadioButton<ThemeMode>(
                value: mode,
                content: Text('$mode'.replaceAll('ThemeMode.', '')),
              );
            }),
          ),
        ),
        biggerSpacer,
        Text(
          'Navigation Pane Display Mode',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        spacer,
        RadioGroup<PaneDisplayMode>(
          groupValue: appTheme.displayMode,
          onChanged: (value) {
            if (value != null) appTheme.displayMode = value;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: List.generate(PaneDisplayMode.values.length, (index) {
              final mode = PaneDisplayMode.values[index];
              return RadioButton<PaneDisplayMode>(
                value: mode,
                content: Text(
                  mode.toString().replaceAll('PaneDisplayMode.', ''),
                ),
              );
            }),
          ),
        ),
        biggerSpacer,
        Text(
          'Navigation Indicator',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        spacer,
        RadioGroup<NavigationIndicators>(
          groupValue: appTheme.indicator,
          onChanged: (value) {
            if (value != null) appTheme.indicator = value;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: List.generate(NavigationIndicators.values.length, (
              final index,
            ) {
              final mode = NavigationIndicators.values[index];
              return RadioButton<NavigationIndicators>(
                value: mode,
                content: Text(
                  mode.toString().replaceAll('NavigationIndicators.', ''),
                ),
              );
            }),
          ),
        ),
        biggerSpacer,
        Text(
          'Visual Density',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        description(
          content: const Text(
            'Controls the compact sizing of UI elements. Compact mode reduces '
            'the height and padding of controls.',
          ),
        ),
        spacer,
        RadioGroup<VisualDensity>(
          groupValue: appTheme.visualDensity,
          onChanged: (value) {
            if (value != null) appTheme.visualDensity = value;
          },
          child: const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              RadioButton<VisualDensity>(
                value: VisualDensity.standard,
                content: Text('Standard'),
              ),
              RadioButton<VisualDensity>(
                value: VisualDensity.compact,
                content: Text('Compact'),
              ),
            ],
          ),
        ),
        biggerSpacer,
        Text(
          'Accent Color',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        spacer,
        Wrap(
          children: [
            Tooltip(
              message: accentColorNames[0],
              child: _buildColorBlock(appTheme, systemAccentColor),
            ),
            ...List.generate(Colors.accentColors.length, (final index) {
              final color = Colors.accentColors[index];
              return Tooltip(
                message: accentColorNames[index + 1],
                child: _buildColorBlock(appTheme, color),
              );
            }),
          ],
        ),
        if (kIsWindowEffectsSupported) ...[
          biggerSpacer,
          Text(
            'Window Transparency',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          description(
            content: Text(
              'Running on ${defaultTargetPlatform.toString().replaceAll('TargetPlatform.', '')}',
            ),
          ),
          spacer,
          RadioGroup<WindowEffect>(
            groupValue: appTheme.windowEffect,
            onChanged: (final value) {
              if (value != null) {
                appTheme.windowEffect = value;
                appTheme.setEffect(value, context);
              }
            },
            child: Row(
              spacing: 8,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: List.generate(
                      currentWindowEffects
                          .take(currentWindowEffects.length ~/ 2)
                          .length,
                      (final index) {
                        final mode = currentWindowEffects[index];
                        return RadioButton<WindowEffect>(
                          value: mode,
                          content: Text(
                            mode.toString().replaceAll('WindowEffect.', ''),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: List.generate(
                      currentWindowEffects
                          .take(currentWindowEffects.length ~/ 2)
                          .length,
                      (final index) {
                        final mode =
                            currentWindowEffects[index +
                                currentWindowEffects.length ~/ 2];
                        return RadioButton<WindowEffect>(
                          value: mode,
                          content: Text(
                            mode.toString().replaceAll('WindowEffect.', ''),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        biggerSpacer,
        Text(
          'Text Direction',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        spacer,
        RadioGroup<TextDirection>(
          groupValue: appTheme.textDirection,
          onChanged: (final value) {
            if (value != null) appTheme.textDirection = value;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: List.generate(TextDirection.values.length, (final index) {
              final direction = TextDirection.values[index];
              return RadioButton<TextDirection>(
                value: direction,
                content: Text(
                  '$direction'
                      .replaceAll('TextDirection.', '')
                      .replaceAll('rtl', 'Right to left')
                      .replaceAll('ltr', 'Left to right'),
                ),
              );
            }).reversed.toList(),
          ),
        ),
        biggerSpacer,
        Text('Locale', style: FluentTheme.of(context).typography.subtitle),
        description(
          content: const Text(
            'The locale used by the Windows UI widgets, such as TimePicker and '
            'DatePicker. This does not reflect the language of this showcase app.',
          ),
        ),
        spacer,
        RadioGroup<Locale>(
          groupValue: currentLocale,
          onChanged: (final value) {
            if (value != null) {
              appTheme.locale = value;
            }
          },
          child: Wrap(
            spacing: 15,
            runSpacing: 10,
            children: List.generate(supportedLocales.length, (final index) {
              final locale = supportedLocales[index];
              return RadioButton<Locale>(
                value: locale,
                content: Text('$locale'),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildColorBlock(final AppTheme appTheme, final AccentColor color) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(2),
      child: Button(
        onPressed: () {
          appTheme.color = color;
        },
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsetsDirectional.zero),
          backgroundColor: WidgetStateProperty.resolveWith((final states) {
            if (states.isPressed) {
              return color.light;
            } else if (states.isHovered) {
              return color.lighter;
            }
            return color;
          }),
        ),
        child: Container(
          height: 40,
          width: 40,
          alignment: AlignmentDirectional.center,
          child: appTheme.color == color
              ? Icon(
                  WindowsIcons.check_mark,
                  color: color.basedOnLuminance(),
                  size: 22,
                )
              : null,
        ),
      ),
    );
  }
}
