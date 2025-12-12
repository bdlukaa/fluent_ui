import 'package:fluent_ui/fluent_ui.dart';

mixin PageMixin {
  Widget description({required final Widget content}) {
    return Builder(
      builder: (final context) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 4),
          child: DefaultTextStyle(
            style: FluentTheme.of(context).typography.body!,
            child: content,
          ),
        );
      },
    );
  }

  Widget subtitle({required final Widget content}) {
    return Builder(
      builder: (final context) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(top: 14, bottom: 2),
          child: DefaultTextStyle(
            style: FluentTheme.of(context).typography.subtitle!,
            child: content,
          ),
        );
      },
    );
  }
}
