import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AutoSuggestBoxPage extends StatefulWidget {
  const AutoSuggestBoxPage({super.key});

  @override
  State<AutoSuggestBoxPage> createState() => _AutoSuggestBoxPageState();
}

class _AutoSuggestBoxPageState extends State<AutoSuggestBoxPage>
    with PageMixin {
  String? selectedCat;
  Cat? selectedObjectCat;
  bool enabled = true;

  final asgbKey = GlobalKey<AutoSuggestBoxState>(
    debugLabel: 'Manually controlled AutoSuggestBox',
  );

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('AutoSuggestBox'),
        commandBar: ToggleSwitch(
          content: const Text('Disabled'),
          checked: !enabled,
          onChanged: (final v) => setState(() => enabled = !v),
        ),
      ),
      children: [
        const Text(
          'A text control that makes suggestions to users as they type. The app '
          'is notified when text has been changed by the user and is responsible '
          'for providing relevant suggestions for this control to display.',
        ),
        subtitle(content: const Text('A basic AutoSuggestBox')),
        CodeSnippetCard(
          codeSnippet: r'''
String? selectedCat;

AutoSuggestBox<String>(
  placeholder: 'Type a cat name',
  items: cats.map((cat) {
    return AutoSuggestBoxItem<String>(
      value: cat,
      label: cat,
      onFocusChange: (focused) {
        if (focused) { 
          debugPrint('Focused $cat');
        }
      }
    );
  }).toList(),
  onSelected: (item) {
    setState(() => selected = item);
  },
),

const cats = <String>[
  'Abyssinian',
  'Aegean',
  'American Bobtail',
  'American Curl',
  ...
];''',
          child: Row(
            children: [
              SizedBox(
                width: 350,
                child: AutoSuggestBox<String>(
                  placeholder: 'Type a cat name',
                  enabled: enabled,
                  items: cats
                      .map<AutoSuggestBoxItem<String>>(
                        (final cat) => AutoSuggestBoxItem<String>(
                          value: cat,
                          label: cat,
                          onFocusChange: (final focused) {
                            if (focused) debugPrint('Focused $cat');
                          },
                        ),
                      )
                      .toList(),
                  onSelected: (final item) {
                    setState(() => selectedCat = item.value);
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Text(selectedCat ?? ''),
                ),
              ),
            ],
          ),
        ),
        subtitle(
          content: const Text('A AutoSuggestBox with a custom type "Cat"'),
        ),
        description(
          content: const Text(
            'The control can be used with a custom value class. With this feature,'
            ' AutoSuggestBox can be used as a replacement of a ComboBox.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: r'''
class Cat {
  final int id;
  final String name;
  final bool hasTag;

  const Cat(this.id, this.name, this.hasTag);
}
        
Cat? selectedObjectCat;

AutoSuggestBox<Cat>(
  items: objectCats
      .map<AutoSuggestBoxItem<Cat>>(
        (cat) => AutoSuggestBoxItem<Cat>(
          value: cat,
          label: cat.name,
          onFocusChange: (focused) {
            if (focused) {
              debugPrint('Focused #${cat.id} - ${cat.name}');
            }
          },
        ),
      )
      .toList(),
  onSelected: (item) {
    setState(() => selectedObjectCat = item.value);
  },
),

const objectCats = [
  Cat(1, 'Abyssinian', true),
  Cat(2, 'Aegean', true),
  Cat(3, 'American Bobtail', false),
  Cat(4, 'American Curl', true),
  Cat(5, 'American Ringtail', false),
  Cat(6, 'American Shorthair', true),
  ...
];''',
          child: Row(
            children: [
              SizedBox(
                width: 350,
                child: AutoSuggestBox<Cat>(
                  enabled: enabled,
                  items: objectCats
                      .map<AutoSuggestBoxItem<Cat>>(
                        (final cat) => AutoSuggestBoxItem<Cat>(
                          value: cat,
                          label: cat.name,
                          onFocusChange: (final focused) {
                            if (focused) {
                              debugPrint('Focused $cat');
                            }
                          },
                        ),
                      )
                      .toList(),
                  onSelected: (final item) {
                    setState(() => selectedObjectCat = item.value);
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Text(
                    selectedObjectCat != null
                        ? 'Cat #${selectedObjectCat!.id} "${selectedObjectCat!.name}" ${selectedObjectCat!.hasTag ? '[🏷 TAGGED]' : "[❌ NON TAGGED]"}'
                        : '',
                  ),
                ),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('An AutoSuggestBox with manual control')),
        description(
          content: const Text(
            'To manually control an AutoSuggestBox, you can use '
            'the "GlobalKey<AutoSuggestBoxState>" to get the "AutoSuggestBoxState" '
            'instance. With this instance, you can call the "showOverlay" and '
            '"dismissOverlay" methods to show and hide the overlay. To check if '
            'the overlay is visible, you can use the "isOverlayVisible" property',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: r'''
final asgbKey = GlobalKey<AutoSuggestBoxState>(
  debugLabel: 'Manually controlled AutoSuggestBox',
);

AutoSuggestBox<String>(
  key: asgbKey,
  items: cats.map((cat) {
    return ...;
  }).toList(),
  onSelected: (item) { ... },
  // Listen to the overlay visibility changes
  onOverlayVisibilityChanged: (visible) { debugPrint('$visible'); },
),

// To toggle the overlay state, first check if it's visible
final isOverlayVisible = asgbKey.currentState?.isOverlayVisible ?? false;
if (isOverlayVisible) {
  // Call the dismissOverlay method to hide the overlay
  asgbKey.currentState?.dismissOverlay();
} else {
  // Call the showOverlay method to show the overlay
  asgbKey.currentState?.showOverlay();
}
''',
          child: Wrap(
            runAlignment: WrapAlignment.spaceBetween,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 350,
                    child: AutoSuggestBox<String>(
                      key: asgbKey,
                      enabled: enabled,
                      items: cats
                          .map<AutoSuggestBoxItem<String>>(
                            (final cat) => AutoSuggestBoxItem<String>(
                              value: cat,
                              label: cat,
                              onFocusChange: (final focused) {
                                if (focused) debugPrint('Focused $cat');
                              },
                            ),
                          )
                          .toList(),
                      onSelected: (final item) {
                        setState(() => selectedCat = item.value);
                      },
                      onOverlayVisibilityChanged: (final visible) {
                        debugPrint('Overlay is visible: $visible');
                        setState(() {});
                      },
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: Text(selectedCat ?? ''),
                    ),
                  ),
                ],
              ),
              ToggleButton(
                checked: asgbKey.currentState?.isOverlayVisible ?? false,
                onChanged: (_) {
                  final asgbState = asgbKey.currentState;
                  if (asgbState == null) return;

                  if (asgbState.isOverlayVisible) {
                    asgbState.dismissOverlay();
                  } else {
                    asgbState.showOverlay();
                  }
                  setState(() {});
                },
                child: Text(
                  asgbKey.currentState?.isOverlayVisible ?? false
                      ? 'Hide overlay'
                      : 'Show overlay',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const cats = <String>[
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

const objectCats = [
  Cat(1, 'Abyssinian', true),
  Cat(2, 'Aegean', true),
  Cat(3, 'American Bobtail', false),
  Cat(4, 'American Curl', true),
  Cat(5, 'American Ringtail', false),
  Cat(6, 'American Shorthair', true),
  Cat(7, 'American Wirehair', false),
  Cat(8, 'Aphrodite Giant', true),
  Cat(9, 'Arabian Mau', false),
  Cat(10, 'Asian cat', true),
  Cat(11, 'Asian Semi-longhair', false),
  Cat(12, 'Australian Mist', false),
  Cat(13, 'Balinese', false),
  Cat(14, 'Bambino', false),
  Cat(15, 'Bengal', true),
  Cat(16, 'Birman', false),
  Cat(17, 'Bombay', true),
  Cat(18, 'Brazilian Shorthair', false),
  Cat(19, 'British Longhair', true),
  Cat(20, 'British Shorthair', false),
  Cat(21, 'Burmese', true),
  Cat(22, 'Burmilla', false),
  Cat(23, 'California Spangled', false),
  Cat(24, 'Chantilly-Tiffany', true),
  Cat(25, 'Chartreux', true),
  Cat(26, 'Chausie', false),
  Cat(27, 'Colorpoint Shorthair', true),
  Cat(28, 'Cornish Rex', false),
  Cat(29, 'Cymric', false),
  Cat(30, 'Cyprus', false),
  Cat(31, 'Devon Rex', false),
  Cat(32, 'Donskoy', false),
  Cat(33, 'Dragon Li', false),
  Cat(34, 'Dwelf', false),
  Cat(35, 'Egyptian Mau', true),
  Cat(36, 'European Shorthair', false),
  Cat(37, 'Exotic Shorthair', false),
  Cat(38, 'Foldex', false),
  Cat(39, 'German Rex', true),
  Cat(40, 'Havana Brown', true),
  Cat(41, 'Highlander', true),
  Cat(42, 'Himalayan', true),
  Cat(43, 'Japanese Bobtail', true),
  Cat(44, 'Javanese', true),
  Cat(45, 'Kanaani', true),
  Cat(46, 'Khao Manee', true),
  Cat(47, 'Kinkalow', true),
  Cat(48, 'Korat', false),
  Cat(49, 'Korean Bobtail', true),
  Cat(50, 'Korn Ja', false),
  Cat(51, 'Kurilian Bobtail', true),
  Cat(52, 'Lambkin', false),
  Cat(53, 'LaPerm', true),
  Cat(54, 'Lykoi', true),
  Cat(55, 'Maine Coon', false),
  Cat(56, 'Manx', true),
  Cat(57, 'Mekong Bobtail', true),
  Cat(58, 'Minskin', false),
  Cat(59, 'Napoleon', true),
  Cat(60, 'Munchkin', false),
  Cat(61, 'Nebelung', false),
  Cat(62, 'Norwegian Forest Cat', false),
  Cat(63, 'Ocicat', true),
  Cat(64, 'Ojos Azules', true),
  Cat(65, 'Oregon Rex', false),
  Cat(66, 'Oriental Bicolor', true),
  Cat(67, 'Oriental Longhair', false),
  Cat(68, 'Oriental Shorthair', true),
  Cat(69, 'Persian (modern)', true),
  Cat(70, 'Persian (traditional)', true),
  Cat(71, 'Peterbald', false),
  Cat(72, 'Pixie-bob', false),
  Cat(73, 'Ragamuffin', true),
  Cat(74, 'Ragdoll', true),
  Cat(75, 'Raas', true),
  Cat(76, 'Russian Blue', true),
  Cat(77, 'Russian White', true),
  Cat(78, 'Sam Sawet', false),
  Cat(79, 'Savannah', false),
  Cat(80, 'Scottish Fold', false),
  Cat(81, 'Selkirk Rex', false),
  Cat(82, 'Serengeti', false),
  Cat(83, 'Serrade Petit', false),
  Cat(84, 'Siamese', false),
  Cat(85, 'Siberian or´Siberian Forest Cat', false),
  Cat(86, 'Singapura', true),
  Cat(87, 'Snowshoe', false),
  Cat(88, 'Sokoke', false),
  Cat(89, 'Somali', false),
  Cat(90, 'Sphynx', true),
  Cat(91, 'Suphalak', true),
  Cat(92, 'Thai', false),
  Cat(93, 'Thai Lilac', false),
  Cat(94, 'Tonkinese', false),
  Cat(95, 'Toyger', true),
  Cat(96, 'Turkish Angora', true),
  Cat(97, 'Turkish Van', false),
  Cat(98, 'Turkish Vankedisi', false),
  Cat(99, 'Ukrainian Levkoy', false),
  Cat(100, 'Wila Krungthep', true),
  Cat(101, 'York Chocolate', true),
];

class Cat {
  final int id;
  final String name;
  final bool hasTag;

  const Cat(this.id, this.name, this.hasTag);
}
