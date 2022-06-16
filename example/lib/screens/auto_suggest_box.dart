import 'package:fluent_ui/fluent_ui.dart';

class AutoSuggestBoxes extends StatefulWidget {
  const AutoSuggestBoxes({Key? key}) : super(key: key);

  @override
  State<AutoSuggestBoxes> createState() => _AutoSuggestBoxesState();
}

class _AutoSuggestBoxesState extends State<AutoSuggestBoxes> {
  String selectedCat = '';
  String selectedCat2 = '';

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('AutoSuggestBox')),
      children: [
        const Text(
          'A text control that makes sugestions to users as they type. The app '
          'is notified when text has been changed by the user and is responsible '
          'for providing relevant suggestions for this control to display.',
        ),
        const SizedBox(height: 10.0),
        Text(
          'A basic autosuggest box.',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 10.0),
        Row(
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
                child: Text(selectedCat),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Text(
          'An AutoSuggestBox that provides a SearchBox experience.',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            SizedBox(
              width: 350.0,
              child: AutoSuggestBox(
                items: _cats,
                onSelected: (item) {
                  setState(() => selectedCat2 = item);
                },
                placeholder: 'Type a cat breed',
                trailingIcon: IconButton(
                  icon: const Icon(FluentIcons.search),
                  onPressed: () {
                    debugPrint('search button pressed');
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(selectedCat2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Text(
          'A form AutoSuggestBox.',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            SizedBox(
              width: 350.0,
              child: AutoSuggestBox.form(
                items: _cats,
                onSelected: (item) {
                  setState(() => selectedCat = item);
                },
                autovalidateMode: AutovalidateMode.always,
                validator: (text) {
                  if (!_cats.contains(text)) return 'INVALID';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
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
