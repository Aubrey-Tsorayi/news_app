import 'package:flutter/material.dart';
import 'package:news_app/screens/bookmark_page.dart';
import 'package:news_app/screens/home_page.dart';
import 'package:news_app/utilities/colors.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;
  final _pageController = PageController();

  List<Widget> body = [
    HomePage(),
    BookmarkPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: body,
      ),
      // bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        elevation: 20,
        fixedColor: primaryColor,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _pageController.animateToPage(index,
                duration: Duration(microseconds: 500), curve: Curves.easeIn);
          });
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              color: primaryColor,
            ),
            activeIcon: Icon(
              Icons.home,
              color: primaryColor,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bookmarks_outlined,
              color: primaryColor,
            ),
            activeIcon: Icon(
              Icons.bookmarks,
              color: primaryColor,
            ),
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }
}
