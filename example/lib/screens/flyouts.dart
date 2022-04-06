import 'package:fluent_ui/fluent_ui.dart';

class FlyoutShowcase extends StatefulWidget {
  const FlyoutShowcase({Key? key}) : super(key: key);

  @override
  State<FlyoutShowcase> createState() => _FlyoutShowcaseState();
}

class _FlyoutShowcaseState extends State<FlyoutShowcase> {
  Typography get typography => FluentTheme.of(context).typography;

  FlyoutController flyoutController = FlyoutController();

  @override
  void dispose() {
    flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Flyouts')),
      children: [
        Wrap(spacing: 12.0, runSpacing: 12.0, children: [
          _flyoutOnHover(),
          _flyoutOnPress(),
          _flyoutOnLongPress(),
          _flyoutWithController(),
        ]),
        Wrap(spacing: 12.0, runSpacing: 12.0, children: [
          _flyoutAtStart(),
          _flyoutAtCenter(),
          _flyoutAtEnd(),
          _flyoutAtCustomPosition(),
        ]),
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
          openMode: FlyoutOpenMode.hover,
          placement: FlyoutPlacement.start,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown at the start of the child'),
            );
          },
          child: Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text('Hover to show a flyout at start'),
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
          openMode: FlyoutOpenMode.hover,
          placement: FlyoutPlacement.center,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown at the center of the child'),
            );
          },
          child: Container(
            color: Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text('Hover to show a flyout at center'),
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
          openMode: FlyoutOpenMode.hover,
          placement: FlyoutPlacement.end,
          content: (context) {
            return const FlyoutContent(
              child: Text('This is a flyout shown at the end of the child'),
            );
          },
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text('Hover to show a flyout at end'),
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
          openMode: FlyoutOpenMode.hover,
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
              'Hover to show a flyout at custom position',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    ]);
  }
}
