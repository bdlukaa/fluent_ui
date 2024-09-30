import 'package:example/main.dart';
import 'package:example/theme.dart';
import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

class Flyout2Screen extends StatefulWidget {
  const Flyout2Screen({super.key});

  @override
  State<Flyout2Screen> createState() => _Flyout2ScreenState();
}

class _Flyout2ScreenState extends State<Flyout2Screen> with PageMixin {
  final controller = FlyoutController();
  final attachKey = GlobalKey();

  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  final itemsController = FlyoutController();
  final itemsAttachKey = GlobalKey();

  final contextController = FlyoutController();
  final contextAttachKey = GlobalKey();

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
    menuController.dispose();
    contextController.dispose();
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
          codeSnippet: '''FlyoutTarget(
  controller: controller,
  child: Button(
    child: const Text('Clear cart'),
    onPressed: () {
      controller.showFlyout(
        autoModeConfiguration: FlyoutAutoConfiguration(
          preferredMode: $placementMode,
        ),
        barrierDismissible: $barrierDismissible,
        dismissOnPointerMoveAway: $dismissOnPointerMoveAway,
        dismissWithEsc: $dismissWithEsc,
        navigatorKey: rootNavigatorKey.currentState,
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
                  onPressed: Flyout.of(context).close,
                  child: const Text('Yes, empty my cart'),
                ),
              ],
            ),
          );
        },
      );
    },
  )
)''',
          child: Row(children: [
            FlyoutTarget(
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
                    navigatorKey: rootNavigatorKey.currentState,
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
                              onPressed: Flyout.of(context).close,
                              child: const Text('Yes, empty my cart'),
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
          codeSnippet: '''final menuController = FlyoutController();

FlyoutTarget(
  controller: menuController,
  child: Button(
    child: const Text('Options'),
    onPressed: () {
      menuController.showFlyout(
        autoModeConfiguration: FlyoutAutoConfiguration(
          preferredMode: $placementMode,
        ),
        barrierDismissible: $barrierDismissible,
        dismissOnPointerMoveAway: $dismissOnPointerMoveAway,
        dismissWithEsc: $dismissWithEsc,
        navigatorKey: rootNavigatorKey.currentState,
        builder: (context) {
          return MenuFlyout(items: [
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.share),
              text: const Text('Share'),
              onPressed: Flyout.of(context).close,
            ),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.copy),
              text: const Text('Copy'),
              onPressed: Flyout.of(context).close,
            ),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.delete),
              text: const Text('Delete'),
              onPressed: Flyout.of(context).close,
            ),
            const MenuFlyoutSeparator(),
            MenuFlyoutItem(
              text: const Text('Rename'),
              onPressed: Flyout.of(context).close,
            ),
            MenuFlyoutItem(
              text: const Text('Select'),
              onPressed: Flyout.of(context).close,
            ),
            const MenuFlyoutSeparator(),
            MenuFlyoutSubItem(
              text: const Text('Send to'),
              items: (_) => [
                MenuFlyoutItem(
                  text: const Text('Bluetooth'),
                  onPressed: Flyout.of(context).close,
                ),
                MenuFlyoutItem(
                  text: const Text('Desktop (shortcut)'),
                  onPressed: Flyout.of(context).close,
                ),
                MenuFlyoutSubItem(
                  text: const Text('Compressed file'),
                  items: (context) => [
                    MenuFlyoutItem(
                      text: const Text('Compress and email'),
                      onPressed: Flyout.of(context).close,
                    ),
                    MenuFlyoutItem(
                      text: const Text('Compress to .7z'),
                      onPressed: Flyout.of(context).close,
                    ),
                    MenuFlyoutItem(
                      text: const Text('Compress to .zip'),
                      onPressed: Flyout.of(context).close,
                    ),
                  ],
                ),
              ],
            ),
          ]);
        },
      );
    },
  )
)''',
          child: Row(children: [
            FlyoutTarget(
              key: menuAttachKey,
              controller: menuController,
              child: Button(
                child: const Text('Options'),
                onPressed: () {
                  menuController.showFlyout(
                    autoModeConfiguration: FlyoutAutoConfiguration(
                      preferredMode: placementMode,
                    ),
                    barrierDismissible: barrierDismissible,
                    dismissOnPointerMoveAway: dismissOnPointerMoveAway,
                    dismissWithEsc: dismissWithEsc,
                    navigatorKey: rootNavigatorKey.currentState,
                    builder: (context) {
                      return MenuFlyout(items: [
                        MenuFlyoutItem(
                          leading: const Icon(FluentIcons.share),
                          text: const Text('Share'),
                          onPressed: Flyout.of(context).close,
                        ),
                        MenuFlyoutItem(
                          leading: const Icon(FluentIcons.copy),
                          text: const Text('Copy'),
                          onPressed: Flyout.of(context).close,
                        ),
                        MenuFlyoutItem(
                          leading: const Icon(FluentIcons.delete),
                          text: const Text('Delete'),
                          onPressed: Flyout.of(context).close,
                        ),
                        const MenuFlyoutSeparator(),
                        MenuFlyoutItem(
                          text: const Text('Rename'),
                          onPressed: Flyout.of(context).close,
                        ),
                        MenuFlyoutItem(
                          text: const Text('Select'),
                          onPressed: null,
                        ),
                        const MenuFlyoutSeparator(),
                        MenuFlyoutSubItem(
                          text: const Text('Send to'),
                          items: (_) => [
                            MenuFlyoutItem(
                              text: const Text('Bluetooth'),
                              onPressed: Flyout.of(context).close,
                            ),
                            MenuFlyoutItem(
                              text: const Text('Desktop (shortcut)'),
                              onPressed: Flyout.of(context).close,
                            ),
                            MenuFlyoutSubItem(
                              text: const Text('Compressed file'),
                              items: (context) => [
                                MenuFlyoutItem(
                                  text: const Text('Compress and email'),
                                  onPressed: Flyout.of(context).close,
                                ),
                                MenuFlyoutItem(
                                  text: const Text('Compress to .7z'),
                                  onPressed: Flyout.of(context).close,
                                ),
                                MenuFlyoutItem(
                                  text: const Text('Compress to .zip'),
                                  onPressed: Flyout.of(context).close,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Text(menuController.isOpen ? 'Displaying' : ''),
          ]),
        ),
        subtitle(content: const Text('Other Flyout Item Types')),
        description(
          content: const Text(
            'The flyout can contain other flyout items like separators, '
            'toggle and radio items.',
          ),
        ),
        CardHighlight(
          codeSnippet: '''final itemsController = FlyoutController();
final itemsAttachKey = GlobalKey();

FlyoutTarget(
  controller: itemsController,
  child: Button(
    child: const Text('Show options'),
    onPressed: () {
      itemsController.showFlyout(
        autoModeConfiguration: FlyoutAutoConfiguration(
          preferredMode: $placementMode,
        ),
        barrierDismissible: $barrierDismissible,
        dismissOnPointerMoveAway: $dismissOnPointerMoveAway,
        dismissWithEsc: $dismissWithEsc,
        navigatorKey: rootNavigatorKey.currentState,
        builder: (context) {
          var repeat = true;
          var shuffle = false;

          var radioIndex = 1;
          return StatefulBuilder(builder: (context, setState) {
            return MenuFlyout(items: [
              MenuFlyoutItem(
                text: const Text('Reset'),
                onPressed: () {
                  setState(() {
                    repeat = false;
                    shuffle = false;
                  });
                },
              ),
              const MenuFlyoutSeparator(),
              ToggleMenuFlyoutItem(
                text: const Text('Repeat'),
                value: repeat,
                onChanged: (v) {
                  setState(() => repeat = v);
                },
              ),
              ToggleMenuFlyoutItem(
                text: const Text('Shuffle'),
                value: shuffle,
                onChanged: (v) {
                  setState(() => shuffle = v);
                },
              ),
              const MenuFlyoutSeparator(),
              ...List.generate(3, (index) {
                return RadioMenuFlyoutItem(
                  text: Text([
                    'Small icons',
                    'Medium icons',
                    'Large icons',
                  ][index]),
                  value: index,
                  groupValue: radioIndex,
                  onChanged: (v) {
                    setState(() => radioIndex = index);
                  },
                );
              }),
            ]);
          });
        },
      );
    },
  )
)
''',
          child: Row(children: [
            FlyoutTarget(
              key: itemsAttachKey,
              controller: itemsController,
              child: Button(
                child: const Text('Show options'),
                onPressed: () {
                  itemsController.showFlyout(
                    autoModeConfiguration: FlyoutAutoConfiguration(
                      preferredMode: placementMode,
                    ),
                    barrierDismissible: barrierDismissible,
                    dismissOnPointerMoveAway: dismissOnPointerMoveAway,
                    dismissWithEsc: dismissWithEsc,
                    navigatorKey: rootNavigatorKey.currentState,
                    builder: (context) {
                      var repeat = true;
                      var shuffle = false;

                      var radioIndex = 1;
                      return StatefulBuilder(builder: (context, setState) {
                        return MenuFlyout(items: [
                          MenuFlyoutItem(
                            text: const Text('Reset'),
                            onPressed: () {
                              setState(() {
                                repeat = false;
                                shuffle = false;
                              });
                            },
                          ),
                          const MenuFlyoutSeparator(),
                          ToggleMenuFlyoutItem(
                            text: const Text('Repeat'),
                            value: repeat,
                            onChanged: (v) {
                              setState(() => repeat = v);
                            },
                          ),
                          ToggleMenuFlyoutItem(
                            text: const Text('Shuffle'),
                            value: shuffle,
                            onChanged: (v) {
                              setState(() => shuffle = v);
                            },
                          ),
                          const MenuFlyoutSeparator(),
                          ...List.generate(3, (index) {
                            return RadioMenuFlyoutItem(
                              text: Text([
                                'Small icons',
                                'Medium icons',
                                'Large icons',
                              ][index]),
                              value: index,
                              groupValue: radioIndex,
                              onChanged: (v) {
                                setState(() => radioIndex = index);
                              },
                            );
                          }),
                        ]);
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Text(menuController.isOpen ? 'Displaying' : ''),
          ]),
        ),
        subtitle(content: const Text('Context Menus')),
        description(
          content: const Text(
            'The command bar flyout lets you provide users with easy access '
            'to common tasks by showing commands in a floating toolbar related '
            'to an element on your UI canvas. Use your right mouse button to '
            'open the context menu.',
          ),
        ),
        CardHighlight(
          codeSnippet: '''final contextController = FlyoutController();
final contextAttachKey = GlobalKey();

return GestureDetector(
  onSecondaryTapUp: (d) {

    // This calculates the position of the flyout according to the parent navigator
    final targetContext = contextAttachKey.currentContext;
    if (targetContext == null) return;
    final box = targetContext.findRenderObject() as RenderBox;
    final position = box.localToGlobal(
      d.localPosition,
      ancestor: Navigator.of(context).context.findRenderObject(),
    );

    contextController.showFlyout(
      barrierColor: Colors.black.withOpacity(0.1),
      position: position,
      builder: (context) {
        return FlyoutContent(
          child: SizedBox(
            width: 130.0,
            child: CommandBar(
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.add_favorite),
                  label: const Text('Favorite'),
                  onPressed: () {},
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.copy),
                  label: const Text('Copy'),
                  onPressed: () {},
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.share),
                  label: const Text('Share'),
                  onPressed: () {},
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.save),
                  label: const Text('Save'),
                  onPressed: () {},
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.delete),
                  label: const Text('Delete'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  },
  child: FlyoutTarget(
    key: contextAttachKey,
    controller: contextController,
    child: const FlutterLogo(size: 400.0),
  ),
);
''',
          child: GestureDetector(
            onSecondaryTapUp: (d) {
              final targetContext = contextAttachKey.currentContext;
              if (targetContext == null) return;

              final box = targetContext.findRenderObject() as RenderBox;
              final position = box.localToGlobal(
                d.localPosition,
                ancestor: Navigator.of(context).context.findRenderObject(),
              );

              void showFlyout(Offset position) {
                contextController.showFlyout(
                  barrierColor: Colors.black.withOpacity(0.1),
                  position: position,
                  barrierRecognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).pop();
                    }
                    ..onSecondaryTapUp = (d) {
                      Navigator.of(context).pop();

                      final box = Navigator.of(context)
                          .context
                          .findRenderObject() as RenderBox;
                      final position = box.localToGlobal(
                        d.localPosition,
                        ancestor: box,
                      );

                      showFlyout(position);
                    },
                  builder: (context) {
                    return FlyoutContent(
                      child: SizedBox(
                        width: 130,
                        child: CommandBar(
                          isCompact: true,
                          primaryItems: [
                            CommandBarButton(
                              icon: const Icon(FluentIcons.add_favorite),
                              label: const Text('Favorite'),
                              onPressed: () {},
                            ),
                            CommandBarButton(
                              icon: const Icon(FluentIcons.copy),
                              label: const Text('Copy'),
                              onPressed: () {},
                            ),
                            CommandBarButton(
                              icon: const Icon(FluentIcons.share),
                              label: const Text('Share'),
                              onPressed: () {},
                            ),
                            CommandBarButton(
                              icon: const Icon(FluentIcons.save),
                              label: const Text('Save'),
                              onPressed: () {},
                            ),
                            CommandBarButton(
                              icon: const Icon(FluentIcons.delete),
                              label: const Text('Delete'),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              showFlyout(position);
            },
            child: FlyoutTarget(
              key: contextAttachKey,
              controller: contextController,
              child: ShaderMask(
                shaderCallback: (rect) {
                  final color = context.read<AppTheme>().color.defaultBrushFor(
                        FluentTheme.of(context).brightness,
                      );
                  return LinearGradient(
                    colors: [
                      color,
                      color,
                    ],
                  ).createShader(rect);
                },
                child: const FlutterLogo(
                  size: 400.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
