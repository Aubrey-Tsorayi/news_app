import 'package:news_app/domain/models/article.dart';

/// Articles matching every word of [query] in their headline, summary,
/// author or text, best matches first: headline hits rank above body hits,
/// then newer above older. An empty query matches nothing.
///
/// Pure and total, so it is safe to run on every keystroke.
List<Article> searchArticles(List<Article> articles, String query) {
  final terms = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  if (terms.isEmpty) return const [];

  final scored = <(Article, int)>[];
  for (final article in articles) {
    final title = article.title.toLowerCase();
    final rest = [
      article.summary,
      article.author ?? '',
      ...article.paragraphs,
    ].join(' ').toLowerCase();

    var score = 0;
    var matchesAll = true;
    for (final term in terms) {
      if (title.contains(term)) {
        score += 2;
      } else if (rest.contains(term)) {
        score += 1;
      } else {
        matchesAll = false;
        break;
      }
    }
    if (matchesAll) scored.add((article, score));
  }

  scored.sort((a, b) {
    final byScore = b.$2.compareTo(a.$2);
    return byScore != 0
        ? byScore
        : b.$1.publishedAt.compareTo(a.$1.publishedAt);
  });
  return [for (final (article, _) in scored) article];
}
