import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Strapi 5 (headless CMS), REST API.
///
/// Collection type: Fair Event
/// API ID: fair-event
/// Endpoint: /api/fair-events
class StrapiEventSource implements EventSource {
  StrapiEventSource(this.client, {required this.baseUrl, this.token = ''});

  final http.Client client;

  /// Your server, e.g. http://localhost:1337 (no slash at the end).
  final String baseUrl;

  /// Empty when the Public role may read fair-events.
  final String token;

  @override
  String get name => 'Strapi';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    // Build the Strapi REST API request.
    final uri = Uri.parse('$baseUrl/api/fair-events').replace(
      queryParameters: {'sort': 'startsAt:asc', 'pagination[pageSize]': '100'},
    );

    // Add authorization only when a token is provided.
    final headers = <String, String>{'Accept': 'application/json'};

    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Request and decode the JSON response.
    final response = await getJson(client, uri, cms: name, headers: headers);

    // Check the response structure.
    if (response is! Map<String, dynamic>) {
      throw CmsException('Strapi returned an invalid response.');
    }

    final data = response['data'];

    if (data is! List) {
      throw CmsException('Strapi did not return a valid events list.');
    }

    // Convert each Strapi document into a FairEvent.
    final events = <FairEvent>[];

    for (final item in data) {
      if (item is! Map) {
        continue;
      }

      // Strapi 5 returns documentId and fields directly in each item.
      final startsAtValue = item['startsAt'];
      final startsAt = DateTime.tryParse(startsAtValue?.toString() ?? '');

      if (startsAt == null) {
        throw CmsException('An event has a missing or invalid start date.');
      }

      events.add(
        FairEvent(
          id: item['documentId']?.toString() ?? '',
          orgId: item['orgId']?.toString() ?? '',
          title: item['title']?.toString() ?? '',
          startsAt: startsAt,
          venue: item['venue']?.toString() ?? '',
          description: item['description']?.toString() ?? '',
          cancelled: item['cancelled'] == true,
        ),
      );
    }

    return events;
  }
}
