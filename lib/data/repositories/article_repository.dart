import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/config/news_sources.dart';
import 'package:news_app/data/services/feed_service.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/domain/models/news_source.dart';

/// The latest articles from every source, plus the sources that couldn't be
/// reached this time.
class FeedResult {
  const FeedResult({required this.articles, this.failedSources = const []});

  final List<Article> articles;
  final List<NewsSource> failedSources;
}

abstract class ArticleRepository {
  Future<FeedResult> fetchLatest();
}

class FeedArticleRepository implements ArticleRepository {
  FeedArticleRepository(this._service, {this.sources = newsSources});

  final FeedService _service;
  final List<NewsSource> sources;

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

    final byId = <String, Article>{
      for (final (_, articles, _) in results)
        for (final article in articles ?? const <Article>[])
          article.id: article,
    };
    final articles = byId.values.toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return FeedResult(articles: articles, failedSources: failed);
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

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return FeedArticleRepository(ref.watch(feedServiceProvider));
});
