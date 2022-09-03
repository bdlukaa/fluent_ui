import 'dart:async';

import 'package:example/widgets/deferred_widget.dart';

import 'package:fluent_ui/fluent_ui.dart';

abstract class Page {
  Page() {
    _pageIndex++;
  }

  final StreamController _controller = StreamController.broadcast();
  Stream get stateStream => _controller.stream;

  Widget build(BuildContext context);

  void setState(VoidCallback func) {
    func();
    _controller.add(null);
  }

  Widget description({required Widget content}) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: DefaultTextStyle(
          style: FluentTheme.of(context).typography.body!,
          child: content,
        ),
      );
    });
  }

  Widget subtitle({required Widget content}) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(top: 14.0, bottom: 2.0),
        child: DefaultTextStyle(
          style: FluentTheme.of(context).typography.subtitle!,
          child: content,
        ),
      );
    });
  }
}

int _pageIndex = -1;

abstract class ScrollablePage extends Page {
  ScrollablePage() : super();

  final scrollController = ScrollController();
  Widget buildHeader(BuildContext context) => const SizedBox.shrink();

  Widget buildBottomBar(BuildContext context) => const SizedBox.shrink();

  List<Widget> buildScrollable(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      key: PageStorageKey(_pageIndex),
      scrollController: scrollController,
      header: buildHeader(context),
      children: buildScrollable(context),
      bottomBar: buildBottomBar(context),
    );
  }
}

class EmptyPage extends Page {
  final Widget? child;

  EmptyPage([this.child]);

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}

typedef DeferredPageBuilder = Page Function();

class DeferredPage extends Page {
  final LibraryLoader libraryLoader;
  final DeferredPageBuilder createPage;

  DeferredPage({
    required this.libraryLoader,
    required this.createPage,
  });

  @override
  Widget build(BuildContext context) {
    return DeferredWidget(libraryLoader, () => createPage().build(context));
  }
}

extension PageExtension on List<Page> {
  List<Widget> transform(BuildContext context) {
    return map((page) {
      return StreamBuilder(
        stream: page.stateStream,
        builder: (context, _) {
          return page.build(context);
        },
      );
    }).toList();
  }
}

extension WidgetPageExtension on Widget {
  Page toPage() {
    return EmptyPage(this);
  }
}
