/// One event of an org, as the app uses it. Every CMS sends its own JSON
/// shape; each source turns that shape into this one class.
class FairEvent {
  const FairEvent({
    required this.id,
    required this.orgId,
    required this.title,
    required this.startsAt,
    required this.venue,
    this.description = '',
    this.cancelled = false,
  });

  /// The id the CMS gave the entry.
  final String id;

  /// Which org runs it: 'csc', 'itso', ... (the ids in orgs.dart).
  final String orgId;
  final String title;
  final DateTime startsAt;
  final String venue;
  final String description;

  /// Officers tick this in the CMS when an event is called off.
  final bool cancelled;
}
