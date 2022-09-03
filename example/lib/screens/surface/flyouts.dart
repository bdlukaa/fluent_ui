import 'package:example/widgets/card_highlight.dart';
import 'package:fluent_ui/fluent_ui.dart';

class FlyoutPage extends StatefulWidget {
  const FlyoutPage({Key? key}) : super(key: key);

  @override
  State<FlyoutPage> createState() => _FlyoutShowcaseState();
}

class _FlyoutShowcaseState extends State<FlyoutPage> {
  Typography get typography => FluentTheme.of(context).typography;

  FlyoutController buttonController = FlyoutController();
  FlyoutController flyoutController = FlyoutController();

  @override
  void dispose() {
    buttonController.dispose();
    flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Flyouts')),
      children: [
        const Text(
          'A Flyout displays lightweight UI that is either information, or requires user interaction. Unlike a dialog, a Flyout can be light dismissed by clicking or tapping off of it. Use it to collect input from the user, show more details about an item, or ask the user to confirm an action.',
        ),
        Text('A button with a Flyout', style: typography.subtitle),
        const SizedBox(height: 10.0),
        CardHighlight(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Flyout(
              controller: buttonController,
              content: (context) {
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
                        onPressed: buttonController.close,
                      ),
                    ],
                  ),
                );
              },
              child: Button(
                child: const Text('Empty cart'),
                onPressed: buttonController.open,
              ),
            ),
          ),
          codeSnippet:
              '''// define the controller. It'll be responsible to open/close the flyout programatically
FlyoutController buttonController = FlyoutController();

Flyout(
  controller: buttonController,
  // [content] is the content of the flyout popup, opened when the user presses
  // the button
  content: (context) {
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
            onPressed: buttonController.close,
          ),
        ],
      ),
    );
  },
  child: Button(
    child: const Text('Empty cart'),
    onPressed: buttonController.open,
  )
)''',
        ),
        const SizedBox(height: 20.0),
        DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Wrap(spacing: 12.0, runSpacing: 12.0, children: [
            _flyoutOnHover(),
            _flyoutOnPress(),
            _flyoutOnLongPress(),
            _flyoutWithController(),
          ]),
        ),
        DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Wrap(spacing: 12.0, runSpacing: 12.0, children: [
            _flyoutAtStart(),
            _flyoutAtCenter(),
            _flyoutAtEnd(),
            _flyoutAtCustomPosition(),
          ]),
        ),
        const PageHeader(title: Text('Menu Flyouts'), padding: 0.0),
        const Text(
          'A MenuFlyout displays lightweight UI that is light dismissed by clicking or tapping off of it. Use it to let the user choose from a contextual list of simple commands or options.',
        ),
        DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Wrap(spacing: 12.0, runSpacing: 12.0, children: [
            _menuFlyout(),
            _menuFlyoutWithSubItem(),
          ]),
        ),
      ],
    );
  }

  Widget _flyoutOnHover() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Flyout on hover', style: typography.subtitle),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Flyout(
          openMode: FlyoutOpenMode.hover,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown on hover'),
            );
          },
          child: Container(
            color: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text('Hover to show flyout'),
          ),
        ),
      ),
    ]);
  }

  Widget _flyoutOnPress() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Flyout on click/press', style: typography.subtitle),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Flyout(
          openMode: FlyoutOpenMode.press,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown on press'),
            );
          },
          child: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text('Click/press to show flyout'),
          ),
        ),
      ),
    ]);
  }

  Widget _flyoutOnLongPress() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Flyout on long click/press', style: typography.subtitle),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Flyout(
          openMode: FlyoutOpenMode.longPress,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown on long press'),
            );
          },
          child: Container(
            color: Colors.magenta,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text('Long press/click to show flyout'),
          ),
        ),
      ),
    ]);
  }

  Widget _flyoutWithController() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Flyout with controller', style: typography.subtitle),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Flyout(
          controller: flyoutController,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown with the controller'),
            );
          },
          child: GestureDetector(
            onTap: flyoutController.open,
            child: Container(
              color: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: const Text('Click/press to show flyout'),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _flyoutAtStart() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Flyout displayed at start', style: typography.subtitle),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Flyout(
          openMode: FlyoutOpenMode.press,
          placement: FlyoutPlacement.start,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown at the start of the child'),
            );
          },
          child: Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text('Press to show a flyout at start'),
          ),
        ),
      ),
    ]);
  }

  Widget _flyoutAtCenter() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Flyout displayed at center', style: typography.subtitle),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Flyout(
          openMode: FlyoutOpenMode.press,
          placement: FlyoutPlacement.center,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown at the center of the child'),
            );
          },
          child: Container(
            color: Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text('Press to show a flyout at center'),
          ),
        ),
      ),
    ]);
  }

  Widget _flyoutAtEnd() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Flyout displayed at end', style: typography.subtitle),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Flyout(
          openMode: FlyoutOpenMode.press,
          placement: FlyoutPlacement.end,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown at the end of the child'),
            );
          },
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text('Press to show a flyout at end'),
          ),
        ),
      ),
    ]);
  }

  Widget _flyoutAtCustomPosition() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Flyout displayed at custom position', style: typography.subtitle),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Flyout(
          openMode: FlyoutOpenMode.press,
          placement: FlyoutPlacement.full,
          content: (context) {
            return const Align(
              alignment: AlignmentDirectional.topEnd,
              child: FlyoutContent(
                child: Text(
                  'This is a flyout shown at a custom position on the window',
                ),
              ),
            );
          },
          child: Container(
            color: Colors.yellow,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text(
              'Press to show a flyout at custom position',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _menuFlyout() {
    return Flyout(
      content: (context) {
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
          ],
        );
      },
      openMode: FlyoutOpenMode.press,
      child: Container(
        color: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: const Text('Click to show flyout'),
      ),
    );
  }

  Widget _menuFlyoutWithSubItem() {
    return Flyout(
      placement: FlyoutPlacement.end,
      content: (context) {
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
      },
      openMode: FlyoutOpenMode.press,
      child: Container(
        color: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: const Text('Click to show flyout with subitem'),
      ),
    );
  }
}
