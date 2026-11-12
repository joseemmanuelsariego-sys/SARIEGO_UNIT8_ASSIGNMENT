import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

class ContentfulEventSource implements EventSource {
  ContentfulEventSource(
    this.client, {
    required this.spaceId,
    required this.token,
    this.environment = 'master',
  });

  final http.Client client;
  final String spaceId;
  final String token;
  final String environment;

  @override
  String get name => 'Contentful';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    final uri = Uri.https(
      'cdn.contentful.com',
      '/spaces/$spaceId/environments/$environment/entries',
      {'content_type': 'fairEvent', 'order': 'fields.startsAt', 'limit': '100'},
    );

    final headers = <String, String>{'Authorization': 'Bearer $token'};

    final json = await getJson(client, uri, cms: name, headers: headers);

    final data = json as Map<String, dynamic>;
    final items = data['items'];
    print(
      'CONTENTFUL DEBUG: Received ${items is List ? items.length : 0} items',
    );

    if (items is! List) {
      throw CmsException('Invalid Contentful response: items is missing.');
    }

    final events = <FairEvent>[];

    for (final raw in items) {
      if (raw is! Map) continue;

      final item = Map<String, dynamic>.from(raw);

      final sys = item['sys'];
      final fields = item['fields'];

      if (sys is! Map || fields is! Map) continue;

      final systemData = Map<String, dynamic>.from(sys);
      final eventFields = Map<String, dynamic>.from(fields);

      final id = systemData['id']?.toString() ?? '';
      final startsAtValue = eventFields['startsAt'];

      // Skip entries without a valid event date.
      if (startsAtValue is! String) continue;

      final startsAt = DateTime.tryParse(startsAtValue);

      if (startsAt == null) continue;

      events.add(
        FairEvent(
          id: id,
          orgId: eventFields['orgId']?.toString() ?? '',
          title: eventFields['title']?.toString() ?? '',
          startsAt: startsAt,
          venue: eventFields['venue']?.toString() ?? '',
          description: eventFields['description']?.toString() ?? '',
          cancelled: eventFields['cancelled'] == true,
        ),
      );
    }
    print('CONTENTFUL DEBUG: Successfully parsed ${events.length} events');
    return events;
  }
}
