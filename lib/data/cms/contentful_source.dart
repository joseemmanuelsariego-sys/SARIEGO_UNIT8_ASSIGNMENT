import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Contentful (hosted headless CMS), Content Delivery API.
///
/// Content model: "Fair Event" with the API identifier fairEvent.
/// Fields (field ID: type): title: Short text, orgId: Short text,
/// startsAt: Date and time, venue: Short text, description: Long text,
/// cancelled: Boolean.
///
/// Contentful answers:
/// { "sys": { "type": "Array" }, "total": 9, "skip": 0, "limit": 100,
///   "items": [ { "sys": { "id": "3xYz...", "type": "Entry", ... },
///                "fields": { "title": "Hour of Code", "orgId": "csc",
///                            "startsAt": "2026-11-08T13:00+08:00",
///                            "venue": "CICT Lab 2" } } ] }
/// A field left empty is not sent at all, so fields['description'] is null.
class ContentfulEventSource implements EventSource {
  ContentfulEventSource(
    this.client, {
    required this.spaceId,
    required this.token,
    this.environment = 'master',
  });

  final http.Client client;
  final String spaceId;

  /// The Content Delivery API access token (read-only, published entries).
  /// Never the Content Management token.
  final String token;
  final String environment;

  @override
  String get name => 'Contentful';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    // TODO 2 (Contentful): Build the request.

    //   URL:     https://cdn.contentful.com/spaces/$spaceId/environments/$environment/entries
    //   Query:   content_type=fairEvent, order=fields.startsAt, limit=100
    //            (Uri.https(host, path, {...}) builds it for you)
    //   Headers: 'Authorization': 'Bearer $token'
    final uri = Uri.https(
      'cdn.contentful.com',
      '/spaces/$spaceId/environments/$environment/entries',
      {'content_type': 'fairEvent', 'order': 'fields.startsAt', 'limit': '100'},
    );
    final headers = <String, String>{'Authorization': 'Bearer $token'};
    // EXPLAIN E3: Open one of the other two CMS files and compare. Which
    // lines differ, and which are the same? Why is the parsing the part
    // that changes most from one CMS to another?
    final json = await getJson(client, uri, cms: name, headers: headers);

    // TODO 3 (Contentful): Turn the JSON into a List<FairEvent>.
    //   The list is in json['items']. The id is in item['sys']['id'];
    //   everything else is in item['fields'].
    //   Empty fields are missing: use ?? '' and ?? false.
    final items = (json as Map<String, dynamic>)['items'] as List<dynamic>;
    final events = <FairEvent>[];
    for (final raw in items) {
      final item = raw as Map<String, dynamic>;
      final sys = item['sys'] as Map<String, dynamic>;
      final fields = item['fields'] as Map<String, dynamic>;
      events.add(
        FairEvent(
          id: sys['id'] as String,
          orgId: fields['orgId'] as String,
          title: fields['title'] as String,
          startsAt: DateTime.parse(fields['startsAt'] as String),
          venue: fields['venue'] as String,
          description: (fields['description'] as String?) ?? '',
          cancelled: (fields['cancelled'] as bool?) ?? false,
        ),
      );
    }
    return events;
  }
}
