import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/domain/article_search.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/bookmarks/bookmarks_view_model.dart';
import 'package:news_app/ui/home/home_view_model.dart';

/// What the reader has typed into the search box.
class SearchQueryNotifier extends AutoDisposeNotifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQueryNotifier, String>(
        SearchQueryNotifier.new);

/// Search results over this week's cached feed plus saved articles, so
/// search works offline and finds bookmarks that have left the feed.
final searchResultsProvider = Provider.autoDispose<List<Article>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final feed = ref.watch(feedViewModelProvider).valueOrNull?.articles ??
      const <Article>[];
  final saved =
      ref.watch(bookmarksViewModelProvider).valueOrNull ?? const <Article>[];

  // a saved article may also still be in the feed; keep one copy
  final pool = {
    for (final a in [...saved, ...feed]) a.id: a
  }.values.toList();
  return searchArticles(pool, query);
});
