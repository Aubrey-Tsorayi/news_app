import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:news_app/domain/models/article.dart';
import 'package:xml/xml.dart';

/// Turns a WordPress-style RSS 2.0 feed into [Article]s. Pure Dart with no
/// I/O, so it can run on a background isolate and be unit tested.
List<Article> parseRss(String xml, {required String sourceId}) {
  final document = XmlDocument.parse(xml);
  return [
    for (final item in document.findAllElements('item'))
      if (_parseItem(item, sourceId) case final article?) article,
  ];
}

const _summaryLength = 280;

// removed before reading the body: subscription notices, scripts, captions
const _noiseSelector = '.woocommerce, .wc-memberships-restriction-message, '
    'script, style, figure, .wp-caption, iframe';

Article? _parseItem(XmlElement item, String sourceId) {
  final title = _decode(_text(item, 'title'));
  final link = _text(item, 'link').trim();
  if (title.isEmpty || link.isEmpty) return null;

  final description = html.parseFragment(_text(item, 'description'));
  final contentHtml = _text(item, 'content:encoded');
  final content = contentHtml.isEmpty ? null : html.parseFragment(contentHtml);

  final paywalled =
      _isPaywalled(description) || (content != null && _isPaywalled(content));
  final imageUrl = _mediaImage(item) ??
      (content != null ? _firstImage(content) : null) ??
      _firstImage(description);

  final paragraphs = content != null ? _paragraphs(content) : const <String>[];
  final summarySource = _paragraphs(description);
  final summary = _shorten(
    summarySource.isNotEmpty ? summarySource.join(' ') : paragraphs.join(' '),
  );

  return Article(
    id: link,
    sourceId: sourceId,
    title: title,
    url: link,
    publishedAt: parseRfc822(_text(item, 'pubDate')) ?? DateTime.now(),
    summary: summary,
    author: _nonEmpty(_decode(_text(item, 'dc:creator'))),
    paragraphs: paragraphs,
    imageUrl: imageUrl,
    // without content:encoded the feed only carries an excerpt
    isTruncated: content == null || paywalled,
  );
}

String _text(XmlElement item, String name) =>
    item.getElement(name)?.innerText.trim() ?? '';

String? _nonEmpty(String value) => value.isEmpty ? null : value;

/// Decodes HTML entities such as `&#8217;` that WordPress leaves in titles.
String _decode(String value) => value.contains('&')
    ? html.parseFragment(value).text?.trim() ?? value
    : value;

bool _isPaywalled(dom.DocumentFragment fragment) =>
    fragment.querySelector('.wc-memberships-restriction-message') != null;

String? _mediaImage(XmlElement item) {
  for (final name in const ['media:content', 'media:thumbnail', 'enclosure']) {
    final element = item.getElement(name);
    final url = element?.getAttribute('url');
    final type = element?.getAttribute('type');
    if (url != null && (type == null || type.startsWith('image/'))) return url;
  }
  return null;
}

String? _firstImage(dom.DocumentFragment fragment) {
  for (final img in fragment.querySelectorAll('img')) {
    final src = img.attributes['data-src'] ?? img.attributes['src'];
    if (src != null && src.startsWith('http')) return src;
  }
  return null;
}

List<String> _paragraphs(dom.DocumentFragment fragment) {
  final clean = fragment.clone(true);
  for (final noise in clean.querySelectorAll(_noiseSelector)) {
    noise.remove();
  }
  final blocks = clean.querySelectorAll('p, h2, h3, h4, li');
  final texts = blocks.isEmpty
      ? [clean.text ?? '']
      : [for (final block in blocks) block.text];
  return [
    for (final text in texts)
      if (_tidy(text) case final t when t.isNotEmpty && !_isFeedFooter(t)) t,
  ];
}

String _tidy(String text) => text
    .replaceAll('­', '') // soft hyphens
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll(RegExp(r'\s*\[(…|&hellip;|\.\.\.)\]$'), '…')
    .trim();

// "The post X appeared first on Y."
bool _isFeedFooter(String text) =>
    text.startsWith('The post ') && text.contains('appeared first on');

String _shorten(String text) {
  if (text.length <= _summaryLength) return text;
  final cut = text.lastIndexOf(' ', _summaryLength);
  return '${text.substring(0, cut > 0 ? cut : _summaryLength)}…';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

final _rfc822 = RegExp(
  r'(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?'
  r'\s*([+-]\d{4}|GMT|UTC|UT|Z)?',
);

/// Parses RSS dates like `Sat, 31 Oct 2026 16:07:43 +0000` into UTC.
DateTime? parseRfc822(String value) {
  final match = _rfc822.firstMatch(value);
  if (match == null) return null;
  final month = _months.indexOf(_capitalise(match[2]!)) + 1;
  if (month == 0) return null;

  var date = DateTime.utc(
    int.parse(match[3]!),
    month,
    int.parse(match[1]!),
    int.parse(match[4]!),
    int.parse(match[5]!),
    int.parse(match[6] ?? '0'),
  );
  final zone = match[7];
  if (zone != null && (zone.startsWith('+') || zone.startsWith('-'))) {
    final minutes =
        int.parse(zone.substring(1, 3)) * 60 + int.parse(zone.substring(3));
    date = date
        .subtract(Duration(minutes: zone.startsWith('-') ? -minutes : minutes));
  }
  return date;
}

String _capitalise(String s) =>
    s[0].toUpperCase() + s.substring(1).toLowerCase();
