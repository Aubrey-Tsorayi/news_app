import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/screens/app_layout.dart';
import 'package:news_app/screens/article_page.dart';
import 'package:news_app/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Zim News Online',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: "/splash",
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/app': (context) => const AppLayout(),
        '/article': (context) => const ArticlePage(),
      },
    );
  }
}
