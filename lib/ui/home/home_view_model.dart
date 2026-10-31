import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/repositories/article_repository.dart';
import 'package:news_app/domain/models/article.dart';

/// Latest articles from every paper.
class FeedViewModel extends AsyncNotifier<FeedResult> {
  @override
  Future<FeedResult> build() {
    return ref.watch(articleRepositoryProvider).fetchLatest();
  }

  /// Pull-to-refresh. Keeps showing the current articles if the refresh fails
  /// and rethrows so the screen can tell the reader.
  Future<void> refresh() async {
    final result = await AsyncValue.guard(
        () => ref.read(articleRepositoryProvider).fetchLatest());
    if (result.hasError && state.hasValue) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }
    state = result;
  }
}

final feedViewModelProvider =
    AsyncNotifierProvider<FeedViewModel, FeedResult>(FeedViewModel.new);

/// The source filter chip; null means all papers.
class SelectedSourceNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? sourceId) => state = sourceId;
}

final selectedSourceProvider =
    NotifierProvider<SelectedSourceNotifier, String?>(
        SelectedSourceNotifier.new);

/// Articles for the selected source; only recomputed when the feed or the
/// filter changes.
final visibleArticlesProvider = Provider<AsyncValue<List<Article>>>((ref) {
  final sourceId = ref.watch(selectedSourceProvider);
  return ref.watch(feedViewModelProvider).whenData((feed) => sourceId == null
      ? feed.articles
      : feed.articles
          .where((a) => a.sourceId == sourceId)
          .toList(growable: false));
});
