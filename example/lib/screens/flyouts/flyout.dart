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
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Flyouts v2')),
      children: [
        subtitle(content: const Text('Flyouts')),
        Align(
          alignment: Alignment.centerRight,
          child: FlyoutAttach(
            controller: controller,
            child: Button(
              child: const Text('Open Flyout'),
              onPressed: () {
                controller.showFlyout(
                  placementMode: FlyoutPlacementMode.topRight,
                  builder: (context) {
                    return const FlyoutContent(
                      child: Text(
                        'This is a good FLYOUT content'
                        '\nWITH MULTIPLE LINES'
                        '\nAND VERY LONG LINES AHSBABASSABNAPSNPANPASNPA SABPASNSAPNASP',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
