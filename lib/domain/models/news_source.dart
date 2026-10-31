import 'package:flutter/foundation.dart';

/// A newspaper the app reads from.
@immutable
class NewsSource {
  const NewsSource({
    required this.id,
    required this.name,
    required this.feedUrl,
    required this.logoAsset,
  });

  final String id;
  final String name;
  final String feedUrl;
  final String logoAsset;

  @override
  bool operator ==(Object other) => other is NewsSource && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
