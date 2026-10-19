import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

import 'icon_catalog.dart';

class IconBrowser extends StatefulWidget {
  const IconBrowser({this.initialSelection, super.key});

  final IconEntry? initialSelection;

  @override
  State<IconBrowser> createState() => _IconBrowserState();
}

class _IconBrowserState extends State<IconBrowser> {
  final _searchController = TextEditingController();
  IconCollection _collection = IconCollection.windows;
  IconEntry? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
  }

  String _query = '';
  double _previewSize = 64;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IconEntry> get _entries => IconCatalog.search(_collection, _query);

  void _changeCollection(IconCollection? collection) {
    if (collection == null || collection == _collection) return;
    setState(() {
      _collection = collection;
      _selected = null;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _copy(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      await displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: const Text('Copied to clipboard'),
          content: SelectableText(text),
          severity: InfoBarSeverity.success,
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      await displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: const Text('Unable to copy'),
          content: const Text('Your browser denied clipboard access.'),
          severity: InfoBarSeverity.error,
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
        ),
      );
    }
  }

  Future<void> _selectAndCopy(IconEntry entry) async {
    setState(() => _selected = entry);
    await _copy(context, entry.identifier);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final theme = FluentTheme.of(context);
    return ScaffoldPage(
      header: PageHeader(
        title: Text('Fluent UI icons', style: theme.typography.title),
        commandBar: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Tooltip(
            message: 'Search icon names',
            child: TextBox(
              controller: _searchController,
              placeholder: 'Search icons',
              onChanged: (value) => setState(() => _query = value),
              suffix: _query.isEmpty
                  ? const Padding(
                      padding: EdgeInsetsDirectional.only(end: 8),
                      child: Icon(FluentIcons.search, size: 16),
                    )
                  : IconButton(
                      icon: const Icon(FluentIcons.clear, size: 16),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
      ),
      content: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 16),
              child: _BrowserControls(
                collection: _collection,
                count: entries.length,
                onChanged: _changeCollection,
              ),
            ),
          ),
          if (_selected case final selected?)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 16),
                child: _IconPreview(
                  entry: selected,
                  size: _previewSize,
                  onSizeChanged: (size) => setState(() => _previewSize = size),
                  onCopy: () => _copy(context, selected.usageSnippet),
                ),
              ),
            ),
          if (entries.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptySearchState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 24),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 116,
                ),
                itemCount: entries.length,
                itemBuilder: (context, index) => _IconTile(
                  entry: entries[index],
                  selected: entries[index] == _selected,
                  onPressed: _selectAndCopy,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrowserControls extends StatelessWidget {
  const _BrowserControls({
    required this.collection,
    required this.count,
    required this.onChanged,
  });

  final IconCollection collection;
  final int count;
  final ValueChanged<IconCollection?> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final selector = SizedBox(
          width: constraints.maxWidth < 360 ? double.infinity : 200,
          child: ComboBox<IconCollection>(
            isExpanded: true,
            value: collection,
            onChanged: onChanged,
            items: [
              for (final value in IconCollection.values)
                ComboBoxItem(value: value, child: Text(value.label)),
            ],
          ),
        );
        final result = Text('$count matching icons');
        return constraints.maxWidth < 360
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [selector, result],
              )
            : Row(children: [selector, const SizedBox(width: 12), result]);
      },
    );
  }
}

class _IconPreview extends StatelessWidget {
  const _IconPreview({
    required this.entry,
    required this.size,
    required this.onSizeChanged,
    required this.onCopy,
  });

  final IconEntry entry;
  final double size;
  final ValueChanged<double> onSizeChanged;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(entry.identifier, style: theme.typography.subtitle),
        const SizedBox(height: 4),
        SelectableText(
          'Code point: 0x${entry.icon.codePoint.toRadixString(16)}',
        ),
        SelectableText('Font family: ${entry.icon.fontFamily ?? 'Default'}'),
        const SizedBox(height: 8),
        SelectableText(entry.usageSnippet),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: onCopy,
          child: const Text('Copy usage snippet'),
        ),
      ],
    );
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final preview = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(entry.icon, size: size, semanticLabel: entry.identifier),
                const SizedBox(height: 8),
                SizedBox(
                  width: 180,
                  child: Slider(
                    value: size,
                    min: 24,
                    max: 160,
                    divisions: 17,
                    label: '${size.round()}',
                    onChanged: onSizeChanged,
                  ),
                ),
              ],
            );
            return constraints.maxWidth < 520
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [preview, details],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 200, child: preview),
                      Expanded(child: details),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.entry,
    required this.selected,
    required this.onPressed,
  });

  final IconEntry entry;
  final bool selected;
  final ValueChanged<IconEntry> onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Tooltip(
      message: entry.identifier,
      child: HoverButton(
        onPressed: () => onPressed(entry),
        cursor: SystemMouseCursors.copy,
        builder: (context, states) => FocusBorder(
          focused: states.isFocused,
          renderOutside: false,
          child: AnimatedContainer(
            duration: theme.fasterAnimationDuration,
            decoration: BoxDecoration(
              color: selected
                  ? theme.accentColor.defaultBrushFor(theme.brightness)
                  : ButtonThemeData.uncheckedInputColor(
                      theme,
                      states,
                      transparentWhenNone: true,
                    ),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsetsDirectional.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(entry.icon, size: 32, semanticLabel: entry.identifier),
                const SizedBox(height: 8),
                Text(
                  iconDisplayName(entry.name),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.search, size: 40),
          SizedBox(height: 12),
          Text('No icons match this search.'),
          SizedBox(height: 4),
          Text('Try a shorter name or remove separators.'),
        ],
      ),
    );
  }
}
