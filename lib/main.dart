import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/routing/routes.dart';

void main() {
  runApp(const ProviderScope(child: ZimNewsApp()));
}

class ZimNewsApp extends StatelessWidget {
  const ZimNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zim News',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      initialRoute: Routes.home,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
