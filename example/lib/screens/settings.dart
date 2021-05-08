import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
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
      final radius = BorderRadius.zero;
      final shadow = [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: Offset(1, 1),
          blurRadius: 10.0,
        ),
      ];
      final border = Border.all(color: Colors.grey[100]!, width: 0.5);
      if (context.theme.brightness == Brightness.light) {
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
    return ScaffoldPage(
      topBar: PageTopBar(header: Text('Others')),
      contentScrollController: controller,
      content: ListView(
        padding: EdgeInsets.only(bottom: kPageDefaultVerticalPadding),
        controller: controller,
        children: [
          Text('Theme mode', style: context.theme.typography.subtitle),
          ...List.generate(ThemeMode.values.length, (index) {
            final mode = ThemeMode.values[index];
            return RadioListTile(
              checked: appTheme.mode == mode,
              onChanged: (value) {
                if (value) {
                  appTheme.mode = mode;
                }
              },
              title: Text(
                '$mode'.replaceAll('ThemeMode.', ''),
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            );
          }),

          /// MediaQuery.of(context).brightness only doesn't work on windows
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows)
            Text(
              'ThemeMode.system may not work because MediaQuery.of(context).brightness is not implemented on windows yet.'
              '\nWe must wait until Flutter Desktop stable release',
              style: context.theme.typography.caption,
            ),

          Text(
            'Navigation Pane Display Mode',
            style: context.theme.typography.subtitle,
          ),
          ...List.generate(PaneDisplayMode.values.length, (index) {
            final mode = PaneDisplayMode.values[index];
            return RadioListTile(
              checked: appTheme.displayMode == mode,
              onChanged: (value) {
                if (value) {
                  appTheme.displayMode = mode;
                }
              },
              title: Text(
                mode.toString().replaceAll('PaneDisplayMode.', ''),
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            );
          }),
          Text('Accent Color', style: context.theme.typography.subtitle),
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
        ],
      ),
    );
  }

  Widget _buildColorBlock(AppTheme appTheme, AccentColor color) {
    return Button(
      onPressed: () {
        appTheme.color = color;
      },
      style: ButtonThemeData(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.all(2.0),
      ),
      builder: (context, state) {
        return Container(
          height: 40,
          width: 40,
          color: color,
          alignment: Alignment.center,
          child: appTheme.color == color
              ? Icon(Icons.check, color: color.basedOnLuminance())
              : null,
        );
      },
    );
  }
}
