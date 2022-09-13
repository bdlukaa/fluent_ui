import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TooltipPage extends ScrollablePage {
  TooltipPage({super.key});

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('Tooltip'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'A ToolTip shows more information about a UI element. You might show information about what the element does, or what the user should do. The ToolTip is shown when a user hovers over or presses and holds the UI element.',
      ),
      subtitle(content: const Text('Button with a simple tooltip')),
      CardHighlight(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: 'Simple ToolTip',
            child: Button(
              child: const Text('Button with a simple tooltip'),
              onPressed: () {},
            ),
          ),
        ),
        codeSnippet: '''Tooltip(
  message: 'Simple ToolTip',
  child: Button(
    child: const Text('Button with a simple tooltip'),
    onPressed: () {},
  ),
),''',
      ),
      subtitle(
        content: const Text(
          'Button with an horizontal tooltip at the left without mouse position',
        ),
      ),
      CardHighlight(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: 'Horizontal ToolTip',
            displayHorizontally: true,
            useMousePosition: false,
            style: const TooltipThemeData(preferBelow: true),
            child: IconButton(
              icon: const Icon(FluentIcons.graph_symbol, size: 24.0),
              onPressed: () {},
            ),
          ),
        ),
        codeSnippet: '''Tooltip(
  message: 'Horizontal ToolTip',
  displayHorizontally: true,
  useMousePosition: false,
  style: const TooltipThemeData(preferBelow: true),
  child: IconButton(
    icon: const Icon(FluentIcons.graph_symbol, size: 24.0),
    onPressed: () {},
  ),
),''',
      ),
    ];
  }
}
