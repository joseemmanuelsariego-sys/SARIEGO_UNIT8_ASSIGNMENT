// Only for students who chose Sanity. Run: flutter test test/sanity_source_test.dart
// (Chose another CMS? Delete this file, or try it for the bonus.)
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:org_fair/data/cms/sanity_source.dart';

/// What the Sanity Query API sends.
final sanityAnswer = jsonEncode({
  'query': SanityEventSource.query,
  'result': [
    {
      '_id': '4f1c-hour-of-code',
      'title': 'Hour of Code',
      'orgId': 'csc',
      'startsAt': '2026-11-08T05:00:00.000Z',
      'venue': 'CICT Lab 2',
      'description': 'No experience needed.',
      'cancelled': false,
    },
    {
      '_id': '9a2b-photo-walk',
      'title': 'Photo Walk',
      'orgId': 'pixel',
      'startsAt': '2026-11-09T22:00:00.000Z',
      'venue': 'Calle Real',
      'description': null,
      'cancelled': true,
    },
    {
      '_id': '7c3d-open-jam',
      'title': 'Open Jam',
      'orgId': 'tunog',
      'startsAt': '2026-11-14T09:00:00.000Z',
      'venue': 'Quadrangle',
      'description': null,
      'cancelled': null,
    },
  ],
  'ms': 4,
});

void main() {
  test('TODO 2 (Sanity): the request', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(sanityAnswer, 200);
    });

    await SanityEventSource(client, projectId: 'zp7mbokg').fetchEvents();
    expect(sent.method, 'GET');
    expect(sent.url.host, 'zp7mbokg.apicdn.sanity.io');
    expect(sent.url.path, '/v2025-02-19/data/query/production');
    expect(sent.url.queryParameters['query'], SanityEventSource.query);
    expect(sent.headers.containsKey('Authorization'), isFalse);

    await SanityEventSource(
      client,
      projectId: 'zp7mbokg',
      dataset: 'fair',
      token: 'sk123',
    ).fetchEvents();
    expect(sent.url.path, '/v2025-02-19/data/query/fair');
    expect(sent.headers['Authorization'], 'Bearer sk123');
  });

  test('TODO 3 (Sanity): the JSON becomes events', () async {
    final client = MockClient(
      (request) async => http.Response(sanityAnswer, 200),
    );
    final events = await SanityEventSource(
      client,
      projectId: 'p',
    ).fetchEvents();

    expect(events, hasLength(3));
    final first = events[0];
    expect(first.id, '4f1c-hour-of-code');
    expect(first.orgId, 'csc');
    expect(first.title, 'Hour of Code');
    expect(first.startsAt, DateTime.utc(2026, 11, 8, 5));
    expect(first.venue, 'CICT Lab 2');
    expect(first.description, 'No experience needed.');
    expect(first.cancelled, isFalse);
    expect(events[1].cancelled, isTrue);
    expect(events[1].description, '');
    expect(events[2].cancelled, isFalse, reason: 'null means not cancelled');
  });
}
