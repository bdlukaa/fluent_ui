import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:google_fonts/google_fonts.dart';

class CardHighlight extends StatefulWidget {
  const CardHighlight({
    super.key,
    this.backgroundColor,
    this.header,
    required this.child,
    required this.codeSnippet,
    this.initiallyOpen = false,
  });

  final Widget? header;
  final Widget child;
  final String codeSnippet;

  final Color? backgroundColor;
  final bool initiallyOpen;

  @override
  State<CardHighlight> createState() => _CardHighlightState();
}

class _CardHighlightState extends State<CardHighlight>
    with AutomaticKeepAliveClientMixin<CardHighlight> {
  late var isOpen = widget.initiallyOpen;
  var isCopying = false;

  final GlobalKey expanderKey = GlobalKey<ExpanderState>(
    debugLabel: 'Card Expander Key',
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.resources.controlStrokeColorSecondary),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          children: [
            Mica(
              backgroundColor: widget.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: SizedBox(width: double.infinity, child: widget.child),
                ),
              ),
            ),
            Expander(
              initiallyExpanded: widget.initiallyOpen,
              key: expanderKey,
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
                              ? WidgetStatePropertyAll(
                                  theme.accentColor.defaultBrushFor(
                                    theme.brightness,
                                  ),
                                )
                              : null,
                        ),
                        child: isCopying
                            ? Icon(
                                FluentIcons.check_mark,
                                color: theme
                                    .resources
                                    .textOnAccentFillColorPrimary,
                                size: 18,
                              )
                            : const Row(
                                children: [
                                  WindowsIcon(WindowsIcons.copy),
                                  SizedBox(width: 6.0),
                                  Text('Copy'),
                                ],
                              ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.codeSnippet),
                          );
                          setState(() => isCopying = true);
                          Future.delayed(
                            const Duration(milliseconds: 1500),
                            () {
                              isCopying = false;
                              if (mounted) setState(() {});
                            },
                          );
                        },
                      ),
                    )
                  : null,
              header: widget.header ?? const Text('Source code'),
              headerShape: (open) {
                return const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.zero),
                );
              },
              content: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(6.0),
                ),
                child: SyntaxView(
                  code: widget.codeSnippet.trim(),
                  syntaxTheme: getSyntaxTheme(theme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

SyntaxTheme getSyntaxTheme(FluentThemeData theme) {
  final syntaxTheme = theme.brightness.isDark
      ? SyntaxTheme.vscodeDark()
      : SyntaxTheme.vscodeLight();

  syntaxTheme.baseStyle = GoogleFonts.firaCode(
    textStyle: syntaxTheme.baseStyle,
  );

  return syntaxTheme;
}
