import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TilesPage extends StatefulWidget {
  const TilesPage({super.key});

  @override
  State<TilesPage> createState() => _TilesPageState();
}

class _TilesPageState extends State<TilesPage> with PageMixin {
  final shuffledIcons = WindowsIcons.allIcons.values.toList()..shuffle();

  // first
  final firstController = ScrollController();
  String firstSelected = '';

  // second
  final secondController = ScrollController();
  List<String> selected = [];

  // third
  String thirdSelected = '';
  final thirdController = ScrollController();

  @override
  Widget build(final BuildContext context) {
    final theme = FluentTheme.of(context);
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Tiles')),
      children: [
        description(
          content: const Text(
            'A windows-styled list tile. Usually used inside a ListView',
          ),
        ),
        subtitle(content: const Text('Basic ListView with selectable tiles')),
        CodeSnippetCard(
          codeSnippet: '''
String selectedContact = '';

const contacts = ['Kendall', 'Collins', ...];

ListView.builder(
  itemCount: contacts.length,
  itemBuilder: (context, index) {
    final contact = contacts[index];
    return ListTile.selectable(
      title: Text(contact),
      selected: selectedContact == contact,
      onSelectionChange: (v) => setState(() => selectedContact = contact),
    );
  } 
),''',
          child: Container(
            height: 400,
            width: 350,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.resources.surfaceStrokeColorDefault,
              ),
            ),
            child: ListView.builder(
              controller: firstController,
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (final context, final index) {
                final contact = contacts[index];
                return ListTile.selectable(
                  title: Text(contact),
                  selected: firstSelected == contact,
                  onSelectionChange: (final v) {
                    setState(() => firstSelected = contact);
                  },
                );
              },
            ),
          ),
        ),
        subtitle(
          content: const Text('ListViewItems with many properties applied'),
        ),
        CodeSnippetCard(
          codeSnippet: '''
List<String> selectedContacts = [];

const contacts = ['Kendall', 'Collins', ...];

ListView.builder(
  itemCount: contacts.length,
  itemBuilder: (context, index) {
    final contact = contacts[index];
    return ListTile.selectable(
      title: Text(contact),
      selected: selectedContacts.contains(contact),
      selectionMode: ListTileSelectionMode.multiple,
      onSelectionChange: (selected) {
        setState(() {
          if (selected) {
            selectedContacts.add(contact);
          } else {
            selectedContacts.remove(contact);
          }
        });
      },
    );
  } 
),''',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 400,
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.resources.surfaceStrokeColorDefault,
                  ),
                ),
                child: ListView.builder(
                  controller: secondController,
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  itemBuilder: (final context, final index) {
                    final contact = contacts[index];
                    return ListTile.selectable(
                      leading: const CircleAvatar(radius: 15),
                      title: Text(contact),
                      subtitle: const Text('With a custom subtitle'),
                      trailing: Icon(shuffledIcons[index]),
                      selectionMode: ListTileSelectionMode.multiple,
                      selected: selected.contains(contact),
                      onSelectionChange: (final selected) {
                        setState(() {
                          if (selected) {
                            this.selected.add(contact);
                          } else {
                            this.selected.remove(contact);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('ListViewItems with images')),
        CodeSnippetCard(
          codeSnippet: '''
String selectedContact = '';

const contacts = ['Kendall', 'Collins', ...];

ListView.builder(
  itemCount: contacts.length,
  itemBuilder: (context, index) {
    final contact = contacts[index];
    return ListTile.selectable(
      leading: SizedBox(
        height: 100,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(
            color: Colors.accentColors[index ~/ 20],
            child: const Placeholder(),
          ),
        ),
      ),
      title: Text(contact),
      subtitle: const Text('With a custom subtitle'),
      selectionMode: ListTileSelectionMode.single,
      selected: selectedContact == contact,
      onSelectionChange: (v) => setState(() => selectedContact = contact),
    );
  } 
),''',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 400,
                width: 550,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.resources.surfaceStrokeColorDefault,
                  ),
                ),
                child: ListView.builder(
                  controller: thirdController,
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  itemBuilder: (final context, final index) {
                    final contact = contacts[index];
                    return ListTile.selectable(
                      leading: SizedBox(
                        height: 100,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ColoredBox(
                            color: Colors.accentColors[index ~/ 20],
                            child: const Placeholder(),
                          ),
                        ),
                      ),
                      title: Text(contact),
                      subtitle: const Text('With a custom subtitle'),
                      selected: thirdSelected == contact,
                      onSelectionChange: (final selected) {
                        setState(() {
                          if (selected) {
                            thirdSelected = contact;
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const String _contactsList = '''
Kendall
Collins
Adatum Corporation
Henry
Ross
Adventure Works Cycles
Vance
DeLeon
Alpine Ski House
Victoria
Burke
Bellows College
Amber
Rodriguez
Best For You Organics Company
Amari
Rivera
Contoso, Ltd.
Jessie
Irwin
Contoso Pharmaceuticals
Quinn
Campbell
Contoso Suites
Olivia
Wilson
Consolidated Messenger
Ana
Bowman
Fabrikam, Inc.
Shawn
Hughes
Fabrikam Residences
Oscar
Ward
First Up Consultants
Madison
Butler
Fourth Coffee
Graham
Barnes
Graphic Design Institute
Anthony
Ivanov
Humongous Insurance
Michael
Peltier
Lamna Healthcare Company
Morgan
Connors
Liberty's Delightful Sinful Bakery & Cafe
Andre
Lawson
Lucerne Publishing
Preston
Morales
Margie's Travel
Briana
Hernandez
Nod Publishers
Nicole
Wagner
Northwind Traders
Mario
Rogers
Proseware, Inc.
Eugenia
Lopez
Relecloud
Nathan
Rigby
School of Fine Art
Ellis
Turner
Southridge Video
Miguel
Reyes
Tailspin Toys
Hayden
Cook
Tailwind Traders''';

List<String> contacts = _contactsList.split('\n');
