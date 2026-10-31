import 'package:news_app/models/article_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;

  // singleton, make sure one instance of the database is created
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  final String _bookmarksTableName = 'bookmarks';
  final String _bookmarksIdColumnName = 'id';
  final String _bookmarksNewsBrandColumnName = 'newsBrand';
  final String _bookmarksTitleColumnName = 'title';
  final String _bookmarksAuthorColumnName = 'author';
  final String _bookmarksDateColumnName = 'date';
  final String _bookmarksImageUrlColumnName = 'imageUrl';
  final String _bookmarksArticleColumnName = 'article';
  final String _bookmarksIsBookmarkedColumnName = 'isBookmarked';

  // getter for the database
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'bookmarks.db');
    final database = await openDatabase(databasePath, version: 1,
        onCreate: (db, version) async {
      // the id column holds the article's own id so bookmarks can be matched
      // back to articles
      await db.execute('''
      CREATE TABLE $_bookmarksTableName (
        $_bookmarksIdColumnName INTEGER PRIMARY KEY,
        $_bookmarksNewsBrandColumnName TEXT NOT NULL,
        $_bookmarksTitleColumnName TEXT NOT NULL,
        $_bookmarksAuthorColumnName TEXT NOT NULL,
        $_bookmarksDateColumnName TEXT NOT NULL,
        $_bookmarksImageUrlColumnName TEXT NOT NULL,
        $_bookmarksArticleColumnName TEXT NOT NULL,
        $_bookmarksIsBookmarkedColumnName INTEGER NOT NULL
      )
      ''');
    });
    return database;
  }

  Future<void> addBookMark(Article article) async {
    final db = await database;
    final bookmark = {
      _bookmarksIdColumnName: article.id,
      _bookmarksNewsBrandColumnName: article.newsBrand,
      _bookmarksTitleColumnName: article.title,
      _bookmarksAuthorColumnName: article.author,
      _bookmarksDateColumnName: article.date,
      _bookmarksImageUrlColumnName: article.imageUrl,
      _bookmarksArticleColumnName: article.article,
      _bookmarksIsBookmarkedColumnName: 1
    };
    await db.insert(_bookmarksTableName, bookmark,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Article>> getBookmarks() async {
    final db = await database;
    final data = await db.query(_bookmarksTableName);
    return data
        .map((row) => Article(
              id: row[_bookmarksIdColumnName] as int,
              newsBrand: row[_bookmarksNewsBrandColumnName] as String,
              title: row[_bookmarksTitleColumnName] as String,
              author: row[_bookmarksAuthorColumnName] as String,
              date: row[_bookmarksDateColumnName] as String,
              imageUrl: row[_bookmarksImageUrlColumnName] as String,
              article: row[_bookmarksArticleColumnName] as String,
              isBookmarked: row[_bookmarksIsBookmarkedColumnName] == 1,
            ))
        .toList();
  }

  Future<void> deleteBookMark(int id) async {
    final db = await database;
    await db.delete(_bookmarksTableName,
        where: '$_bookmarksIdColumnName = ?', whereArgs: [id]);
  }
}
