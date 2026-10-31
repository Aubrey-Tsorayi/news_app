import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/routing/routes.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Zim News Online',
      theme: appTheme,
      initialRoute: Routes.splash,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
