import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeSnippetCard extends StatefulWidget {
  const CodeSnippetCard({
    required this.child,
    required this.codeSnippet,
    super.key,
    this.backgroundColor,
    this.header,
    this.initiallyOpen = false,
  });

  final Widget? header;
  final Widget child;
  final String codeSnippet;

  final Color? backgroundColor;
  final bool initiallyOpen;

  @override
  State<CodeSnippetCard> createState() => _CodeSnippetCardState();
}

class _CodeSnippetCardState extends State<CodeSnippetCard>
    with AutomaticKeepAliveClientMixin<CodeSnippetCard> {
  late bool isOpen = widget.initiallyOpen;
  bool isCopying = false;

  final GlobalKey expanderKey = GlobalKey<ExpanderState>(
    debugLabel: 'Card Expander Key',
  );

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    final theme = FluentTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.resources.controlStrokeColorSecondary),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Mica(
              backgroundColor: widget.backgroundColor,
              child: Padding(
                padding: const EdgeInsetsDirectional.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: widget.child,
                  ),
                ),
              ),
            ),
            Expander(
              initiallyExpanded: widget.initiallyOpen,
              key: expanderKey,
              onStateChanged: (final state) {
                // this is done because [onStateChanges] is called while the [Expander]
                // is updating. By using this, we schedule the rebuilt of this widget
                // to the next frame
                WidgetsBinding.instance.addPostFrameCallback((final timeStamp) {
                  if (mounted) setState(() => isOpen = state);
                });
              },
              trailing: isOpen
                  ? Container(
                      height: 31,
                      constraints: const BoxConstraints(minWidth: 80),
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
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isCopying
                              ? Icon(
                                  WindowsIcons.check_mark,
                                  color: theme
                                      .resources
                                      .textOnAccentFillColorPrimary,
                                  size: 18,
                                )
                              : const Row(
                                  children: [
                                    WindowsIcon(WindowsIcons.copy),
                                    SizedBox(width: 6),
                                    Text('Copy'),
                                  ],
                                ),
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.codeSnippet),
                          );
                          setState(() => isCopying = true);
                          Future<void>.delayed(
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
              headerShape: (final open) {
                return const RoundedRectangleBorder();
              },
              content: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      spacing: 4,
                      children: [
                        const Text('Dart'),
                        Container(
                          height: 3,
                          width: 10,
                          decoration: BoxDecoration(
                            color: theme.accentColor.defaultBrushFor(
                              theme.brightness,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ],
                    ),
                    SyntaxView(
                      code: widget.codeSnippet.trim(),
                      syntaxTheme: getSyntaxTheme(theme),
                    ),
                  ],
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

SyntaxTheme getSyntaxTheme(final FluentThemeData theme) {
  final syntaxTheme = switch (theme.brightness) {
    Brightness.light => SyntaxTheme.vscodeLight(),
    Brightness.dark => SyntaxTheme.vscodeDark(),
  };

  syntaxTheme.baseStyle = GoogleFonts.firaCode(
    textStyle: syntaxTheme.baseStyle,
  );

  return syntaxTheme;
}
