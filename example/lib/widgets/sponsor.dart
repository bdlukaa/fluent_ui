import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';

class SponsorDialog extends StatelessWidget {
  const SponsorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 600),
      title: Row(
        children: [
          const Icon(FluentIcons.diamond_user, size: 24.0),
          const SizedBox(width: 8.0),
          const Expanded(child: Text('Benefits')),
          SmallIconButton(
            child: Tooltip(
              message: FluentLocalizations.of(context).closeButtonLabel,
              child: IconButton(
                icon: const Icon(FluentIcons.chrome_close),
                onPressed: Navigator.of(context).pop,
              ),
            ),
          ),
        ],
      ),
      content: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Tier(
              name: 'Royal Secretary',
              price: r'US$6 per month',
              benefits: [
                'General support',
                'Priority on issues fix',
                'Sponsor role on Discord',
                'Be the first to know when a new update rolls out',
              ],
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: _Tier(
              name: 'Royal Executor',
              price: r'US$15 per month',
              benefits: [
                'General support',
                'Priority on issues fix',
                'Sponsor role on Discord',
                'Showcasing in the "Sponsors" section',
                'Be the first to know when a new update rolls out',
                'Private channel on Discord with dedicated help',
              ],
            ),
          )
        ],
      ),
      actions: [
        Link(
          uri: Uri.parse('https://www.patreon.com/bdlukaa'),
          builder: (context, open) => FilledButton(
            onPressed: open,
            child: Semantics(
              link: true,
              child: const Text('Become a Sponsor'),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tier extends StatelessWidget {
  const _Tier({
    required this.name,
    required this.price,
    required this.benefits,
  });

  final String name;
  final String price;

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.typography.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(price, style: theme.typography.caption),
        const SizedBox(height: 20.0),
        ...benefits.map((benefit) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsetsDirectional.only(end: 6.0, top: 9.0),
                child: Icon(FluentIcons.circle_fill, size: 4.0),
              ),
              Expanded(child: Text(benefit)),
            ],
          );
        }),
      ],
    );
  }
}
