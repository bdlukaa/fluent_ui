// ignore_for_file: avoid_print

import 'package:fluent_ui/fluent_ui.dart';

class Mobile extends StatefulWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  int _pillButtonBarIndex = 0;
  bool disabled = false;

  @override
  Widget build(BuildContext context) {
    const spacer = SizedBox(height: 10.0);
    const biggerSpacer = SizedBox(height: 40.0);
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Mobile')),
      children: [
        Text(
          'Chips',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        spacer,
        Wrap(spacing: 10.0, runSpacing: 10.0, children: [
          Chip(
            image: const CircleAvatar(
              radius: 12.0,
              child: FlutterLogo(size: 14.0),
            ),
            text: const Text('Default'),
            onPressed: () {
              showBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return BottomSheet(
                    // header: ListTile(
                    //   title: Text(
                    //     'Title',
                    //     style: FluentTheme.of(context)
                    //         .typography
                    //         .subtitle!
                    //         .copyWith(fontWeight: FontWeight.bold),
                    //   ),
                    //   trailing: Row(
                    //     children: List.generate(
                    //       6,
                    //       (_) => Padding(
                    //         padding: EdgeInsets.only(left: 24.0),
                    //         child: Icon(FluentIcons.circle_shape),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    description: const Text('Description or Details here'),
                    children: [
                      const ListTile(
                        leading: Icon(FluentIcons.mail),
                        title: Text('Label'),
                        subtitle: Text('Label'),
                        trailing: Icon(FluentIcons.chevron_right),
                      ),
                      TappableListTile(
                        leading: const Icon(FluentIcons.mail),
                        title: const Text('Label'),
                        subtitle: const Text('Label'),
                        trailing: const Icon(FluentIcons.chevron_right),
                        onTap: () {
                          print('tapped tile');
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Chip(
            image: CircleAvatar(
              radius: 12.0,
              child: FlutterLogo(size: 14.0),
            ),
            text: Text('Disabled'),
            // Comment the onPressed function to disable the chip
            // onPressed: () => print('pressed chip'),
          ),
          Chip.selected(
            image: const CircleAvatar(
              radius: 12.0,
              child: FlutterLogo(size: 14.0),
            ),
            text: const Text('Active and selected'),
            onPressed: () => print('pressed selected chip'),
          ),
          const Chip.selected(
            image: CircleAvatar(
              radius: 12.0,
              child: FlutterLogo(size: 14.0),
            ),
            text: Text('Selected'),
            // Comment the onPressed function to disable the chip
            // onPressed: () => print('pressed chip'),
          ),
        ]),
        biggerSpacer,
        Text(
          'Buttons',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        spacer,
        Wrap(runSpacing: 10.0, spacing: 10.0, children: [
          TextButton(
            child: const Text('Text Button'),
            onPressed: disabled
                ? null
                : () {
                    print('pressed text button');
                  },
          ),
          spacer,
          FilledButton(
            child: const Text('Filled Button'),
            onPressed: disabled
                ? null
                : () {
                    print('pressed filled button');
                  },
          ),
          spacer,
          OutlinedButton(
            child: const Text('Outlined Button'),
            onPressed: disabled
                ? null
                : () {
                    print('pressed outlined button');
                  },
          ),
        ]),
        biggerSpacer,
        Text(
          'Snackbar',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        spacer,
        Wrap(runSpacing: 10.0, spacing: 10.0, children: [
          Snackbar(
            content: const Text('Single-line snackbar'),
            action: TextButton(
              child: const Text('Action'),
              // style: const ButtonThemeData(margin: EdgeInsets.zero),
              onPressed: () {
                showSnackbar(
                  context,
                  const Snackbar(
                    content: Text('New update is available!'),
                  ),
                );
              },
            ),
          ),
          Snackbar(
            content: const Text(
              'Multi-line snackbar block. Used when the content is too big',
            ),
            extended: true,
            action: TextButton(
              child: const Text('Action'),
              onPressed: () {
                showSnackbar(
                  context,
                  Snackbar(
                    content: const Text('New update is availble!'),
                    action: TextButton(
                      child: const Text('Download'),
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          )
        ]),
        biggerSpacer,
        Text(
          'Other',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        spacer,
        PillButtonBar(
          selected: _pillButtonBarIndex,
          onChanged: (i) => setState(() => _pillButtonBarIndex = i),
          items: const [
            PillButtonBarItem(text: Text('All')),
            PillButtonBarItem(text: Text('Mail')),
            PillButtonBarItem(text: Text('People')),
            PillButtonBarItem(text: Text('Events')),
          ],
        ),
        biggerSpacer,
      ],
    );
  }
}
