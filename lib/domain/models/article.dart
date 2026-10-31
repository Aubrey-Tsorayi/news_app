import 'package:flutter/foundation.dart';

@immutable
class Article {
  const Article({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.url,
    required this.publishedAt,
    required this.summary,
    this.author,
    this.paragraphs = const [],
    this.imageUrl,
    this.isTruncated = true,
  });

  /// Stable id from the feed (the article's link).
  final String id;
  final String sourceId;
  final String title;
  final String url;
  final DateTime publishedAt;
  final String summary;
  final String? author;

  /// Body text, one entry per paragraph. Empty when the feed only has a
  /// summary.
  final List<String> paragraphs;
  final String? imageUrl;

  /// True when the feed doesn't carry the whole story (excerpt or paywall),
  /// so the reader should continue on the publisher's site.
  final bool isTruncated;

  /// Estimated reading time at ~200 words per minute, at least one minute.
  int get readingMinutes {
    final text = paragraphs.isEmpty ? summary : paragraphs.join(' ');
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return (words / 200).ceil().clamp(1, 999);
  }

  @override
  bool operator ==(Object other) => other is Article && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
