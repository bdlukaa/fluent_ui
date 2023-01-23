import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class Flyout2Screen extends StatefulWidget {
  const Flyout2Screen({Key? key}) : super(key: key);

  @override
  State<Flyout2Screen> createState() => _Flyout2ScreenState();
}

class _Flyout2ScreenState extends State<Flyout2Screen> with PageMixin {
  final controller = FlyoutController();
  final attachKey = GlobalKey();

  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  bool barrierDismissible = true;
  bool dismissOnPointerMoveAway = false;
  bool dismissWithEsc = true;
  FlyoutPlacementMode placementMode = FlyoutPlacementMode.topCenter;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Flyouts')),
      children: [
        const Text(
          'A flyout is a light dismiss container that can show arbitrary UI as '
          'its content. Flyouts can contain other flyouts or context menus to '
          'create a nested experience.',
        ),
        const SizedBox(height: 8.0),
        Mica(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                description(content: const Text('Config')),
                const SizedBox(height: 8.0),
                Wrap(runSpacing: 10.0, spacing: 10.0, children: [
                  ToggleSwitch(
                    checked: barrierDismissible,
                    onChanged: (v) => setState(() => barrierDismissible = v),
                    content: const Text('Barrier dismissible'),
                  ),
                  ToggleSwitch(
                    checked: dismissOnPointerMoveAway,
                    onChanged: (v) =>
                        setState(() => dismissOnPointerMoveAway = v),
                    content: const Text('Dismiss on pointer move away'),
                  ),
                  ToggleSwitch(
                    checked: dismissWithEsc,
                    onChanged: (v) => setState(() => dismissWithEsc = v),
                    content: const Text('Dismiss with esc'),
                  ),
                  ComboBox<FlyoutPlacementMode>(
                    placeholder: const Text('Placeholder'),
                    items: FlyoutPlacementMode.values
                        .where((mode) => mode != FlyoutPlacementMode.auto)
                        .map((mode) {
                      return ComboBoxItem(
                        value: mode,
                        child: Text(mode.name.uppercaseFirst()),
                      );
                    }).toList(),
                    value: placementMode,
                    onChanged: (mode) {
                      if (mode != null) setState(() => placementMode = mode);
                    },
                  ),
                ]),
              ],
            ),
          ),
        ),
        subtitle(content: const Text('A button with a flyout')),
        CardHighlight(
          codeSnippet: '''FlyoutAttach(
  controller: controller,
  child: Button(
    child: const Text('Clear cart'),
    onPressed: () {},
  )
)''',
          child: Row(children: [
            FlyoutAttach(
              key: attachKey,
              controller: controller,
              child: Button(
                child: const Text('Clear cart'),
                onPressed: () async {
                  controller.showFlyout(
                    autoModeConfiguration: FlyoutAutoConfiguration(
                      preferredMode: placementMode,
                    ),
                    barrierDismissible: barrierDismissible,
                    dismissOnPointerMoveAway: dismissOnPointerMoveAway,
                    dismissWithEsc: dismissWithEsc,
                    builder: (context) {
                      return FlyoutContent(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'All items will be removed. Do you want to continue?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12.0),
                            Button(
                              child: const Text('Yes, empty my cart'),
                              onPressed: Navigator.of(context).pop,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Text(controller.isOpen ? 'Displaying' : ''),
          ]),
        ),
        subtitle(content: const Text('MenuFlyout')),
        description(
          content: const Text(
            'Menu flyouts are used in menu and context menu scenarios to '
            'display a list of commands or options when requested by the user. '
            'A menu flyout shows a single, inline, top-level menu that can '
            'have menu items and sub-menus. To show a set of multiple top-level '
            'menus in a horizontal row, use menu bar (which you typically '
            'position at the top of the app window).',
          ),
        ),
        CardHighlight(
          codeSnippet: '''FlyoutAttach(
  controller: controller,
  child: Button(
    child: const Text('Clear cart'),
    onPressed: () {},
  )
)''',
          child: Row(children: [
            FlyoutAttach(
              key: menuAttachKey,
              controller: menuController,
              child: Button(
                child: const Text('Options'),
                onPressed: () async {
                  menuController.showFlyout(
                    autoModeConfiguration: FlyoutAutoConfiguration(
                      preferredMode: placementMode,
                    ),
                    barrierDismissible: barrierDismissible,
                    dismissOnPointerMoveAway: dismissOnPointerMoveAway,
                    dismissWithEsc: dismissWithEsc,
                    builder: (context) {
                      return MenuFlyout(
                        items: [
                          MenuFlyoutItem(
                            leading: const Icon(FluentIcons.share),
                            text: const Text('Share'),
                            onPressed: () {},
                          ),
                          MenuFlyoutItem(
                            leading: const Icon(FluentIcons.copy),
                            text: const Text('Copy'),
                            onPressed: () {},
                          ),
                          MenuFlyoutItem(
                            leading: const Icon(FluentIcons.delete),
                            text: const Text('Delete'),
                            onPressed: () {},
                          ),
                          const MenuFlyoutSeparator(),
                          MenuFlyoutItem(
                            text: const Text('Rename'),
                            onPressed: () {},
                          ),
                          MenuFlyoutItem(
                            text: const Text('Select'),
                            onPressed: () {},
                          ),
                          const MenuFlyoutSeparator(),
                          MenuFlyoutSubItem(
                            text: const Text('Send to'),
                            items: [
                              MenuFlyoutItem(
                                text: const Text('Bluetooth'),
                                onPressed: () {},
                              ),
                              MenuFlyoutItem(
                                text: const Text('Desktop (shortcut)'),
                                onPressed: () {},
                              ),
                              MenuFlyoutSubItem(
                                text: const Text('Compressed file'),
                                items: [
                                  MenuFlyoutItem(
                                    text: const Text('Compress and email'),
                                    onPressed: () {},
                                  ),
                                  MenuFlyoutItem(
                                    text: const Text('Compress to .7z'),
                                    onPressed: () {},
                                  ),
                                  MenuFlyoutItem(
                                    text: const Text('Compress to .zip'),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Text(menuController.isOpen ? 'Displaying' : ''),
          ]),
        ),
      ],
    );
  }
}
