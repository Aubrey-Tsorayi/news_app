import 'package:flutter/material.dart';

const Color primaryColor = Colors.red;

const _fontFamily = 'SF Pro Text';

final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: _fontFamily,
);

/// Text styles shared across screens, defined once instead of per widget.
abstract final class AppTextStyles {
  static const heading = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  static const sectionTitle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const articleTitle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const cardTitle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18);
  static const rowTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const author = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const emptyState =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const chip = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  static final subtext = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey[600]);
  static final rowBrand = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey[500]);
  static final body = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey[600]);
}
