import 'package:flutter/foundation.dart';

@immutable
class Article {
  const Article({
    required this.id,
    required this.newsBrand,
    required this.title,
    required this.author,
    required this.date,
    required this.imageUrl,
    required this.article,
  });

  final int id;
  final String newsBrand;
  final String title;
  final String author;
  final String date;
  final String imageUrl;
  final String article;

  // articles are identified by id, so lookups in sets and lists stay cheap
  @override
  bool operator ==(Object other) => other is Article && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
