import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';

void showCopiedSnackbar(BuildContext context, String copiedText) {
  showSnackbar(
    context,
    InfoBar(
      title: RichText(
        text: TextSpan(
          text: 'Copied ',
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: copiedText,
              style: TextStyle(
                color: Colors.blue.defaultBrushFor(
                  FluentTheme.of(context).brightness,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class IconsPage extends StatefulWidget {
  const IconsPage({super.key});

  @override
  State<IconsPage> createState() => _IconsPageState();
}

class _IconsPageState extends State<IconsPage> {
  String filterText = '';

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    final entries = FluentIcons.allIcons.entries.where(
      (icon) =>
          filterText.isEmpty ||
          // Remove '_'
          icon.key
              .replaceAll('_', '')
              // toLowerCase
              .toLowerCase()
              .contains(filterText
                  .toLowerCase()
                  // Remove spaces
                  .replaceAll(' ', '')),
    );

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Fluent Icons Gallery showcase'),
        commandBar: SizedBox(
          width: 240.0,
          child: Tooltip(
            message: 'Filter by name',
            child: TextBox(
              suffix: const Icon(FluentIcons.search),
              placeholder: 'Type to filter icons by name (e.g "logo")',
              onChanged: (value) => setState(() {
                filterText = value;
              }),
            ),
          ),
        ),
      ),
      bottomBar: const SizedBox(
        width: double.infinity,
        child: InfoBar(
          title: Text('Tip:'),
          content: Text(
            'You can click on any icon to copy its name to the clipboard!',
          ),
        ),
      ),
      content: GridView.builder(
        padding: EdgeInsetsDirectional.only(
          start: PageHeader.horizontalPadding(context),
          end: PageHeader.horizontalPadding(context),
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final e = entries.elementAt(index);
          return HoverButton(
            onPressed: () async {
              final copyText = 'FluentIcons.${e.key}';
              await FlutterClipboard.copy(copyText);
              if (context.mounted) showCopiedSnackbar(context, copyText);
            },
            cursor: SystemMouseCursors.copy,
            builder: (context, states) {
              return FocusBorder(
                focused: states.isFocused,
                renderOutside: false,
                child: Tooltip(
                  useMousePosition: false,
                  message:
                      '\nFluentIcons.${e.key}\n(tap to copy to clipboard)\n',
                  child: RepaintBoundary(
                    child: AnimatedContainer(
                      duration: FluentTheme.of(context).fasterAnimationDuration,
                      decoration: BoxDecoration(
                        color: ButtonThemeData.uncheckedInputColor(
                          FluentTheme.of(context),
                          states,
                          transparentWhenNone: true,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(e.value, size: 40),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(top: 8.0),
                            child: Text(
                              snakeCasetoSentenceCase(e.key),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String snakeCasetoSentenceCase(String original) {
    return '${original[0].toUpperCase()}${original.substring(1)}'
        .replaceAll(RegExp(r'(_|-)+'), ' ');
  }
}
