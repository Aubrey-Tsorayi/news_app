import 'package:news_app/domain/models/article.dart';

/// Removes stories a paper published more than once under different links
/// (Zimpapers republishes some stories with a "-2" link), keeping the
/// newest copy of each paper's headline.
///
/// Expects [articles] newest first and keeps that order. Pure and total.
List<Article> withoutRepublished(List<Article> articles) {
  final seen = <(String, String)>{};
  return [
    for (final article in articles)
      if (seen.add((article.sourceId, _normalise(article.title)))) article,
  ];
}

String _normalise(String title) =>
    title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
