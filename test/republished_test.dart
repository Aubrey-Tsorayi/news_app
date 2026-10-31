import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/domain/republished.dart';

Article article(String id, String sourceId, String title, int hoursAgo) =>
    Article(
      id: id,
      sourceId: sourceId,
      title: title,
      url: id,
      publishedAt: DateTime.utc(2026, 10, 31, 12 - hoursAgo),
      summary: '',
    );

void main() {
  test('keeps the newest copy of a republished story', () {
    final newer = article('bonus-2', 'sundaymail', 'Civil servants bonus', 3);
    final older = article('bonus', 'sundaymail', 'Civil servants bonus', 4);
    expect(withoutRepublished([newer, older]), [newer]);
  });

  test('ignores case and spacing differences in the headline', () {
    final a = article('a', 'herald', 'Border  reopens', 1);
    final b = article('b', 'herald', 'border reopens ', 2);
    expect(withoutRepublished([a, b]), [a]);
  });

  test('the same headline from different papers is kept', () {
    final herald = article('h', 'herald', 'Budget presented', 1);
    final daily = article('d', 'dailynews', 'Budget presented', 2);
    expect(withoutRepublished([herald, daily]), [herald, daily]);
  });
}
