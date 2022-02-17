import 'package:flutter/foundation.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';

import '../theme.dart';

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

class Settings extends StatelessWidget {
  const Settings({Key? key, this.controller}) : super(key: key);

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final tooltipThemeData = TooltipThemeData(decoration: () {
      const radius = BorderRadius.zero;
      final shadow = [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(1, 1),
          blurRadius: 10.0,
        ),
      ];
      final border = Border.all(color: Colors.grey[100], width: 0.5);
      if (FluentTheme.of(context).brightness == Brightness.light) {
        return BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: border,
          boxShadow: shadow,
        );
      } else {
        return BoxDecoration(
          color: Colors.grey,
          borderRadius: radius,
          border: border,
          boxShadow: shadow,
        );
      }
    }());

    const spacer = SizedBox(height: 10.0);
    const biggerSpacer = SizedBox(height: 40.0);
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Settings')),
      scrollController: controller,
      children: [
        Text('Theme mode', style: FluentTheme.of(context).typography.subtitle),
        spacer,
        ...List.generate(ThemeMode.values.length, (index) {
          final mode = ThemeMode.values[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RadioButton(
              checked: appTheme.mode == mode,
              onChanged: (value) {
                if (value) {
                  appTheme.mode = mode;
                }
              },
              content: Text('$mode'.replaceAll('ThemeMode.', '')),
            ),
          );
        }),
        biggerSpacer,
        Text(
          'Navigation Pane Display Mode',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        spacer,
        ...List.generate(PaneDisplayMode.values.length, (index) {
          final mode = PaneDisplayMode.values[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RadioButton(
              checked: appTheme.displayMode == mode,
              onChanged: (value) {
                if (value) appTheme.displayMode = mode;
              },
              content: Text(
                mode.toString().replaceAll('PaneDisplayMode.', ''),
              ),
            ),
          );
        }),
        biggerSpacer,
        Text('Navigation Indicator',
            style: FluentTheme.of(context).typography.subtitle),
        spacer,
        ...List.generate(NavigationIndicators.values.length, (index) {
          final mode = NavigationIndicators.values[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RadioButton(
              checked: appTheme.indicator == mode,
              onChanged: (value) {
                if (value) appTheme.indicator = mode;
              },
              content: Text(
                mode.toString().replaceAll('NavigationIndicators.', ''),
              ),
            ),
          );
        }),
        biggerSpacer,
        Text('Accent Color',
            style: FluentTheme.of(context).typography.subtitle),
        spacer,
        Wrap(children: [
          Tooltip(
            style: tooltipThemeData,
            child: _buildColorBlock(appTheme, systemAccentColor),
            message: accentColorNames[0],
          ),
          ...List.generate(Colors.accentColors.length, (index) {
            final color = Colors.accentColors[index];
            return Tooltip(
              style: tooltipThemeData,
              message: accentColorNames[index + 1],
              child: _buildColorBlock(appTheme, color),
            );
          }),
        ]),
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) ...[
          biggerSpacer,
          Text('Window Transparency',
              style: FluentTheme.of(context).typography.subtitle),
          spacer,
          ...List.generate(flutter_acrylic.WindowEffect.values.length, (index) {
            final mode = flutter_acrylic.WindowEffect.values[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RadioButton(
                checked: appTheme.acrylicEffect == mode,
                onChanged: (value) {
                  if (value) {
                    appTheme.acrylicEffect = mode;
                    flutter_acrylic.Window.setEffect(
                      effect: mode,
                      color: FluentTheme.of(context)
                          .acrylicBackgroundColor
                          .withOpacity(0.2),
                      dark: FluentTheme.of(context).brightness.isDark,
                    );
                  }
                },
                content: Text(
                  mode.toString().replaceAll('AcrylicEffect.', ''),
                ),
              ),
            );
          }),
        ],
        biggerSpacer,
        Text('Text Direction',
            style: FluentTheme.of(context).typography.subtitle),
        spacer,
        ...List.generate(TextDirection.values.length, (index) {
          final direction = TextDirection.values[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RadioButton(
              checked: appTheme.textDirection == direction,
              onChanged: (value) {
                if (value) {
                  appTheme.textDirection = direction;
                }
              },
              content: Text(
                '$direction'
                    .replaceAll('TextDirection.', '')
                    .replaceAll('rtl', 'Right to left')
                    .replaceAll('ltr', 'Left to right'),
              ),
            ),
          );
        }).reversed,
      ],
    );
  }

  Widget _buildColorBlock(AppTheme appTheme, AccentColor color) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Button(
        onPressed: () {
          appTheme.color = color;
        },
        style: ButtonStyle(padding: ButtonState.all(EdgeInsets.zero)),
        child: Container(
          height: 40,
          width: 40,
          color: color,
          alignment: Alignment.center,
          child: appTheme.color == color
              ? Icon(
                  FluentIcons.check_mark,
                  color: color.basedOnLuminance(),
                  size: 22.0,
                )
              : null,
        ),
      ),
    );
  }
}
