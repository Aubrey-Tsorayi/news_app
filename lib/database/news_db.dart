import 'package:sqflite/sqflite.dart';
import 'package:news_app/database/database_services.dart';
import 'package:news_app/models/article_model.dart';

class NewsDB {
  final tableName = 'articles';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY,
        newsBrand TEXT,
        title TEXT,
        author TEXT,
        date TEXT,
        imageUrl TEXT,
        article TEXT,
        isBookmarked INTEGER
    );  """);
  }
}