import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Sanity (hosted headless CMS), HTTP Query API with GROQ.
///
/// Schema type in your Studio: name 'fairEvent', fields title (string),
/// orgId (string), startsAt (datetime), venue (string),
/// description (text), cancelled (boolean).
class SanityEventSource implements EventSource {
  SanityEventSource(
    this.client, {
    required this.projectId,
    this.dataset = 'production',
    this.token = '',
  });

  final http.Client client;
  final String projectId;
  final String dataset;

  /// Empty when the dataset is public.
  final String token;

  /// All fairEvent documents, ordered by start date.
  static const query =
      '*[_type == "fairEvent"] | order(startsAt asc) '
      '{_id, title, orgId, startsAt, venue, description, cancelled}';

  @override
  String get name => 'Sanity';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    // Build the Sanity API request.
    final uri = Uri.https(
      '$projectId.apicdn.sanity.io',
      '/v2025-02-19/data/query/$dataset',
      {'query': query},
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
      throw CmsException('Sanity returned an invalid response.');
    }

    final result = response['result'];

    if (result is! List) {
      throw CmsException('Sanity did not return a valid events list.');
    }

    // Convert each Sanity document into a FairEvent.
    final events = <FairEvent>[];

    for (final item in result) {
      if (item is! Map) {
        continue;
      }

      final startsAtValue = item['startsAt'];
      final startsAt = DateTime.tryParse(startsAtValue?.toString() ?? '');

      if (startsAt == null) {
        throw CmsException('An event has a missing or invalid start date.');
      }

      events.add(
        FairEvent(
          id: item['_id']?.toString() ?? '',
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
