import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/domain/article_search.dart';
import 'package:news_app/domain/models/article.dart';

Article article(
  String id, {
  required String title,
  String summary = '',
  List<String> paragraphs = const [],
  String? author,
  int hoursAgo = 0,
}) =>
    Article(
      id: id,
      sourceId: 'herald',
      title: title,
      url: id,
      publishedAt: DateTime.utc(2026, 10, 31, 12 - hoursAgo),
      summary: summary,
      paragraphs: paragraphs,
      author: author,
    );

List<String> ids(List<Article> articles) => [for (final a in articles) a.id];

void main() {
  final border = article('border',
      title: 'SA suspends operations at Beitbridge border',
      summary: 'Traffic is expected to rise.');
  final rangers = article('rangers',
      title: 'Young conservation leaders',
      paragraphs: ['Elephants move near the border of Hwange.'],
      hoursAgo: 2);
  final markets = article('markets',
      title: 'Analysts urge selective stock picking',
      author: 'Kudzanai Gerede');
  final all = [border, rangers, markets];

  test('empty or blank query matches nothing', () {
    expect(searchArticles(all, ''), isEmpty);
    expect(searchArticles(all, '   '), isEmpty);
  });

  test('matches title, summary, body and author, ignoring case', () {
    expect(ids(searchArticles(all, 'BEITBRIDGE')), ['border']);
    expect(ids(searchArticles(all, 'traffic')), ['border']);
    expect(ids(searchArticles(all, 'elephants')), ['rangers']);
    expect(ids(searchArticles(all, 'gerede')), ['markets']);
  });

  test('every word must match', () {
    expect(ids(searchArticles(all, 'border elephants')), ['rangers']);
    expect(searchArticles(all, 'border stocks'), isEmpty);
  });

  test('headline matches rank above body matches', () {
    // "border" is in the headline of one and only the body of the other
    expect(ids(searchArticles(all, 'border')), ['border', 'rangers']);
  });

  test('equal matches are ordered newest first', () {
    final older = article('older', title: 'Border update', hoursAgo: 5);
    final newer = article('newer', title: 'Border update', hoursAgo: 1);
    expect(ids(searchArticles([older, newer], 'border update')),
        ['newer', 'older']);
  });
}
