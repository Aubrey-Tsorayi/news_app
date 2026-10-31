import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/routing/routes.dart';
import 'package:news_app/ui/bookmarks/bookmarks_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // start loading bookmarks while the splash is showing
    ref.read(bookmarksViewModelProvider);
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      // replace the splash so it isn't kept in memory or reachable with Back
      Navigator.pushReplacementNamed(context, Routes.app);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(
        child: Image(
          image: AssetImage("assets/images/Splash_Screen_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
