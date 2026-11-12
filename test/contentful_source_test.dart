// Only for students who chose Contentful.
// Run: flutter test test/contentful_source_test.dart
// (Chose another CMS? Delete this file, or try it for the bonus.)
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:org_fair/data/cms/contentful_source.dart';

/// What the Content Delivery API sends for GET .../entries?content_type=fairEvent
final contentfulAnswer = jsonEncode({
  'sys': {'type': 'Array'},
  'total': 3,
  'skip': 0,
  'limit': 100,
  'items': [
    {
      'metadata': {'tags': <Object>[]},
      'sys': {
        'space': {
          'sys': {'type': 'Link', 'linkType': 'Space', 'id': 'abc123'},
        },
        'id': '3xYzHourOfCode',
        'type': 'Entry',
        'createdAt': '2026-10-30T01:00:00.000Z',
        'updatedAt': '2026-10-30T01:00:00.000Z',
        'revision': 1,
        'contentType': {
          'sys': {'type': 'Link', 'linkType': 'ContentType', 'id': 'fairEvent'},
        },
        'locale': 'en-US',
      },
      'fields': {
        'title': 'Hour of Code',
        'orgId': 'csc',
        'startsAt': '2026-11-08T13:00+08:00',
        'venue': 'CICT Lab 2',
        'description': 'No experience needed.',
        'cancelled': false,
      },
    },
    {
      'sys': {'id': '5PhotoWalk', 'type': 'Entry'},
      'fields': {
        'title': 'Photo Walk',
        'orgId': 'pixel',
        'startsAt': '2026-11-10T06:00+08:00',
        'venue': 'Calle Real',
        'cancelled': true,
      },
    },
    {
      'sys': {'id': '7OpenJam', 'type': 'Entry'},
      'fields': {
        'title': 'Open Jam',
        'orgId': 'tunog',
        'startsAt': '2026-11-14T17:00+08:00',
        'venue': 'Quadrangle',
      },
    },
  ],
});

void main() {
  test('TODO 2 (Contentful): the request', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(contentfulAnswer, 200);
    });

    await ContentfulEventSource(
      client,
      spaceId: 'abc123',
      token: 'delivery-token',
    ).fetchEvents();
    expect(sent.method, 'GET');
    expect(sent.url.host, 'cdn.contentful.com');
    expect(sent.url.path, '/spaces/abc123/environments/master/entries');
    expect(sent.url.queryParameters['content_type'], 'fairEvent');
    expect(sent.url.queryParameters['order'], 'fields.startsAt');
    expect(sent.headers['Authorization'], 'Bearer delivery-token');
  });

  test('TODO 3 (Contentful): the JSON becomes events', () async {
    final client = MockClient(
      (request) async => http.Response(contentfulAnswer, 200),
    );
    final events = await ContentfulEventSource(
      client,
      spaceId: 'abc123',
      token: 't',
    ).fetchEvents();

    expect(events, hasLength(3));
    final first = events[0];
    expect(first.id, '3xYzHourOfCode');
    expect(first.orgId, 'csc');
    expect(first.title, 'Hour of Code');
    // 13:00 in UTC+8 is 05:00 UTC.
    expect(first.startsAt.toUtc(), DateTime.utc(2026, 11, 8, 5));
    expect(first.venue, 'CICT Lab 2');
    expect(first.description, 'No experience needed.');
    expect(first.cancelled, isFalse);
    expect(events[1].cancelled, isTrue);
    expect(events[1].description, '', reason: 'A missing field means empty');
    expect(events[2].cancelled, isFalse, reason: 'A missing field means false');
  });
}
