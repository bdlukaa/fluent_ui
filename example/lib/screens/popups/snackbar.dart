import 'package:clipboard/clipboard.dart';
import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SnackBarPage extends StatefulWidget {
  const SnackBarPage({super.key});

  @override
  State<SnackBarPage> createState() => _SnackBarPageState();
}

class _SnackBarPageState extends State<SnackBarPage> with PageMixin {
  var textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('SnackBar')),
      children: [
        const Text(
            'A Snackbar is a small message that pops up at the bottom of '
            'the screen to display a brief message to the user. '
            'It is often used to provide feedback or to alert the user of a change or an error.'),
        subtitle(content: const Text('Example of a Simple SnackBar')),
        CardHighlight(
            child: Button(
              child: const Text('Click me'),
              onPressed: () {
                showSnackbar(
                  context,
                  const Snackbar(
                    content: Text('A Simple SnackBar'),
                  ),
                );
              },
            ),
            codeSnippet: '''
showSnackbar(
  context,
  const Snackbar(
    content: Text('A Simple SnackBar'),
  ),
);
'''),
        subtitle(content: const Text('Example of a Featureful SnackBar')),
        CardHighlight(
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextBox(
                    controller: textEditingController,
                    placeholder: 'Enter Something',
                  ),
                ),
                const SizedBox(width: 10.0),
                Button(
                  child: const Text('Copy to clipboard'),
                  onPressed: () async {
                    if (textEditingController.text.isEmpty) {
                      showSnackbarWithText(
                          context, textEditingController.text, false);
                      return;
                    }
                    await FlutterClipboard.copy(textEditingController.text);
                    showSnackbarWithText(
                        context, textEditingController.text, true);
                  },
                ),
                const Spacer(),
              ],
            ),
            codeSnippet: '''
// Define text editing controller
var textEditingController = TextEditingController();

// A sample Row which renders TextBox and Button
Row(
  children: [
    SizedBox(
      width: 300,
      child: TextBox(
        controller: textEditingController,
        placeholder: 'Enter Something',
      ),
    ),
    const SizedBox(width: 10.0),
    Button(
      child: const Text('Copy to clipboard'),
      onPressed: () async {
        if (textEditingController.text.isEmpty) {
          showSnackbarWithText(
              context, textEditingController.text, false);
          return;
        }
        await FlutterClipboard.copy(textEditingController.text);
        showSnackbarWithText(
            context, textEditingController.text, true);
      },
    ),
    const Spacer(),
  ],
);

// takes String copiedText and bool statusPass
// statusPass indicates if the entered text can be
// copied to clipboard
void showSnackbarWithText(
    BuildContext context, String copiedText, bool statusPass) {
  showSnackbar(
    context,
    Snackbar(
      content: RichText(
        text: TextSpan(
          text: statusPass ? 'Copied: ' : 'Error: ',
          style: TextStyle(color: statusPass ? Colors.white : Colors.red),
          children: [
            TextSpan(
              text: statusPass
                  ? copiedText
                  : 'Empty string can not be copied to clipboard',
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
      extended: true,
    ),
  );
}

// Do not forget to dispose the textEditingController
@override
void dispose() {
  textEditingController.dispose();
  super.dispose();
}
'''),
      ],
    );
  }
}

// takes String copiedText and bool statusPass
// statusPass indicates if the entered text can be
// copied to clipboard
void showSnackbarWithText(
    BuildContext context, String copiedText, bool statusPass) {
  showSnackbar(
    context,
    Snackbar(
      content: RichText(
        text: TextSpan(
          text: statusPass ? 'Copied: ' : 'Error: ',
          style: TextStyle(color: statusPass ? Colors.white : Colors.red),
          children: [
            TextSpan(
              text: statusPass
                  ? copiedText
                  : 'Empty string can not be copied to clipboard',
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
      extended: true,
    ),
  );
}
