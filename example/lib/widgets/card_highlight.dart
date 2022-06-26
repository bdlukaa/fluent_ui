import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';

class CardHighlight extends StatefulWidget {
  const CardHighlight({
    Key? key,
    required this.child,
    required this.codeSnippet,
  }) : super(key: key);

  final Widget child;
  final String codeSnippet;

  @override
  State<CardHighlight> createState() => _CardHighlightState();
}

class _CardHighlightState extends State<CardHighlight> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Column(children: [
      Card(
        child: widget.child,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
      ),
      Expander(
        key: PageStorageKey(widget.codeSnippet.hashCode),
        headerShape: (open) => const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        header: const Text('Source code'),
        content: HighlightView(
          widget.codeSnippet,
          language: 'dart',
          theme: theme.brightness.isDark ? fluentHighlightTheme : githubTheme,
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14.0,
            wordSpacing: 1.0,
          ),
        ),
      ),
    ]);
  }
}

const fluentHighlightTheme = {
  'root': TextStyle(
    backgroundColor: Color(0x00ffffff),
    color: Color(0xffdddddd),
  ),
  'keyword': TextStyle(
      color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
  'selector-tag':
      TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold),
  'literal': TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold),
  'section': TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold),
  'link': TextStyle(color: Color(0xffffffff)),
  'subst': TextStyle(color: Color(0xffdddddd)),
  'string': TextStyle(color: Color(0xffdd8888)),
  'title': TextStyle(color: Color(0xffdd8888), fontWeight: FontWeight.bold),
  'name': TextStyle(color: Color(0xffdd8888), fontWeight: FontWeight.bold),
  'type': TextStyle(color: Color(0xffdd8888), fontWeight: FontWeight.bold),
  'attribute': TextStyle(color: Color(0xffdd8888)),
  'symbol': TextStyle(color: Color(0xffdd8888)),
  'bullet': TextStyle(color: Color(0xffdd8888)),
  'built_in': TextStyle(color: Color(0xffdd8888)),
  'addition': TextStyle(color: Color(0xffdd8888)),
  'variable': TextStyle(color: Color(0xffdd8888)),
  'template-tag': TextStyle(color: Color(0xffdd8888)),
  'template-variable': TextStyle(color: Color(0xffdd8888)),
  'comment': TextStyle(color: Color(0xff777777)),
  'quote': TextStyle(color: Color(0xff777777)),
  'deletion': TextStyle(color: Color(0xff777777)),
  'meta': TextStyle(color: Color(0xff777777)),
  'doctag': TextStyle(fontWeight: FontWeight.bold),
  'strong': TextStyle(fontWeight: FontWeight.bold),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
};
