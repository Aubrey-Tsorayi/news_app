import 'package:flutter/material.dart';
import 'package:news_app/config/theme.dart';

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
        Text(heading, style: AppTextStyles.heading),
        Text(subtext, style: AppTextStyles.subtext),
      ],
    );
  }
}
