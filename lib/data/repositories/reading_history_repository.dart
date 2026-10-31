import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/repositories/article_repository.dart';
import 'package:news_app/data/services/news_database.dart';
import 'package:sqflite/sqflite.dart';

/// Which articles the reader has opened, stored on the device.
abstract class ReadingHistoryRepository {
  /// Ids of articles the reader has opened.
  Future<Set<String>> getReadIds();

  /// Records that [articleId] was opened.
  Future<void> markRead(String articleId);
}

class LocalReadingHistoryRepository implements ReadingHistoryRepository {
  LocalReadingHistoryRepository(
    this._db, {
    this.retention = const Duration(days: 30),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final NewsDatabase _db;

  /// How long read markers are kept. Longer than the feed cache, so saved
  /// articles still show as read for a while after leaving the feed.
  final Duration retention;
  final DateTime Function() _now;

  static const _table = NewsDatabase.readTable;
  static const _id = NewsDatabase.readIdColumn;
  static const _readAt = NewsDatabase.readAtColumn;

  @override
  Future<Set<String>> getReadIds() async {
    final db = await _db.database;
    final cutoff = _now().subtract(retention).millisecondsSinceEpoch;
    await db.delete(_table, where: '$_readAt < ?', whereArgs: [cutoff]);
    final rows = await db.query(_table, columns: [_id]);
    return {for (final row in rows) row[_id]! as String};
  }

  @override
  Future<void> markRead(String articleId) async {
    final db = await _db.database;
    await db.insert(
      _table,
      {_id: articleId, _readAt: _now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

final readingHistoryRepositoryProvider =
    Provider<ReadingHistoryRepository>((ref) {
  return LocalReadingHistoryRepository(ref.watch(newsDatabaseProvider));
});
