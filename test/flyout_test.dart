import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  group('FlyoutListTile', () {
    testWidgets('is displayed correctly', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const FlyoutListTile(
            text: Text('Copy'),
          ),
        ),
      );

      expect(find.byType(FlyoutListTile), findsOneWidget);
    });

    testWidgets('is rendered via controller', (tester) async {
      final controller = FlyoutController();

      await tester.pumpWidget(
        wrapApp(
          child: FlyoutTarget(
            controller: controller,
            child: Button(
              child: const Text('Clear cart'),
              onPressed: () {
                controller.showFlyout(
                  autoModeConfiguration: FlyoutAutoConfiguration(
                    preferredMode: FlyoutPlacementMode.topCenter,
                  ),
                  barrierDismissible: true,
                  dismissOnPointerMoveAway: false,
                  dismissWithEsc: true,
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
        ),
      );

      // Before tapping button FlyoutContent is not shown
      expect(find.byType(FlyoutContent), findsNothing);

      await tester.tap(find.byType(Button));
      await tester.pumpAndSettle();

      // After tapping button FlyoutContent is displayed
      expect(find.byType(FlyoutContent), findsOneWidget);
    });
  });
}
