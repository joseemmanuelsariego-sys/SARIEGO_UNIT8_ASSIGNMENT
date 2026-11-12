// STARTER FILE: given to students as-is.
import '../models/fair_event.dart';
import 'event_source.dart';

/// The events built into the app. Used when you run without --dart-define
/// CMS=..., so the app works before your CMS is ready (and in the tests).
///
/// Times are in UTC, like a CMS sends them. 05:00 UTC is 1:00 PM in the
/// Philippines (UTC+8).
class SampleEventSource implements EventSource {
  SampleEventSource({this.delay = const Duration(seconds: 1)});

  final Duration delay;

  @override
  String get name => 'Built-in sample events';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    await Future<void>.delayed(delay);
    return sampleEvents;
  }
}

final List<FairEvent> sampleEvents = [
  FairEvent(
    id: 'e1',
    orgId: 'csc',
    title: 'Hour of Code',
    startsAt: DateTime.utc(2026, 11, 8, 5),
    venue: 'CICT Lab 2',
    description: 'Your first program in one hour. No experience needed.',
  ),
  FairEvent(
    id: 'e2',
    orgId: 'csc',
    title: 'Algorithms Study Jam',
    startsAt: DateTime.utc(2026, 11, 15, 7),
    venue: 'Library',
  ),
  FairEvent(
    id: 'e3',
    orgId: 'itso',
    title: 'Flutter Workshop',
    startsAt: DateTime.utc(2026, 11, 12, 1),
    venue: 'CICT AVR',
    description: 'Bring a laptop with Flutter installed.',
  ),
  FairEvent(
    id: 'e4',
    orgId: 'robotics',
    title: 'Line Follower Build',
    startsAt: DateTime.utc(2026, 11, 20, 5),
    venue: 'Lab 4',
  ),
  FairEvent(
    id: 'e5',
    orgId: 'ballers',
    title: 'Tryouts',
    startsAt: DateTime.utc(2026, 11, 6, 8),
    venue: 'WVSU Gym',
  ),
  FairEvent(
    id: 'e6',
    orgId: 'shuttle',
    title: 'Beginners Saturday',
    startsAt: DateTime.utc(2026, 11, 9, 0),
    venue: 'WVSU Gym',
  ),
  FairEvent(
    id: 'e7',
    orgId: 'pixel',
    title: 'Photo Walk',
    startsAt: DateTime.utc(2026, 11, 9, 22),
    venue: 'Calle Real',
    description: 'Moved because of the rain. Meet at the CICT lobby.',
    cancelled: true,
  ),
  FairEvent(
    id: 'e8',
    orgId: 'pixel',
    title: 'UI Design Clinic',
    startsAt: DateTime.utc(2026, 11, 17, 6),
    venue: 'CICT Lab 1',
  ),
  FairEvent(
    id: 'e9',
    orgId: 'tunog',
    title: 'Open Jam',
    startsAt: DateTime.utc(2026, 11, 14, 9),
    venue: 'Quadrangle',
  ),
  FairEvent(
    id: 'e10',
    orgId: 'tabang',
    title: 'Barangay Tech Day',
    startsAt: DateTime.utc(2026, 11, 23, 0),
    venue: 'Brgy. Tabuc Suba',
  ),
];
