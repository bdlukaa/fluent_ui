import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class MenuBarPage extends StatefulWidget {
  const MenuBarPage({super.key});

  @override
  State<MenuBarPage> createState() => _MenuBarPageState();
}

class _MenuBarPageState extends State<MenuBarPage> with PageMixin {
  var _orientation = 'landscape';
  var _iconSize = 'medium_icons';
  final _programaticallyKey = GlobalKey<MenuBarState>();

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('MenuBar')),
      children: [
        const Text(
          'A MenuBar is a horizontal list of items that can be clicked to show a menu flyout. It is used to provide a list of options to the user.',
        ),
        subtitle(content: const Text('A simple MenuBar')),
        CodeSnippetCard(
          codeSnippet: '''
var _orientation = 'landscape';
var _iconSize = 'medium_icons';''

MenuBar(
  items: [
    MenuFlyoutSubItem(
      text: const Text('New'),
      items: (context) {
        return [
          MenuFlyoutItem(
            text: const Text('Plain Text Documents'),
            onPressed: () {},
          ),
          MenuFlyoutItem(
            text: const Text('Rich Text Documents'),
            onPressed: () {},
          ),
          MenuFlyoutItem(
            text: const Text('Other Formats'),
            onPressed: () {},
          ),
        ];
      },
    ),
    MenuFlyoutItem(text: const Text('Open'), onPressed: () {}),
    MenuFlyoutItem(text: const Text('Save'), onPressed: () {}),
    const MenuFlyoutSeparator(),
    MenuFlyoutItem(text: const Text('Exit'), onPressed: () {}),
  ]
)
''',
          child: MenuBar(
            items: [
              MenuBarItem(
                title: 'File',
                items: [
                  MenuFlyoutItem(text: const Text('New'), onPressed: () {}),
                  MenuFlyoutItem(text: const Text('Open'), onPressed: () {}),
                  MenuFlyoutItem(text: const Text('Save'), onPressed: () {}),
                  MenuFlyoutItem(text: const Text('Exit'), onPressed: () {}),
                ],
              ),
              MenuBarItem(
                title: 'Edit',
                items: [
                  MenuFlyoutItem(text: const Text('Cut'), onPressed: () {}),
                  MenuFlyoutItem(text: const Text('Copy'), onPressed: () {}),
                  MenuFlyoutItem(text: const Text('Paste'), onPressed: () {}),
                ],
              ),
              MenuBarItem(
                title: 'Help',
                items: [
                  MenuFlyoutItem(text: const Text('About'), onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
        subtitle(
          content: const Text(
            'MenuBar with submenus, separators and radio items',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''
var _orientation = 'landscape';
var _iconSize = 'medium_icons';''

MenuBar(
  items: [
    MenuBarItem(title: 'File', items: [
      MenuFlyoutSubItem(
        text: const Text('New'),
        items: (context) {
          return [
            MenuFlyoutItem(
              text: const Text('Plain Text Documents'),
              onPressed: () {},
            ),
            MenuFlyoutItem(
              text: const Text('Rich Text Documents'),
              onPressed: () {},
            ),
            MenuFlyoutItem(
              text: const Text('Other Formats'),
              onPressed: () {},
            ),
          ];
        },
      ),
      MenuFlyoutItem(text: const Text('Open'), onPressed: () {}),
      MenuFlyoutItem(text: const Text('Save'), onPressed: () {}),
      const MenuFlyoutSeparator(),
      MenuFlyoutItem(text: const Text('Exit'), onPressed: () {}),
    ]),
    MenuBarItem(title: 'Edit', items: [
      MenuFlyoutItem(text: const Text('Undo'), onPressed: () {}),
      MenuFlyoutItem(text: const Text('Cut'), onPressed: () {}),
      MenuFlyoutItem(text: const Text('Copy'), onPressed: () {}),
      MenuFlyoutItem(text: const Text('Paste'), onPressed: () {}),
    ]),
    MenuBarItem(title: 'View', items: [
      MenuFlyoutItem(text: const Text('Output'), onPressed: () {}),
      const MenuFlyoutSeparator(),
      RadioMenuFlyoutItem<String>(
        text: const Text('Landscape'),
        value: 'landscape',
        groupValue: _orientation,
        onChanged: (v) => setState(() => _orientation = v),
      ),
      RadioMenuFlyoutItem<String>(
        text: const Text('Portrait'),
        value: 'portrait',
        groupValue: _orientation,
        onChanged: (v) => setState(() => _orientation = v),
      ),
      const MenuFlyoutSeparator(),
      RadioMenuFlyoutItem<String>(
        text: const Text('Small icons'),
        value: 'small_icons',
        groupValue: _iconSize,
        onChanged: (v) => setState(() => _iconSize = v),
      ),
      RadioMenuFlyoutItem<String>(
        text: const Text('Medium icons'),
        value: 'medium_icons',
        groupValue: _iconSize,
        onChanged: (v) => setState(() => _iconSize = v),
      ),
      RadioMenuFlyoutItem<String>(
        text: const Text('Large icons'),
        value: 'large_icons',
        groupValue: _iconSize,
        onChanged: (v) => setState(() => _iconSize = v),
      ),
    ]),
    MenuBarItem(title: 'Help', items: [
      MenuFlyoutItem(text: const Text('About'), onPressed: () {}),
    ]),
  ],
)
''',
          child: MenuBar(
            items: [
              MenuBarItem(
                title: 'File',
                items: [
                  MenuFlyoutSubItem(
                    text: const Text('New'),
                    items: (final context) {
                      return [
                        MenuFlyoutItem(
                          text: const Text('Plain Text Documents'),
                          onPressed: () {},
                        ),
                        MenuFlyoutItem(
                          text: const Text('Rich Text Documents'),
                          onPressed: () {},
                        ),
                        MenuFlyoutItem(
                          text: const Text('Other Formats'),
                          onPressed: () {},
                        ),
                      ];
                    },
                  ),
                  MenuFlyoutItem(text: const Text('Open'), onPressed: () {}),
                  MenuFlyoutItem(text: const Text('Save'), onPressed: () {}),
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(text: const Text('Exit'), onPressed: () {}),
                ],
              ),
              MenuBarItem(
                title: 'Edit',
                items: [
                  MenuFlyoutItem(text: const Text('Undo'), onPressed: () {}),
                  MenuFlyoutItem(text: const Text('Cut'), onPressed: () {}),
                  MenuFlyoutItem(text: const Text('Copy'), onPressed: () {}),
                  MenuFlyoutItem(text: const Text('Paste'), onPressed: () {}),
                ],
              ),
              MenuBarItem(
                title: 'View',
                items: [
                  MenuFlyoutItem(text: const Text('Output'), onPressed: () {}),
                  const MenuFlyoutSeparator(),
                  RadioMenuFlyoutItem<String>(
                    text: const Text('Landscape'),
                    value: 'landscape',
                    groupValue: _orientation,
                    onChanged: (final v) => setState(() => _orientation = v),
                  ),
                  RadioMenuFlyoutItem<String>(
                    text: const Text('Portrait'),
                    value: 'portrait',
                    groupValue: _orientation,
                    onChanged: (final v) => setState(() => _orientation = v),
                  ),
                  const MenuFlyoutSeparator(),
                  RadioMenuFlyoutItem<String>(
                    text: const Text('Small icons'),
                    value: 'small_icons',
                    groupValue: _iconSize,
                    onChanged: (final v) => setState(() => _iconSize = v),
                  ),
                  RadioMenuFlyoutItem<String>(
                    text: const Text('Medium icons'),
                    value: 'medium_icons',
                    groupValue: _iconSize,
                    onChanged: (final v) => setState(() => _iconSize = v),
                  ),
                  RadioMenuFlyoutItem<String>(
                    text: const Text('Large icons'),
                    value: 'large_icons',
                    groupValue: _iconSize,
                    onChanged: (final v) => setState(() => _iconSize = v),
                  ),
                ],
              ),
              MenuBarItem(
                title: 'Help',
                items: [
                  MenuFlyoutItem(text: const Text('About'), onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
        subtitle(content: const Text('Open a MenuBar programatically')),
        description(
          content: const Text(
            'You can open a MenuBar programatically using a global key.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''
final key = GlobalKey<MenuBarState>();

MenuBar(
  key: key,
  items: [
    MenuBarItem(title: 'File', items: [
      MenuFlyoutItem(text: const Text('New'), onPressed: () {}),
      MenuFlyoutItem(text: const Text('Open'), onPressed: () {}),
      MenuFlyoutItem(text: const Text('Save'), onPressed: () {}),
      MenuFlyoutItem(text: const Text('Exit'), onPressed: () {}),
    ]),
    MenuBarItem(title: 'Edit', items: [
      MenuFlyoutItem(text: const Text('Cut'), onPressed: () {}),
      MenuFlyoutItem(text: const Text('Copy'), onPressed: () {}),
      MenuFlyoutItem(text: const Text('Paste'), onPressed: () {}),
    ]),
    MenuBarItem(title: 'Help', items: [
      MenuFlyoutItem(text: const Text('About'), onPressed: () {}),
    ]),
  ],
),

key.currentState?.showItemAt(items1);
''',
          child: Row(
            children: [
              Expanded(
                child: MenuBar(
                  key: _programaticallyKey,
                  items: [
                    MenuBarItem(
                      title: 'File',
                      items: [
                        MenuFlyoutItem(
                          text: const Text('New'),
                          onPressed: () {},
                        ),
                        MenuFlyoutItem(
                          text: const Text('Open'),
                          onPressed: () {},
                        ),
                        MenuFlyoutItem(
                          text: const Text('Save'),
                          onPressed: () {},
                        ),
                        MenuFlyoutItem(
                          text: const Text('Exit'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    MenuBarItem(
                      title: 'Edit',
                      items: [
                        MenuFlyoutItem(
                          text: const Text('Cut'),
                          onPressed: () {},
                        ),
                        MenuFlyoutItem(
                          text: const Text('Copy'),
                          onPressed: () {},
                        ),
                        MenuFlyoutItem(
                          text: const Text('Paste'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    MenuBarItem(
                      title: 'Help',
                      items: [
                        MenuFlyoutItem(
                          text: const Text('About'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Button(
                onPressed: () {
                  _programaticallyKey.currentState?.showItemAt(1);
                },
                child: const Text('Open MenuBar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
