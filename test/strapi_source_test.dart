// Only for students who chose Strapi. Run: flutter test test/strapi_source_test.dart
// (Chose another CMS? Delete this file, or try it for the bonus.)
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:org_fair/data/cms/strapi_source.dart';

/// What Strapi 5 sends for GET /api/fair-events.
final strapiAnswer = jsonEncode({
  'data': [
    {
      'id': 4,
      'documentId': 'k7f2a9',
      'title': 'Hour of Code',
      'orgId': 'csc',
      'startsAt': '2026-11-08T05:00:00.000Z',
      'venue': 'CICT Lab 2',
      'description': 'No experience needed.',
      'cancelled': false,
      'createdAt': '2026-10-30T01:00:00.000Z',
      'updatedAt': '2026-10-30T01:00:00.000Z',
      'publishedAt': '2026-10-30T01:00:00.000Z',
    },
    {
      'id': 6,
      'documentId': 'p3m8q1',
      'title': 'Photo Walk',
      'orgId': 'pixel',
      'startsAt': '2026-11-09T22:00:00.000Z',
      'venue': 'Calle Real',
      'description': null,
      'cancelled': true,
      'publishedAt': '2026-10-30T01:00:00.000Z',
    },
    {
      'id': 8,
      'documentId': 'z9r2t5',
      'title': 'Open Jam',
      'orgId': 'tunog',
      'startsAt': '2026-11-14T09:00:00.000Z',
      'venue': 'Quadrangle',
      'description': null,
      'cancelled': null,
      'publishedAt': '2026-10-30T01:00:00.000Z',
    },
  ],
  'meta': {
    'pagination': {'page': 1, 'pageSize': 100, 'pageCount': 1, 'total': 3},
  },
});

void main() {
  test('TODO 2 (Strapi): the request', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(strapiAnswer, 200);
    });

    await StrapiEventSource(
      client,
      baseUrl: 'http://localhost:1337',
      token: 'abc123',
    ).fetchEvents();
    expect(sent.method, 'GET');
    expect(sent.url.path, '/api/fair-events');
    expect(sent.url.queryParameters['sort'], 'startsAt:asc');
    expect(sent.url.queryParameters['pagination[pageSize]'], '100');
    expect(sent.headers['Authorization'], 'Bearer abc123');

    await StrapiEventSource(
      client,
      baseUrl: 'http://localhost:1337',
    ).fetchEvents();
    expect(
      sent.headers.containsKey('Authorization'),
      isFalse,
      reason: 'No token, no Authorization header',
    );
  });

  test('TODO 3 (Strapi): the JSON becomes events', () async {
    final client = MockClient(
      (request) async => http.Response(strapiAnswer, 200),
    );
    final events = await StrapiEventSource(
      client,
      baseUrl: 'http://localhost:1337',
    ).fetchEvents();

    expect(events, hasLength(3));
    final first = events[0];
    expect(first.id, 'k7f2a9');
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
