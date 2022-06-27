import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AutoSuggestBoxPage extends ScrollablePage {
  String? selectedCat;

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('AutoSuggestBox'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'A text control that makes suggestions to users as they type. The app is notified when text has been changed by the user and is responsible for providing relevant suggestions for this control to display.',
      ),
      subtitle(content: const Text('A basic AutoSuggestBox')),
      CardHighlight(
        child: Row(
          children: [
            SizedBox(
              width: 350.0,
              child: AutoSuggestBox(
                items: _cats,
                onSelected: (item) {
                  setState(() => selectedCat = item);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(selectedCat ?? ''),
              ),
            ),
          ],
        ),
        codeSnippet: '''
String? selectedCat;

AutoSuggestBox(
  items: _cats,
  onSelected: (item) {
    setState(() => selected = item);
  },
),

const _cats = <String>[
  'Abyssinian',
  'Aegean',
  'American Bobtail',
  'American Curl',
  ...
];
''',
      ),
    ];
  }
}

const _cats = <String>[
  'Abyssinian',
  'Aegean',
  'American Bobtail',
  'American Curl',
  'American Ringtail',
  'American Shorthair',
  'American Wirehair',
  'Aphrodite Giant',
  'Arabian Mau',
  'Asian cat',
  'Asian Semi-longhair',
  'Australian Mist',
  'Balinese',
  'Bambino',
  'Bengal',
  'Birman',
  'Bombay',
  'Brazilian Shorthair',
  'British Longhair',
  'British Shorthair',
  'Burmese',
  'Burmilla',
  'California Spangled',
  'Chantilly-Tiffany',
  'Chartreux',
  'Chausie',
  'Colorpoint Shorthair',
  'Cornish Rex',
  'Cymric',
  'Cyprus',
  'Devon Rex',
  'Donskoy',
  'Dragon Li',
  'Dwelf',
  'Egyptian Mau',
  'European Shorthair',
  'Exotic Shorthair',
  'Foldex',
  'German Rex',
  'Havana Brown',
  'Highlander',
  'Himalayan',
  'Japanese Bobtail',
  'Javanese',
  'Kanaani',
  'Khao Manee',
  'Kinkalow',
  'Korat',
  'Korean Bobtail',
  'Korn Ja',
  'Kurilian Bobtail',
  'Lambkin',
  'LaPerm',
  'Lykoi',
  'Maine Coon',
  'Manx',
  'Mekong Bobtail',
  'Minskin',
  'Napoleon',
  'Munchkin',
  'Nebelung',
  'Norwegian Forest Cat',
  'Ocicat',
  'Ojos Azules',
  'Oregon Rex',
  'Oriental Bicolor',
  'Oriental Longhair',
  'Oriental Shorthair',
  'Persian (modern)',
  'Persian (traditional)',
  'Peterbald',
  'Pixie-bob',
  'Ragamuffin',
  'Ragdoll',
  'Raas',
  'Russian Blue',
  'Russian White',
  'Sam Sawet',
  'Savannah',
  'Scottish Fold',
  'Selkirk Rex',
  'Serengeti',
  'Serrade Petit',
  'Siamese',
  'Siberian or´Siberian Forest Cat',
  'Singapura',
  'Snowshoe',
  'Sokoke',
  'Somali',
  'Sphynx',
  'Suphalak',
  'Thai',
  'Thai Lilac',
  'Tonkinese',
  'Toyger',
  'Turkish Angora',
  'Turkish Van',
  'Turkish Vankedisi',
  'Ukrainian Levkoy',
  'Wila Krungthep',
  'York Chocolate',
];
