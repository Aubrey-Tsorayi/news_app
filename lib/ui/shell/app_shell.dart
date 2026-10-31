import 'package:flutter/material.dart';
import 'package:news_app/config/theme.dart';
import 'package:news_app/ui/bookmarks/bookmarks_screen.dart';
import 'package:news_app/ui/home/home_screen.dart';

/// Bottom navigation between the home and bookmarks screens.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [
          HomeScreen(),
          BookmarksScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 20,
        fixedColor: primaryColor,
        currentIndex: _currentIndex,
        // onPageChanged updates the index once the page settles
        onTap: (index) => _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: primaryColor),
            activeIcon: Icon(Icons.home, color: primaryColor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks_outlined, color: primaryColor),
            activeIcon: Icon(Icons.bookmarks, color: primaryColor),
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }
}
