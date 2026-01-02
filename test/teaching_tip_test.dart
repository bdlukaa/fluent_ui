import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets(
    'TeachingTip displays and closes with title, subtitle, and mediaContent',
    (tester) async {
      final flyoutController = FlyoutController();

      await tester.pumpWidget(
        wrapApp(
          child: ScaffoldPage(
            content: FlyoutTarget(
              controller: flyoutController,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
                child: const Text('Test Target'),
              ),
            ),
          ),
        ),
      );

      showTeachingTip(
        flyoutController: flyoutController,
        placementMode: FlyoutPlacementMode.topCenter,
        builder: (context) {
          return const TeachingTip(
            leading: Icon(FluentIcons.refresh),
            title: Text('Test Title'),
            subtitle: Text('Test Subtitle'),
            mediaContent: Text('Test Media Content'),
          );
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.text('Test Media Content'), findsOneWidget);
      expect(find.byIcon(FluentIcons.refresh), findsOneWidget);
      await tester.tap(find.byIcon(FluentIcons.chrome_close));
      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsNothing);
      expect(find.text('Test Subtitle'), findsNothing);
      expect(find.text('Test Media Content'), findsNothing);
      expect(find.byIcon(FluentIcons.refresh), findsNothing);
    },
  );

  testWidgets('TeachingTip renders buttons', (tester) async {
    final flyoutController = FlyoutController();

    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: FlyoutTarget(
            controller: flyoutController,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
              child: const Text('Test Target'),
            ),
          ),
        ),
      ),
    );

    showTeachingTip(
      flyoutController: flyoutController,
      placementMode: FlyoutPlacementMode.topCenter,
      builder: (context) {
        return TeachingTip(
          title: const Text('Title'),
          subtitle: const Text('Subtitle'),
          buttons: [
            Button(child: const Text('Button1'), onPressed: () {}),
            Button(child: const Text('Button2'), onPressed: () {}),
          ],
        );
      },
    );

    await tester.pumpAndSettle();

    expect(find.text('Button1'), findsOneWidget);
    expect(find.text('Button2'), findsOneWidget);
  });

  testWidgets('TeachingTip close button calls onClose', (tester) async {
    var closed = false;
    final flyoutController = FlyoutController();
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: FlyoutTarget(
            controller: flyoutController,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
              child: const Text('Test Target'),
            ),
          ),
        ),
      ),
    );

    showTeachingTip(
      flyoutController: flyoutController,
      placementMode: FlyoutPlacementMode.topCenter,
      builder: (context) {
        return TeachingTip(
          title: const Text('Title'),
          subtitle: const Text('Subtitle'),
          onClose: (_) {
            closed = true;
          },
        );
      },
    );

    await tester.pumpAndSettle();

    final closeButton = find.byIcon(FluentIcons.chrome_close);
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });

  testWidgets('TeachingTip does not show close button if onClose is null', (
    tester,
  ) async {
    final flyoutController = FlyoutController();
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: FlyoutTarget(
            controller: flyoutController,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
              child: const Text('Test Target'),
            ),
          ),
        ),
      ),
    );

    showTeachingTip(
      flyoutController: flyoutController,
      placementMode: FlyoutPlacementMode.topCenter,
      builder: (context) {
        return const TeachingTip(
          title: Text('Title'),
          subtitle: Text('Subtitle'),
          onClose: null,
        );
      },
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(FluentIcons.chrome_close), findsNothing);
  });
}
