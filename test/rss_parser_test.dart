import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/data/services/rss_parser.dart';

// Trimmed copies of the real feeds' structure (October 2026).
String feed(String items) => '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"><channel>$items</channel></rss>''';

const heraldItem = '''
<item>
  <title>SA suspends operations at border, Beitbridge braces for traffic</title>
  <link>https://www.heraldonline.co.zw/sa-suspends-operations/</link>
  <dc:creator><![CDATA[Online Reporter]]></dc:creator>
  <pubDate>Sat, 31 Oct 2026 16:07:43 +0000</pubDate>
  <guid isPermaLink="false">https://www.heraldonline.co.zw/?p=5707949</guid>
  <description><![CDATA[Thupeyo Muleya Beitbridge Bureau SOUTH Africa has temporarily suspended operations at Kopfontein…]]></description>
</item>''';

const paywalledItem = '''
<item>
  <title>Analysts urge selective stock picking</title>
  <link>https://fingaz.co.zw/2026/10/31/analysts-urge-selective-stock-picking/</link>
  <dc:creator><![CDATA[Kudzanai Gerede]]></dc:creator>
  <pubDate>Sat, 31 Oct 2026 00:09:00 +0000</pubDate>
  <description><![CDATA[<p>INVESTORS should buy shares.</p>]]></description>
  <content:encoded><![CDATA[<p>INVESTORS should ­selectively buy shares.</p>
    <div class="woocommerce"><div class="woocommerce-info wc-memberships-restriction-message">
    Subscribe to read full article. <a href="https://fingaz.co.zw/subscriptions/">Subscribe today</a></div></div>
    <p>The post <a href="#">Analysts</a> appeared first on <a href="#">The Financial Gazette</a>.</p>]]></content:encoded>
</item>''';

const fullItem = '''
<item>
  <title>Young conservation leaders take action in Zimbabwe&#8217;s parks</title>
  <link>https://www.thezimbabwean.co/2026/10/young-conservation-leaders/</link>
  <pubDate>Sat, 31 Oct 2026 04:32:18 +0200</pubDate>
  <description><![CDATA[IFAW's Room to Roam Nature Clubs have launched across 21 schools [&#8230;]]]></description>
  <content:encoded><![CDATA[<div class="wp-caption"><img src="https://www.thezimbabwean.co/wp-content/uploads/2026/10/rangers.webp" /><p class="wp-caption-text">Caption</p></div>
    <p>For a child growing up near Hwange National Park, wildlife is close.</p>
    <h2><strong>A connected landscape</strong></h2>
    <p>Room to Roam is a long-term initiative.</p>]]></content:encoded>
</item>''';

void main() {
  test('excerpt-only feed is a truncated summary', () {
    final [article] = parseRss(feed(heraldItem), sourceId: 'herald');

    expect(
        article.id, 'https://www.heraldonline.co.zw/sa-suspends-operations/');
    expect(article.author, 'Online Reporter');
    expect(article.summary, startsWith('Thupeyo Muleya'));
    expect(article.paragraphs, isEmpty);
    expect(article.isTruncated, isTrue);
    expect(article.imageUrl, isNull);
    expect(article.publishedAt, DateTime.utc(2026, 10, 31, 16, 7, 43));
  });

  test('paywalled feed drops the subscription notice and footer', () {
    final [article] = parseRss(feed(paywalledItem), sourceId: 'fingaz');

    expect(article.paragraphs, ['INVESTORS should selectively buy shares.']);
    expect(article.isTruncated, isTrue);
  });

  test('full-text feed keeps paragraphs, headings and the image', () {
    final [article] = parseRss(feed(fullItem), sourceId: 'zimbabwean');

    expect(article.title, contains('Zimbabwe’s parks'));
    expect(article.paragraphs, [
      'For a child growing up near Hwange National Park, wildlife is close.',
      'A connected landscape',
      'Room to Roam is a long-term initiative.',
    ]);
    expect(article.imageUrl,
        'https://www.thezimbabwean.co/wp-content/uploads/2026/10/rangers.webp');
    expect(article.isTruncated, isFalse);
    expect(article.summary, endsWith('21 schools…'));
    // +0200 is two hours ahead of UTC
    expect(article.publishedAt, DateTime.utc(2026, 10, 31, 2, 32, 18));
  });

  test('items without a title or link are skipped', () {
    expect(parseRss(feed('<item><title>No link</title></item>'), sourceId: 'x'),
        isEmpty);
  });

  test('parseRfc822 handles GMT and missing seconds', () {
    expect(parseRfc822('Mon, 2 Nov 2026 08:05 GMT'),
        DateTime.utc(2026, 11, 2, 8, 5));
    expect(parseRfc822('not a date'), isNull);
  });
}
