import 'package:flutter/material.dart';
import 'package:news_app/config/theme.dart';

class NoBookmarks extends StatelessWidget {
  const NoBookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.red[300],
            child: const Icon(
              Icons.bookmarks_outlined,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "You haven't saved any articles yet. Start reading and bookmarking them now",
            style: AppTextStyles.emptyState,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
