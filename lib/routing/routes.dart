import 'package:flutter/material.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/article/article_screen.dart';
import 'package:news_app/ui/search/search_screen.dart';
import 'package:news_app/ui/shell/app_shell.dart';

abstract final class Routes {
  static const home = '/';
  static const article = '/article';
  static const search = '/search';
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final Widget page = switch (settings.name) {
    Routes.article => ArticleScreen(article: settings.arguments! as Article),
    Routes.search => const SearchScreen(),
    _ => const AppShell(),
  };
  return MaterialPageRoute(builder: (_) => page, settings: settings);
}
