import 'package:fluent_ui/fluent_ui.dart';

enum IconCollection {
  fluent('Fluent Icons', 'FluentIcons', FluentIcons.allIcons),
  windows('Windows Icons', 'WindowsIcons', WindowsIcons.allIcons);

  const IconCollection(this.label, this.identifier, this.icons);

  final String label;
  final String identifier;
  final Map<String, IconData> icons;
}

class IconEntry {
  IconEntry({required this.name, required this.icon, required this.collection})
    : normalizedName = normalizeIconQuery(name);

  final String name;
  final IconData icon;
  final IconCollection collection;
  final String normalizedName;

  String get identifier => '${collection.identifier}.$name';

  String get usageSnippet => 'const Icon($identifier, size: 24)';
}

class IconCatalog {
  IconCatalog._();

  static final Map<IconCollection, List<IconEntry>> _entries = {
    for (final collection in IconCollection.values)
      collection: collection.icons.entries
          .map(
            (entry) => IconEntry(
              name: entry.key,
              icon: entry.value,
              collection: collection,
            ),
          )
          .toList(growable: false),
  };

  static List<IconEntry> entriesFor(IconCollection collection) =>
      _entries[collection]!;

  static List<IconEntry> search(IconCollection collection, String query) {
    final normalizedQuery = normalizeIconQuery(query);
    final entries = entriesFor(collection);
    if (normalizedQuery.isEmpty) return entries;
    return entries
        .where((entry) => entry.normalizedName.contains(normalizedQuery))
        .toList(growable: false);
  }
}

String normalizeIconQuery(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[_\-\s]'), '');

String iconDisplayName(String name) =>
    name.replaceAll('_', ' ').replaceAll('-', ' ');
