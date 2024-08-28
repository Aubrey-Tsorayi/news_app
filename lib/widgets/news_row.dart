import 'package:flutter/material.dart';

class NewsRow extends StatelessWidget {
  const NewsRow({
    super.key,
    required this.id,
    required this.title,
    required this.newsBrand,
  });

  final int id;
  final String title;
  final String newsBrand;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/article");
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newsBrand,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "SF Pro Text",
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: "SF Pro Text",
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
