import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class CardHighlight extends StatefulWidget {
  const CardHighlight({
    Key? key,
    this.backgroundColor,
    required this.child,
    required this.codeSnippet,
  }) : super(key: key);

  final Widget child;
  final String codeSnippet;

  final Color? backgroundColor;

  @override
  State<CardHighlight> createState() => _CardHighlightState();
}

class _CardHighlightState extends State<CardHighlight>
    with AutomaticKeepAliveClientMixin<CardHighlight> {
  bool isOpen = false;
  bool isCopying = false;

  final GlobalKey expanderKey = GlobalKey<ExpanderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = FluentTheme.of(context);

    return Column(children: [
      Card(
        backgroundColor: widget.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
        child: SizedBox(
          width: double.infinity,
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: widget.child,
          ),
        ),
      ),
      Expander(
        key: expanderKey,
        headerShape: (open) => const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        onStateChanged: (state) {
          // this is done because [onStateChanges] is called while the [Expander]
          // is updating. By using this, we schedule the rebuilt of this widget
          // to the next frame
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (mounted) setState(() => isOpen = state);
          });
        },
        trailing: isOpen
            ? Container(
                height: 31,
                constraints: const BoxConstraints(minWidth: 75),
                child: Button(
                  style: ButtonStyle(
                    backgroundColor: isCopying
                        ? ButtonState.all(
                            theme.accentColor.defaultBrushFor(theme.brightness),
                          )
                        : null,
                  ),
                  child: isCopying
                      ? Icon(
                          FluentIcons.check_mark,
                          color: theme.resources.textOnAccentFillColorPrimary,
                          size: 18,
                        )
                      : Row(children: const [
                          Icon(FluentIcons.copy),
                          SizedBox(width: 6.0),
                          Text('Copy')
                        ]),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.codeSnippet));
                    setState(() => isCopying = true);
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      isCopying = false;
                      if (mounted) setState(() {});
                    });
                  },
                ),
              )
            : null,
        header: const Text('Source code'),
        content: SyntaxView(
          code: widget.codeSnippet,
          syntaxTheme: theme.brightness.isDark
              ? SyntaxTheme.vscodeDark()
              : SyntaxTheme.vscodeLight(),
        ),
      ),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
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
