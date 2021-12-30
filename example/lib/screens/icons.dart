import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';

class IconsPage extends StatefulWidget {
  const IconsPage({Key? key}) : super(key: key);

  @override
  _IconsPageState createState() => _IconsPageState();
}

class _IconsPageState extends State<IconsPage> {
  String filterText = "";

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Fluent Icons Gallery showcase'),
        commandBar: SizedBox(
          width: 240.0,
          child: Tooltip(
            message: 'Filter by name',
            child: TextBox(
              header: 'Search',
              suffix: const Icon(FluentIcons.search),
              placeholder: 'Type to filter icons by name (ex: "logo")',
              onChanged: (value) => setState(() {
                filterText = value;
              }),
            ),
          ),
        ),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: PageHeader.horizontalPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
            ),
            const InfoBar(
              title: Text("Useful info:"),
              content:
                  Text("Use the upper right search box to filter the icons. You can also click on any icon to copy its name to the clipboard!"),
            ),
            Expanded(
              child: GridView.extent(
                  maxCrossAxisExtent: 150,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: FluentIcons.allIcons.entries
                      .where((element) =>
                          filterText.isEmpty ||
                          // Remove "_"
                          element.key
                              .replaceAll("_", "")
                              // toLowerCase
                              .toLowerCase()
                              .contains(filterText
                                  .toLowerCase()
                                  // Remove spaces
                                  .replaceAll(" ", "")))
                      .map((e) => GestureDetector(
                            onTap: () =>
                                FlutterClipboard.copy('FluentIcons.${e.key}')
                                    .then(
                              (_) => showSnackbar(
                                context,
                                Snackbar(
                                  content: Text(
                                      'Copied "FluentIcons.${e.key}" to the clipboard!'),
                                  extended: true,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  e.value,
                                  size: 40,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    e.key,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                  ),
                                )
                              ],
                            ),
                          ))
                      .toList()),
            )
          ],
        ),
      ),
    );
  }
}
