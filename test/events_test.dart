// Part 3 tests for everyone, whichever CMS you chose. Run: flutter test
// Each test names the TODOs it checks.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:org_fair/data/event_repository.dart';
import 'package:org_fair/data/event_source.dart';
import 'package:org_fair/models/fair_event.dart';
import 'package:org_fair/widgets/event_tile.dart';

import 'helpers.dart';

void main() {
  group('TODO 1: status codes become messages', () {
    test('200 gives the JSON', () {
      expect(decodeOrThrow(http.Response('{"a": 1}', 200), 'X'), {'a': 1});
    });

    for (final (code, words) in [
      (401, 'token'),
      (403, 'token'),
      (404, 'content type'),
      (500, 'Try again later'),
      (503, 'Try again later'),
      (418, 'answered 418'),
    ]) {
      test('$code', () {
        expect(
          () => decodeOrThrow(http.Response('', code), 'Strapi'),
          throwsA(
            isA<CmsException>().having(
              (e) => e.message,
              'message',
              allOf(contains('Strapi'), contains(words)),
            ),
          ),
        );
      });
    }
  });

  test('TODO 4 and 5: a failed load gives the saved copy', () async {
    final source = FakeEventSource();
    final repository = EventRepository(source);

    source.failWith = const CmsException('No connection.');
    await expectLater(
      repository.load(),
      throwsA(isA<CmsException>()),
      reason: 'With nothing saved yet, the error must come through',
    );

    source.failWith = null;
    final first = await repository.load();
    expect(first.savedCopy, isFalse);

    source.failWith = const CmsException('No connection.');
    final second = await repository.load();
    expect(second.savedCopy, isTrue, reason: 'TODO 5');
    expect(second.events, hasLength(first.events.length), reason: 'TODO 4');
  });

  testWidgets("TODO 11: the What's On tab", (tester) async {
    await openApp(tester);
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text("What's On"),
      ),
      findsOneWidget,
    );
    await tapDestination(tester, "What's On");
    expect(find.text('Hour of Code'), findsOneWidget);
  });

  testWidgets('TODO 7 (needs 11): events are sorted by time', (tester) async {
    final source = FakeEventSource([
      FairEvent(
        id: 'b',
        orgId: 'csc',
        title: 'Later',
        startsAt: DateTime.utc(2026, 11, 20),
        venue: 'Lab',
      ),
      FairEvent(
        id: 'a',
        orgId: 'csc',
        title: 'Sooner',
        startsAt: DateTime.utc(2026, 11, 10),
        venue: 'Lab',
      ),
    ]);
    await openApp(tester, source: source);
    await tapDestination(tester, "What's On");
    expect(
      tester.getTopLeft(find.text('Sooner')).dy,
      lessThan(tester.getTopLeft(find.text('Later')).dy),
    );
  });

  testWidgets('TODO 6 (needs 11): pull to refresh loads again', (tester) async {
    final source = FakeEventSource();
    await openApp(tester, source: source);
    await tapDestination(tester, "What's On");
    expect(source.calls, 1);

    // An officer edits the event in the CMS...
    source.events = [
      FairEvent(
        id: 'e1',
        orgId: 'csc',
        title: 'Hour of Code (moved to the gym)',
        startsAt: DateTime.utc(2026, 11, 8, 5),
        venue: 'WVSU Gym',
      ),
    ];
    // ...and the student pulls the list down.
    // (show() does what a pull-down does.)
    tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show();
    await tester.pumpAndSettle();
    expect(source.calls, 2, reason: '_refresh must start a new load');
    expect(find.text('Hour of Code (moved to the gym)'), findsOneWidget);
  });

  testWidgets('TODO 8 (needs 4, 5, 6, 11): offline banner', (tester) async {
    final source = FakeEventSource();
    await openApp(tester, source: source);
    await tapDestination(tester, "What's On");
    expect(find.byType(MaterialBanner), findsNothing);

    source.failWith = const CmsException('No connection.');
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(
      find.text('Hour of Code'),
      findsOneWidget,
      reason: 'The saved events stay on screen',
    );

    source.failWith = null;
    await tester.tap(find.widgetWithText(TextButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);
  });

  testWidgets('TODO 9: cancelled events are marked', (tester) async {
    Future<void> show(bool cancelled) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventTile(
            event: FairEvent(
              id: 'x',
              orgId: 'pixel',
              title: 'Photo Walk',
              startsAt: DateTime.utc(2026, 11, 9, 22),
              venue: 'Calle Real',
              cancelled: cancelled,
            ),
          ),
        ),
      ),
    );

    await show(true);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Photo Walk')).style?.decoration,
      TextDecoration.lineThrough,
    );
    expect(find.byIcon(Icons.event_busy), findsOneWidget);

    await show(false);
    expect(find.text('Cancelled'), findsNothing);
    expect(find.byIcon(Icons.event_busy), findsNothing);
  });

  testWidgets("TODO 10: an org's Events tab shows only its events", (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Computer Science Circle'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'Events'));
    await tester.pumpAndSettle();
    expect(find.text('Hour of Code'), findsOneWidget);
    expect(find.text('Algorithms Study Jam'), findsOneWidget);
    expect(
      find.text('Flutter Workshop'),
      findsNothing,
      reason: 'That one belongs to ITSO',
    );
  });

  test('Given: times from the CMS are shown in local time', () {
    final utc = DateTime.parse('2026-11-08T05:00:00.000Z');
    expect(formatWhen(utc), formatWhen(utc.toLocal()));
  });
}
