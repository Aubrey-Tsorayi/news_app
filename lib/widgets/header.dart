import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  const HeaderText({
    super.key,
    required this.heading,
    required this.subtext,
  });

  final String heading;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 24,
            fontFamily: "SF Pro Text",
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          width: 400,
          child: Text(
            subtext,
            style: TextStyle(
              fontSize: 16,
              fontFamily: "SF Pro Text",
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
