import 'package:flutter/material.dart';

class NoBookmarks extends StatelessWidget {
  const NoBookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            width: 400,
            child: Text(
              "You haven't saved any articles yet. Start reading and bookmarking them now",
              style: TextStyle(
                fontSize: 16,
                fontFamily: "SF Pro Text",
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
