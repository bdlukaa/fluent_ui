import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FlyoutController;
import 'package:fluent_ui/src/controls/flyouts/flyout.dart';

class Flyout2Screen extends StatefulWidget {
  const Flyout2Screen({Key? key}) : super(key: key);

  @override
  State<Flyout2Screen> createState() => _Flyout2ScreenState();
}

class _Flyout2ScreenState extends State<Flyout2Screen> with PageMixin {
  final controller = FlyoutController();

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
      header: const PageHeader(title: Text('Flyouts v2')),
      children: [
        description(
          content: const Text(
            'A flyout is a light dismiss container that can show arbitrary UI as '
            'its content. Flyouts can contain other flyouts or context menus to '
            'create a nested experience.',
          ),
        ),
        subtitle(content: const Text('A button with a flyout')),
        Row(children: [
          FlyoutAttach(
            controller: controller,
            child: Button(
              child: const Text('Clear cart'),
              onPressed: () {
                controller.showFlyout(
                  placementMode: FlyoutPlacementMode.topLeft,
                  builder: (context) {
                    return MenuFlyout(
                      items: [
                        MenuFlyoutSubItem(
                          text: const Text('New'),
                          items: [
                            MenuFlyoutItem(
                              text: const Text('Plain Text Document'),
                              onPressed: () {},
                            ),
                            MenuFlyoutItem(
                              text: const Text('Rich Text Document'),
                              onPressed: () {},
                            ),
                            MenuFlyoutItem(
                              text: const Text('Other formats...'),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        MenuFlyoutItem(
                          text: const Text('Open'),
                          onPressed: () {},
                        ),
                        MenuFlyoutItem(
                          text: const Text('Save'),
                          onPressed: () {},
                        ),
                        const MenuFlyoutSeparator(),
                        MenuFlyoutItem(
                          text: const Text('Exit'),
                          onPressed: () {},
                        ),
                      ],
                    );
                    // return FlyoutContent(
                    //   child: Column(
                    //     mainAxisSize: MainAxisSize.min,
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(
                    //         'All items will be removed. Do you want to continue?',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //       const SizedBox(height: 12.0),
                    //       Button(
                    //         child: const Text('Yes, empty my cart'),
                    //         onPressed: Navigator.of(context).pop,
                    //       ),
                    //     ],
                    //   ),
                    // );
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8.0),
          Text(controller.isOpen ? 'Displaying' : ''),
        ]),
      ],
    );
  }
}
