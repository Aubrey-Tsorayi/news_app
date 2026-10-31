import 'package:flutter/material.dart';
import 'package:news_app/domain/models/article.dart';
import 'package:news_app/ui/article/article_screen.dart';
import 'package:news_app/ui/shell/app_shell.dart';
import 'package:news_app/ui/splash/splash_screen.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const app = '/app';
  static const article = '/article';
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final Widget page = switch (settings.name) {
    Routes.splash => const SplashScreen(),
    Routes.app => const AppShell(),
    Routes.article => ArticleScreen(article: settings.arguments! as Article),
    _ => const AppShell(),
  };
  return MaterialPageRoute(builder: (_) => page, settings: settings);
}
