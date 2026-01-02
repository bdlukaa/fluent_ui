import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/code_snippet_card.dart';

class RatingBarPage extends StatefulWidget {
  const RatingBarPage({super.key});

  @override
  State<RatingBarPage> createState() => _RatingBarPageState();
}

class _RatingBarPageState extends State<RatingBarPage> with PageMixin {
  double ratingFirst = 3;
  double ratingSecond = 3;
  double ratingThird = 3;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Rating Bar')),
      children: [
        description(
          content: const Text(
            'The rating bar allows users to view and set ratings. '
            'It is often used to gather feedback from users.',
          ),
        ),
        subtitle(content: const Text('Simple Rating Bar')),
        description(content: const Text('A simple rating bar with 5 stars.')),
        CodeSnippetCard(
          codeSnippet: '''RatingBar(
  rating: rating,
  onChanged: (v) => setState(() => rating = v),
)''',
          child: RatingBar(
            rating: ratingFirst,
            onChanged: (v) => setState(() => ratingFirst = v),
          ),
        ),
        subtitle(content: const Text('Read Only Rating Bar')),
        description(content: const Text('A rating bar that is read-only.')),
        const CodeSnippetCard(
          codeSnippet: '''RatingBar(
  rating: 3.5,
  onChanged: null,
)''',
          child: RatingBar(rating: 3.5),
        ),
        subtitle(content: const Text('Custom Amount of Stars')),
        description(
          content: const Text('A rating bar with a custom amount of stars.'),
        ),
        CodeSnippetCard(
          codeSnippet: '''RatingBar(
  rating: rating,
  amount: 10,
  onChanged: (v) => setState(() => rating = v),
)''',
          child: RatingBar(
            rating: ratingThird,
            amount: 10,
            onChanged: (v) => setState(() => ratingThird = v),
          ),
        ),
      ],
    );
  }
}
