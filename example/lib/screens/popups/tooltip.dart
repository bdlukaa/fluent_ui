import 'dart:math';

import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TooltipPage extends StatelessWidget with PageMixin {
  TooltipPage({super.key});

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Tooltip')),
      children: [
        const Text(
          'A ToolTip shows more information about a UI element. You might show information about what the element does, or what the user should do. The ToolTip is shown when a user hovers over or presses and holds the UI element.',
        ),
        subtitle(content: const Text('Button with a simple tooltip')),
        CodeSnippetCard(
          codeSnippet: '''
Tooltip(
  message: 'Simple ToolTip',
  child: Button(
    child: const Text('Button with a simple tooltip'),
    onPressed: () {},
  ),
),''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tooltip(
              message: 'Simple ToolTip',
              child: Button(
                child: const Text('Button with a simple tooltip'),
                onPressed: () {},
              ),
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'Button with an horizontal tooltip at the left without mouse position',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''
Tooltip(
  message: 'Horizontal ToolTip',
  displayHorizontally: true,
  useMousePosition: false,
  style: const TooltipThemeData(preferBelow: true),
  child: IconButton(
    icon: const WindowsIcon(WindowsIcons.graph_symbol, size: 24.0),
    onPressed: () {},
  ),
),''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tooltip(
              message: 'Horizontal ToolTip',
              displayHorizontally: true,
              useMousePosition: false,
              style: const TooltipThemeData(preferBelow: true),
              child: IconButton(
                icon: const WindowsIcon(
                  WindowsIcons.app_icon_default,
                  size: 24,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ),
        subtitle(content: const Text('Multiple tooltips next to each other')),
        const Text('This usually happen on a CommandBar inside an app bar.'),
        CodeSnippetCard(
          codeSnippet: '''
Tooltip(
  message: 'Horizontal ToolTip',
  displayHorizontally: true,
  useMousePosition: false,
  style: const TooltipThemeData(preferBelow: true),
  child: IconButton(
    icon: const WindowsIcon(WindowsIcons.graph_symbol, size: 24.0),
    onPressed: () {},
  ),
),''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: List.generate(4, (final index) {
                final icons = WindowsIcons.allIcons.values;
                return Tooltip(
                  message: 'Message',
                  useMousePosition: false,
                  style: const TooltipThemeData(
                    preferBelow: true,
                    waitDuration: Duration.zero,
                  ),
                  child: IconButton(
                    icon: Icon(
                      icons.elementAt(Random().nextInt(icons.length)),
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                );
              }),
            ),
          ),
        ),
        subtitle(content: const Text('Extra long tooltip content that wraps')),
        CodeSnippetCard(
          codeSnippet: '''
Tooltip(
  message:
      List.generate(25, (_) => 'This is a really long tooltip! ')
          .join(" "),
  useMousePosition: false,
  style: const TooltipThemeData(
    maxWidth: 500,
    preferBelow: true,
    waitDuration: Duration.zero,
  ),
  child: IconButton(
    icon: const WindowsIcon(WindowsIcons.text_overflow, size: 24.0),
    onPressed: () {},
  ),
),''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tooltip(
              message: List.generate(
                25,
                (_) => 'This is a really long tooltip! ',
              ).join(' '),
              useMousePosition: false,
              style: const TooltipThemeData(
                maxWidth: 500,
                preferBelow: true,
                waitDuration: Duration.zero,
              ),
              child: IconButton(
                icon: const WindowsIcon(
                  WindowsIcons.app_icon_default,
                  size: 24,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}
