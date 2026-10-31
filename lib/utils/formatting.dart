const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
  'Sunday',
];

/// "Just now", "5 min ago", "3 h ago", "2 d ago", then "31 Oct".
String timeAgo(DateTime date, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final difference = current.difference(date);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes} min ago';
  if (difference.inDays < 1) return '${difference.inHours} h ago';
  if (difference.inDays < 7) return '${difference.inDays} d ago';
  final local = date.toLocal();
  return '${local.day} ${_monthNames[local.month - 1].substring(0, 3)}';
}

/// [timeAgo] for use mid-sentence: "just now", "5 min ago", "31 Oct".
String timeAgoInline(DateTime date, {DateTime? now}) {
  final text = timeAgo(date, now: now);
  return text == 'Just now' ? 'just now' : text;
}

/// "Saturday, 31 October".
String longDate(DateTime date) {
  final local = date.toLocal();
  return '${_weekdayNames[local.weekday - 1]}, '
      '${local.day} ${_monthNames[local.month - 1]}';
}

/// "31 October 2026, 16:07".
String fullDateTime(DateTime date) {
  final local = date.toLocal();
  final minutes = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_monthNames[local.month - 1]} ${local.year}, '
      '${local.hour}:$minutes';
}
