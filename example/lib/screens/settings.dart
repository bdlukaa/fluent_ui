import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Theme mode',
        style: context.theme!.typography?.subheader,
      ),
      ...List.generate(ThemeMode.values.length, (index) {
        final mode = ThemeMode.values[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(children: [
            RadioButton(
              checked: appTheme.mode == mode,
              onChanged: (value) {
                if (value) {
                  appTheme.mode = mode;
                }
              },
            ),
            SizedBox(width: 4),
            Text('$mode'),
          ]),
        );
      }),
      Text(
        'ThemeMode.system may not work because MediaQuery.of(context).brightness is not implemented on desktop yet.\nWe must wait until its beta release',
        style: context.theme!.typography?.caption,
      ),
    ]);
  }
}
