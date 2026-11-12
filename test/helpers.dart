// Shared by the tests. Not a test file itself.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_fair/data/event_repository.dart';
import 'package:org_fair/data/event_source.dart';
import 'package:org_fair/data/orgs.dart';
import 'package:org_fair/data/sample_events.dart';
import 'package:org_fair/main.dart';
import 'package:org_fair/models/fair_event.dart';

/// A pretend CMS. The test decides what it answers next.
class FakeEventSource implements EventSource {
  FakeEventSource([List<FairEvent>? events]) : events = events ?? sampleEvents;

  List<FairEvent> events;

  /// When set, the next fetches throw this.
  CmsException? failWith;
  int calls = 0;

  @override
  String get name => 'Fake CMS';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (failWith case final error?) throw error;
    return events;
  }
}

OrgRepository orgRepo() =>
    OrgRepository(delay: const Duration(milliseconds: 100));

/// Opens the app on an 800 x 2400 screen so every form field fits.
Future<void> openApp(WidgetTester tester, {EventSource? source}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    OrgFairApp(
      repository: orgRepo(),
      events: EventRepository(source ?? FakeEventSource()),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump();
}

Future<void> tapDestination(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}
