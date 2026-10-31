import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/config/news_sources.dart';
import 'package:news_app/data/services/article_cache.dart';
import 'package:news_app/data/services/feed_service.dart';
import 'package:news_app/data/services/news_database.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/domain/models/news_source.dart';

/// The articles to show, and how fresh they are.
class FeedResult {
  const FeedResult({
    required this.articles,
    this.failedSources = const [],
    this.updatedAt,
    this.isOffline = false,
  });

  final List<Article> articles;

  /// Papers that couldn't be reached on the last fetch. Their earlier
  /// articles are still included from the cache.
  final List<NewsSource> failedSources;

  /// When the feed was last fetched successfully.
  final DateTime? updatedAt;

  /// True when showing cached articles because the latest fetch failed.
  final bool isOffline;

  FeedResult copyWith({bool? isOffline}) => FeedResult(
        articles: articles,
        failedSources: failedSources,
        updatedAt: updatedAt,
        isOffline: isOffline ?? this.isOffline,
      );
}

abstract class ArticleRepository {
  /// Articles saved on the device, or null if there are none yet.
  Future<FeedResult?> getCached();

  /// Fetches every paper, saves the results and returns the up-to-date feed.
  Future<FeedResult> fetchLatest();
}

class FeedArticleRepository implements ArticleRepository {
  FeedArticleRepository(
    this._service,
    this._cache, {
    this.sources = newsSources,
    this.retention = const Duration(days: 7),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final FeedService _service;
  final ArticleCache _cache;
  final List<NewsSource> sources;

  /// How long articles stay in the cache. Bookmarks are stored separately
  /// and kept until the reader removes them.
  final Duration retention;
  final DateTime Function() _now;

  @override
  Future<FeedResult?> getCached() async {
    final articles = await _cache.getAll();
    if (articles.isEmpty) return null;
    return FeedResult(
      articles: articles,
      updatedAt: await _cache.lastFetchedAt(),
    );
  }

  @override
  Future<FeedResult> fetchLatest() async {
    // fetch every paper in parallel; one failing doesn't hide the others
    final results = await Future.wait([
      for (final source in sources)
        _service
            .fetch(source)
            .then<(NewsSource, List<Article>?, Object?)>(
                (articles) => (source, articles, null))
            .catchError((Object error) => (source, null, error)),
    ]);

    final failed = [
      for (final (source, articles, _) in results)
        if (articles == null) source,
    ];
    if (failed.length == sources.length) {
      throw results.first.$3 ?? const FeedException('No sources reachable');
    }

    final now = _now();
    final cutoff = now.subtract(retention);
    final fetched = [
      for (final (_, articles, _) in results)
        for (final article in articles ?? const <Article>[])
          if (article.publishedAt.isAfter(cutoff)) article,
    ];

    await _cache.saveAll(fetched, fetchedAt: now);
    await _cache.deletePublishedBefore(cutoff);

    // read back from the cache so papers that failed this time still show
    // what they published earlier in the week
    return FeedResult(
      articles: await _cache.getAll(),
      failedSources: failed,
      updatedAt: now,
    );
  }
}

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final feedServiceProvider = Provider<FeedService>((ref) {
  return FeedService(ref.watch(httpClientProvider));
});

/// The feed database, shared by the article cache and reading history.
final newsDatabaseProvider = Provider<NewsDatabase>((ref) => NewsDatabase());

final articleCacheProvider = Provider<ArticleCache>(
    (ref) => SqfliteArticleCache(ref.watch(newsDatabaseProvider)));

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return FeedArticleRepository(
    ref.watch(feedServiceProvider),
    ref.watch(articleCacheProvider),
  );
});
