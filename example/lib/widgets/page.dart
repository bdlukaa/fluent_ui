import 'package:fluent_ui/fluent_ui.dart';

mixin PageMixin {
  Widget description({required Widget content}) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 4.0),
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
        padding: const EdgeInsetsDirectional.only(top: 14.0, bottom: 2.0),
        child: DefaultTextStyle(
          style: FluentTheme.of(context).typography.subtitle!,
          child: content,
        ),
      );
    });
  }
}
