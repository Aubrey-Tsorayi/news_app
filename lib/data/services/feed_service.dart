import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:news_app/data/services/rss_parser.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/domain/models/news_source.dart';

class FeedException implements Exception {
  const FeedException(this.message);

  final String message;

  @override
  String toString() => 'FeedException: $message';
}

/// Downloads a newspaper's RSS feed and parses it off the UI thread.
class FeedService {
  FeedService(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 15);
  static const _headers = {
    'Accept': 'application/rss+xml, application/xml;q=0.9, */*;q=0.8',
    'User-Agent':
        'ZimNews/1.0 (Android; +https://github.com/Aubrey-Tsorayi/news_app)',
  };

  Future<List<Article>> fetch(NewsSource source) async {
    final response = await _client
        .get(Uri.parse(source.feedUrl), headers: _headers)
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw FeedException('${source.name} returned ${response.statusCode}');
    }
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    final sourceId = source.id;
    // XML and HTML parsing is the heaviest work in the app; keep it off the
    // UI isolate so scrolling stays smooth
    return Isolate.run(() => parseRss(body, sourceId: sourceId));
  }
}
