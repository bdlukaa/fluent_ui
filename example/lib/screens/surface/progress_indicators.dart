import 'dart:math';

import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/code_snippet_card.dart';

class ProgressRingPage extends StatefulWidget {
  const ProgressRingPage({super.key});

  @override
  State<ProgressRingPage> createState() => _ProgressRingPageState();
}

class _ProgressRingPageState extends State<ProgressRingPage> with PageMixin {
  int determinateValue = Random().nextInt(100);
  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Progress controls')),
      children: [
        description(
          content: const Text(
            'A progress control provides feedback to the user that a long-running '
            'operation is underway. It can mean that the user cannot interact with '
            'the app when the progress indicator is visible, and can also indicate '
            'how long the wait time might be, depending on the indicator used.',
          ),
        ),
        subtitle(content: const Text('Indeterminate Progress Indicators')),
        description(
          content: const Text(
            'The indeterminate state shows that an operation is underway and its '
            'completion time is unknown.',
          ),
        ),
        const CodeSnippetCard(
          codeSnippet: 'ProgressRing()',
          child: RepaintBoundary(child: Row(children: [ProgressRing()])),
        ),
        subtitle(content: const Text('Determinate Progress Indicators')),
        description(
          content: const Text(
            'The determinate state shows the percentage completed of a task. '
            'This should be used during an operation whose duration is known, but '
            "its progress should not block the user's interaction with the app.",
          ),
        ),
        CodeSnippetCard(
          codeSnippet: 'ProgressRing(value: $determinateValue)',
          child: Row(
            spacing: 20,
            children: [
              ProgressRing(value: determinateValue.toDouble()),
              Flexible(
                child: InfoLabel(
                  label: 'Progress',
                  child: NumberBox<int>(
                    value: determinateValue,
                    min: 0,
                    max: 100,
                    onChanged: (final v) =>
                        setState(() => determinateValue = v ?? 0),
                    mode: SpinButtonPlacementMode.inline,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}
