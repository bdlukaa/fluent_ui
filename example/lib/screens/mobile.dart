import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class Mobile extends StatefulWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  int _currentIndex = 0;
  int _pillButtonBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: NavigationBody(
        children: [
          ScaffoldPage(
            header: PageHeader(title: Text('Mobile')),
            content: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: PageHeader.horizontalPadding(context),
              ),
              children: [
                Text(
                  'Chips',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                Wrap(spacing: 10.0, runSpacing: 10.0, children: [
                  Chip(
                    image: CircleAvatar(
                      radius: 12.0,
                      child: FlutterLogo(size: 14.0),
                    ),
                    text: Text('Default'),
                    onPressed: () => print('pressed chip'),
                  ),
                  Chip(
                    image: CircleAvatar(
                      radius: 12.0,
                      child: FlutterLogo(size: 14.0),
                    ),
                    text: Text('Disabled'),
                    // Comment the onPressed function to disable the chip
                    // onPressed: () => print('pressed chip'),
                  ),
                  Chip.selected(
                    image: CircleAvatar(
                      radius: 12.0,
                      child: FlutterLogo(size: 14.0),
                    ),
                    text: Text('Active and selected'),
                    onPressed: () => print('pressed selected chip'),
                  ),
                  Chip.selected(
                    image: CircleAvatar(
                      radius: 12.0,
                      child: FlutterLogo(size: 14.0),
                    ),
                    text: Text('Selected'),
                    // Comment the onPressed function to disable the chip
                    // onPressed: () => print('pressed chip'),
                  ),
                ]),
                Text(
                  'Snackbar',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                Wrap(runSpacing: 10.0, spacing: 10.0, children: [
                  // TODO(bdlukaa): add more snackbar examples. The buttons
                  // should not have a decoration, only text style. This should
                  // happen after the button rework.
                  Snackbar(
                    content: const Text('Single-line snackbar'),
                    action: Button(
                      child: const Text('ACTION'),
                      style: const ButtonThemeData(margin: EdgeInsets.zero),
                      onPressed: () {
                        showSnackbar(
                          context,
                          Snackbar(content: Text('New update is available!')),
                        );
                      },
                    ),
                  ),
                  Snackbar(
                    content: const Text(
                      'Multi-line snackbar block. Used when the content is too big',
                    ),
                    extended: true,
                    action: Button(
                      child: const Text('ACTION'),
                      style: const ButtonThemeData(margin: EdgeInsets.zero),
                      onPressed: () {
                        showSnackbar(
                          context,
                          Snackbar(
                            content: Text('New update is availble!'),
                            action: Button(
                              child: Text('DOWNLOAD'),
                              style: ButtonThemeData(margin: EdgeInsets.zero),
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ]),
                Text(
                  'Other',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                Center(
                  child: PillButtonBar(
                    selected: _pillButtonBarIndex,
                    onChanged: (i) => setState(() => _pillButtonBarIndex = i),
                    items: [
                      PillButtonBarItem(text: Text('All')),
                      PillButtonBarItem(text: Text('Mail')),
                      PillButtonBarItem(text: Text('People')),
                      PillButtonBarItem(text: Text('Events')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ScaffoldPage(header: PageHeader(title: Text('Android'))),
          ScaffoldPage(header: PageHeader(title: Text('iOS'))),
        ],
        index: _currentIndex,
      ),
      bottomBar: BottomNavigation(
        index: _currentIndex,
        onChanged: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationItem(
            icon: Icon(Icons.two_k),
            selectedIcon: Icon(Icons.two_k_plus),
            title: Text('Both'),
          ),
          BottomNavigationItem(
            icon: Icon(Icons.phone_android_outlined),
            selectedIcon: Icon(Icons.phone_android),
            title: Text('Android'),
          ),
          BottomNavigationItem(
            icon: Icon(Icons.phone_iphone_outlined),
            selectedIcon: Icon(Icons.phone_iphone),
            title: Text('iOS'),
          ),
        ],
      ),
    );
  }
}
