import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/config/news_sources.dart';

void main() {
  test('only Daily News and the Financial Gazette need a subscription', () {
    final paid = [
      for (final source in newsSources)
        if (source.isPaid) source.id,
    ];
    expect(paid, ['dailynews', 'fingaz']);
  });

  test('NewsDay is not a source', () {
    expect(newsSources.map((s) => s.name.toLowerCase()),
        isNot(contains('newsday')));
  });

  test('source ids are unique', () {
    final ids = newsSources.map((s) => s.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });
}
