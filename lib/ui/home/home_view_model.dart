import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/repositories/article_repository.dart';
import 'package:news_app/domain/models/article.dart';

/// Latest articles from every paper.
///
/// Opens with the articles saved on the device, so the feed appears
/// instantly and works offline, then fetches fresh ones in the background.
class FeedViewModel extends AsyncNotifier<FeedResult> {
  @override
  Future<FeedResult> build() async {
    final repository = ref.watch(articleRepositoryProvider);
    final cached = await repository.getCached();
    if (cached == null) return repository.fetchLatest();

    // after build has returned, so the cached feed is on screen first
    Future(_refreshInBackground);
    return cached;
  }

  Future<void>? _inFlight;

  /// Pull-to-refresh. Keeps showing the current articles if the refresh fails
  /// and rethrows so the screen can tell the reader. Overlapping calls share
  /// one fetch.
  Future<void> refresh() =>
      _inFlight ??= _fetch().whenComplete(() => _inFlight = null);

  Future<void> _fetch() async {
    final result = await AsyncValue.guard(
        () => ref.read(articleRepositoryProvider).fetchLatest());
    final current = state.valueOrNull;
    if (result.hasError && current != null) {
      state = AsyncData(current.copyWith(isOffline: true));
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }
    state = result;
  }

  /// Refreshes when the feed is older than [maxAge], e.g. when the app comes
  /// back to the foreground.
  void refreshIfOlderThan(Duration maxAge) {
    final updatedAt = state.valueOrNull?.updatedAt;
    if (updatedAt == null || DateTime.now().difference(updatedAt) > maxAge) {
      _refreshInBackground();
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      await refresh();
    } catch (_) {
      // refresh has already marked the feed as offline
    }
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
