import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/utils/formatting.dart';

void main() {
  final now = DateTime(2026, 10, 31, 12);

  test('timeAgo', () {
    expect(timeAgo(now, now: now), 'Just now');
    expect(timeAgo(now.subtract(const Duration(minutes: 5)), now: now),
        '5 min ago');
    expect(
        timeAgo(now.subtract(const Duration(hours: 3)), now: now), '3 h ago');
    expect(timeAgo(now.subtract(const Duration(days: 2)), now: now), '2 d ago');
    expect(timeAgo(DateTime(2026, 10, 1), now: now), '1 Oct');
  });

  test('longDate', () {
    expect(longDate(DateTime(2026, 10, 31)), 'Saturday, 31 October');
  });
}
