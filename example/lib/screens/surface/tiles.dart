import 'package:example/widgets/card_highlight.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:example/widgets/page.dart';

class TilePage extends ScrollablePage {
  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('Tiles'));
  }

  // first
  final firstController = ScrollController();
  String firstSelected = '';

  // second
  final secondController = ScrollController();
  ListTileSelectionMode selectionMode = ListTileSelectionMode.none;
  List<String> selected = [];

  @override
  List<Widget> buildScrollable(BuildContext context) {
    final theme = FluentTheme.of(context);
    return [
      const Text('Tiles that are usually used inside a ListView'),
      subtitle(content: const Text('Basic ListView with selectable tiles')),
      CardHighlight(
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
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile.selectable(
                title: Text(contact),
                selected: firstSelected == contact,
                onSelectionChange: (v) {
                  setState(() => firstSelected = contact);
                },
              );
            },
          ),
        ),
        codeSnippet: '''''',
      ),
      subtitle(content: const Text('Basic ListView with Selection support')),
      CardHighlight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile.selectable(
                  leading: const CircleAvatar(radius: 15.0),
                  title: Text(contact),
                  selectionMode: selectionMode,
                  selected: selected.contains(contact),
                  onSelectionChange: (selected) {
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
          const Spacer(),
          Combobox<ListTileSelectionMode>(
            value: selectionMode,
            items: ListTileSelectionMode.values.map((mode) {
              return ComboboxItem(
                value: mode,
                child: Text(mode.name),
              );
            }).toList(),
            onChanged: (mode) => setState(
              () => selectionMode = mode ?? ListTileSelectionMode.none,
            ),
          ),
        ]),
        codeSnippet: '''''',
      ),
    ];
  }
}

const String _contactsList = '''Kendall
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

late List<String> contacts = _contactsList.split('\n');
