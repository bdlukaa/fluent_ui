import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TextBoxPage extends ScrollablePage {
  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('TextBox'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'Use a TextBox to let a user enter simple text input in your app. You can add a header and placeholder text to let the user know what the TextBox is for, and you can customize it in other ways.',
      ),
      subtitle(content: const Text('A simple TextBox')),
      Card(
        child: Row(children: const [
          Expanded(child: TextBox()),
          SizedBox(width: 10.0),
          Expanded(child: TextBox(enabled: false, placeholder: 'Disabled'))
        ]),
      ),
      subtitle(
        content: const Text('A TextBox with a header and placeholder text'),
      ),
      const Card(
        child: TextBox(
          header: 'Enter your name:',
          placeholder: 'Name',
          expands: false,
        ),
      ),
      subtitle(
        content: const Text('A read-only TextBox with various properties set'),
      ),
      const Card(
        child: TextBox(
          readOnly: true,
          placeholder: 'I am super excited to be here!',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 24.0,
            letterSpacing: 8,
            color: Color(0xFF5178BE),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      subtitle(content: const Text('A multi-line TextBox')),
      const Card(
        child: TextBox(
          maxLines: null,
        ),
      ),
    ];
  }
}
