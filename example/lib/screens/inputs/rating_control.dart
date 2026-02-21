import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/code_snippet_card.dart';

class RatingControlPage extends StatefulWidget {
  const RatingControlPage({super.key});

  @override
  State<RatingControlPage> createState() => _RatingControlPageState();
}

class _RatingControlPageState extends State<RatingControlPage> with PageMixin {
  double ratingFirst = 3;
  double ratingSecond = 3;
  double ratingThird = 3;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Rating Control')),
      children: [
        description(
          content: const Text(
            'Use a RatingControl to let users rate content with star icons. '
            'Supports touch, mouse, keyboard, and gamepad interaction.',
          ),
        ),
        subtitle(content: const Text('Simple rating control')),
        description(content: const Text('A rating control with 5 stars.')),
        CodeSnippetCard(
          codeSnippet: '''RatingControl(
  rating: rating,
  onChanged: (v) => setState(() => rating = v),
)''',
          child: RatingControl(
            rating: ratingFirst,
            onChanged: (v) => setState(() => ratingFirst = v),
          ),
        ),
        subtitle(content: const Text('Read-only rating control')),
        description(
          content: const Text(
            'A rating control that shows a fixed rating and does not respond to input.',
          ),
        ),
        const CodeSnippetCard(
          codeSnippet: '''RatingControl(
  rating: 3.5,
  onChanged: null,
)''',
          child: RatingControl(rating: 3.5),
        ),
        subtitle(content: const Text('Custom number of stars')),
        description(content: const Text('A rating control with 10 stars.')),
        CodeSnippetCard(
          codeSnippet: '''RatingControl(
  rating: rating,
  amount: 10,
  onChanged: (v) => setState(() => rating = v),
)''',
          child: RatingControl(
            rating: ratingThird,
            amount: 10,
            onChanged: (v) => setState(() => ratingThird = v),
          ),
        ),
        subtitle(content: const Text('Custom icons')),
        description(
          content: const Text(
            'A rating control using custom icons for rated and unrated states.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''RatingControl(
  rating: rating,
  icon: FluentIcons.heart_fill,
  unratedIcon: FluentIcons.heart,
  onChanged: (v) => setState(() => rating = v),
)''',
          child: RatingControl(
            rating: ratingSecond,
            icon: FluentIcons.heart_fill,
            unratedIcon: FluentIcons.heart,
            onChanged: (v) => setState(() => ratingSecond = v),
          ),
        ),
      ],
    );
  }
}
