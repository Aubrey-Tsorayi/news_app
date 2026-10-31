import 'package:flutter/foundation.dart';

/// Whether a paper's full stories are free to read on its website.
enum SourceAccess {
  /// Full stories are free on the paper's site.
  free,

  /// The paper's site asks for a paid subscription for the full story.
  subscription,
}

/// A newspaper the app reads from.
@immutable
class NewsSource {
  const NewsSource({
    required this.id,
    required this.name,
    required this.feedUrl,
    required this.logoAsset,
    required this.access,
  });

  final String id;
  final String name;
  final String feedUrl;
  final String logoAsset;
  final SourceAccess access;

  /// Whether reading the full story on the paper's site needs a subscription.
  bool get isPaid => access == SourceAccess.subscription;

  @override
  bool operator ==(Object other) => other is NewsSource && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
