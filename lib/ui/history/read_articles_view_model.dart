import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/repositories/reading_history_repository.dart';

/// Ids of the articles the reader has opened.
class ReadArticlesViewModel extends AsyncNotifier<Set<String>> {
  ReadingHistoryRepository get _repository =>
      ref.read(readingHistoryRepositoryProvider);

  @override
  Future<Set<String>> build() {
    return ref.watch(readingHistoryRepositoryProvider).getReadIds();
  }

  /// Saves first, then updates the screen, so the UI never shows a read
  /// marker that wasn't stored.
  Future<void> markRead(String articleId) async {
    if (state.valueOrNull?.contains(articleId) ?? false) return;
    await _repository.markRead(articleId);
    state = AsyncData({...?state.valueOrNull, articleId});
  }
}

final readArticlesViewModelProvider =
    AsyncNotifierProvider<ReadArticlesViewModel, Set<String>>(
        ReadArticlesViewModel.new);

/// Whether one article has been read. Widgets watch this, so marking one
/// article read only rebuilds that article's row.
final isReadProvider = Provider.family<bool, String>((ref, articleId) {
  return ref.watch(readArticlesViewModelProvider
      .select((ids) => ids.valueOrNull?.contains(articleId) ?? false));
});
