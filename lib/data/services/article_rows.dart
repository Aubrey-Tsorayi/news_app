import 'package:news_app/domain/models/article.dart';

/// Column names and row mapping shared by every table that stores articles
/// (the feed cache and bookmarks).
abstract final class ArticleColumns {
  static const id = 'id';
  static const sourceId = 'source_id';
  static const title = 'title';
  static const url = 'url';
  static const publishedAt = 'published_at';
  static const summary = 'summary';
  static const author = 'author';
  static const content = 'content';
  static const imageUrl = 'image_url';
  static const isTruncated = 'is_truncated';

  /// Column definitions for a CREATE TABLE statement.
  static const definitions = '''
    $id TEXT PRIMARY KEY,
    $sourceId TEXT NOT NULL,
    $title TEXT NOT NULL,
    $url TEXT NOT NULL,
    $publishedAt INTEGER NOT NULL,
    $summary TEXT NOT NULL,
    $author TEXT,
    $content TEXT NOT NULL,
    $imageUrl TEXT,
    $isTruncated INTEGER NOT NULL''';
}

// paragraphs are stored as one text column, separated by blank lines
const _paragraphSeparator = '\n\n';

Map<String, Object?> articleToRow(Article article) => {
      ArticleColumns.id: article.id,
      ArticleColumns.sourceId: article.sourceId,
      ArticleColumns.title: article.title,
      ArticleColumns.url: article.url,
      ArticleColumns.publishedAt: article.publishedAt.millisecondsSinceEpoch,
      ArticleColumns.summary: article.summary,
      ArticleColumns.author: article.author,
      ArticleColumns.content: article.paragraphs.join(_paragraphSeparator),
      ArticleColumns.imageUrl: article.imageUrl,
      ArticleColumns.isTruncated: article.isTruncated ? 1 : 0,
    };

Article articleFromRow(Map<String, Object?> row) {
  final content = row[ArticleColumns.content] as String;
  return Article(
    id: row[ArticleColumns.id] as String,
    sourceId: row[ArticleColumns.sourceId] as String,
    title: row[ArticleColumns.title] as String,
    url: row[ArticleColumns.url] as String,
    publishedAt: DateTime.fromMillisecondsSinceEpoch(
        row[ArticleColumns.publishedAt] as int),
    summary: row[ArticleColumns.summary] as String,
    author: row[ArticleColumns.author] as String?,
    paragraphs: content.isEmpty ? const [] : content.split(_paragraphSeparator),
    imageUrl: row[ArticleColumns.imageUrl] as String?,
    isTruncated: row[ArticleColumns.isTruncated] == 1,
  );
}
