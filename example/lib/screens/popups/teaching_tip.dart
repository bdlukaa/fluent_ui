import 'package:example/theme.dart';
import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class TeachingTipPage extends StatefulWidget {
  const TeachingTipPage({Key? key}) : super(key: key);

  @override
  State<TeachingTipPage> createState() => _TeachingTipPageState();
}

class _TeachingTipPageState extends State<TeachingTipPage> with PageMixin {
  final nonTargetedController = FlyoutController();
  final targetedController = FlyoutController();

  static const alignments = {
    'Bottom left': Alignment.bottomLeft,
    'Bottom center': Alignment.bottomCenter,
    'Bottom right': Alignment.bottomRight,
    'Center': Alignment.center,
    'Top left': Alignment.topLeft,
    'Top center': Alignment.topCenter,
    'Top right': Alignment.topRight,
  };
  static const placements = {
    'Top left': FlyoutPlacementMode.topLeft,
    'Top center': FlyoutPlacementMode.topCenter,
    'Top right': FlyoutPlacementMode.topRight,
    'Bottom left': FlyoutPlacementMode.bottomLeft,
    'Bottom center': FlyoutPlacementMode.bottomCenter,
    'Bottom right': FlyoutPlacementMode.bottomRight,
    'Right Top': FlyoutPlacementMode.rightTop,
    'Right Center': FlyoutPlacementMode.rightCenter,
    'Right Bottom': FlyoutPlacementMode.rightBottom,
    'Left Top': FlyoutPlacementMode.leftTop,
    'Left Center': FlyoutPlacementMode.leftCenter,
    'Left Bottom': FlyoutPlacementMode.leftBottom,
  };
  var alignment = 'Bottom center';
  var placement = 'Top center';
  var showMediaContent = false;

  @override
  void dispose() {
    nonTargetedController.dispose();
    targetedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final appTheme = context.watch<AppTheme>();

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Teaching Tip')),
      children: [
        description(
          content: const Text(
            'A teaching tip is a semi-persistent and content-rich flyout '
            'that provides contextual information. It is often used for '
            'informing, reminding, and teaching users about important and new '
            'features that may enhance their experience.',
          ),
        ),
        subtitle(
          content: const Text('Show a non-targeted TeachingTip with buttons.'),
        ),
        CardHighlight(
          codeSnippet: '''final flyoutController = FlyoutController();

FlyoutTarget(
  controller: flyoutController,
  child: Button(
    child: const Text('Show TeachingTip'),
    onPressed: () {
      
    },
  ),
);

showTeachingTip(
  flyoutController: flyoutController,
  nonTargetedAlignment: ${alignments[alignment]},
  builder: (context) {
    return TeachingTip(
      title: const Text('Change themes without hassle'),
      subtitle: const Text(
        'It's easier to see control samples in both light and dark theme',
      ),
      buttons: [
        Button(
          child: const Text('Toggle theme now'),
          onPressed: () {
            if (theme.brightness.isDark) {
              appTheme.mode = ThemeMode.light;
            } else {
              appTheme.mode = ThemeMode.dark;
            }
            flyoutController.close();
          },
        ),
        Button(
          onPressed: () => flyoutController.close(),
          child: const Text('Got it'),
        ),
      ],
    );
  },
);
''',
          child: Row(children: [
            FlyoutTarget(
              controller: nonTargetedController,
              child: Button(
                child: const Text('Show TeachingTip'),
                onPressed: () {
                  showTeachingTip(
                    flyoutController: nonTargetedController,
                    nonTargetedAlignment: alignments[alignment],
                    builder: (context) => TeachingTip(
                      title: const Text('Change themes without hassle'),
                      subtitle: const Text(
                        'It\'s easier to see control samples in both light and dark theme',
                      ),
                      buttons: [
                        Button(
                          child: const Text('Toggle theme now'),
                          onPressed: () {
                            if (theme.brightness.isDark) {
                              appTheme.mode = ThemeMode.light;
                            } else {
                              appTheme.mode = ThemeMode.dark;
                            }
                            nonTargetedController.close();
                          },
                        ),
                        Button(
                          onPressed: () => nonTargetedController.close(),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 18.0),
            SizedBox(
              width: 150.0,
              child: ComboBox<String>(
                placeholder: const Text('Alignment'),
                items: List.generate(alignments.length, (index) {
                  final entry = alignments.entries.elementAt(index);

                  return ComboBoxItem(
                    value: entry.key,
                    child: Text(entry.key.uppercaseFirst()),
                  );
                }),
                value: alignment,
                onChanged: (a) {
                  if (a != null) setState(() => alignment = a);
                },
              ),
            ),
          ]),
        ),
        subtitle(
          content: const Text('Show a targeted TeachingTip.'),
        ),
        CardHighlight(
          codeSnippet: '''final flyoutController = FlyoutController();

final target = FlyoutTarget(
  controller: flyoutController,
  child: Container(
    height: 100,
    width: 200,
    color: theme.accentColor.defaultBrushFor(theme.brightness),
  ),
);

showTeachingTip(
  flyoutController: flyoutController,
  placementMode: ${placements[placement]},
  builder: (context) {
    return TeachingTip(
      leading: const Icon(FluentIcons.refresh),
      title: const Text('This is the title'),
      subtitle: const Text('And this is the subtitle'),${showMediaContent ? '''\n      mediaContent: SizedBox(
        width: double.infinity,
        child: ColoredBox(
          color: Colors.blue.defaultBrushFor(theme.brightness),
          child: const FlutterLogo(size: 100),
        ),
      )''' : ''}
    );
  },
);
''',
          child: Row(children: [
            Expanded(
              child: Center(
                child: FlyoutTarget(
                  controller: targetedController,
                  child: Container(
                    height: 100,
                    width: 200,
                    color: theme.accentColor.defaultBrushFor(theme.brightness),
                  ),
                ),
              ),
            ),
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8.0,
                children: [
                  InfoLabel(
                    label: 'Placement',
                    child: ComboBox<String>(
                      placeholder: const Text('Placement'),
                      items: List.generate(placements.length, (index) {
                        final entry = placements.entries.elementAt(index);

                        return ComboBoxItem(
                          value: entry.key,
                          child: Text(entry.key.uppercaseFirst()),
                        );
                      }),
                      value: placement,
                      onChanged: (a) {
                        if (a != null) setState(() => placement = a);
                      },
                      isExpanded: true,
                    ),
                  ),
                  Checkbox(
                    checked: showMediaContent,
                    onChanged: (v) {
                      if (v != null) setState(() => showMediaContent = v);
                    },
                    content: const Text('Show media content'),
                  ),
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      child: const Text('Show TeachingTip'),
                      onPressed: () {
                        showTeachingTip(
                          flyoutController: targetedController,
                          placementMode: placements[placement]!,
                          builder: (context) {
                            return TeachingTip(
                              leading: const Icon(FluentIcons.refresh),
                              title: const Text('This is the title'),
                              subtitle: const Text('And this is the subtitle'),
                              mediaContent: showMediaContent
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: ColoredBox(
                                        color: Colors.blue
                                            .defaultBrushFor(theme.brightness),
                                        child: const FlutterLogo(size: 100),
                                      ),
                                    )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
