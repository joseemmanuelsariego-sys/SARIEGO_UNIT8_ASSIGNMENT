import 'package:flutter/material.dart';

import '../data/event_repository.dart';
import '../widgets/event_tile.dart';
import '../widgets/state_message.dart';

/// "What's On": every event of every org, from the CMS.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, required this.repository});

  final EventRepository repository;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // EXPLAIN E6: The request starts in initState, and again only in
  // _refresh. Why not write future: widget.repository.load() inside build()?
  // How many requests would the app send, and when?
  late Future<EventLoad> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.load();
  }

  Future<void> _refresh() async {
    final next = widget.repository.load();
    setState(() {
      _future = next;
    });
    try {
      await next;
    } catch (_) {
      // The FutureBuilder already shows the error.
    }
    // TODO 6: Start a new load, store it in _future with setState (use a
    // block body: setState(() { ... });), then await it so the spinner
    // stays until the answer comes. Wrap the await in try/catch: if it
    // fails, the FutureBuilder already shows the error, so do nothing.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("What's On"),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<EventLoad>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done &&
              !snapshot.hasData) {
            return const StateMessage(
              icon: Icons.hourglass_top,
              text: 'Loading events...',
              showSpinner: true,
            );
          }
          if (snapshot.hasError) {
            return StateMessage(
              icon: Icons.cloud_off,
              text: '${snapshot.error}',
              action: FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            );
          }
          return _buildEvents(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildEvents(EventLoad load) {
    // TODO 7: The CMS may send the events in any order. Make a sorted copy,
    // earliest first: [...load.events]..sort((a, b) => ...compareTo...)
    final events = [...load.events]
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    // EXPLAIN E7: RefreshIndicator calls onRefresh and hides its spinner
    // when the Future it gets back completes. What would the user see if
    // _refresh returned right away, before the CMS answered?
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        // Lets you pull to refresh even when the list is short.
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (load.savedCopy)
            MaterialBanner(
              content: const Text(
                'No connection. Showing the events saved earlier.',
              ),
              actions: [
                TextButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            ),
          // TODO 8: When load.savedCopy is true, show a MaterialBanner at the
          // top: content 'No connection. Showing the events saved earlier.'
          // and one action, a TextButton 'Retry' that calls _refresh.
          // (Use a collection-if inside this list.)
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 120),
              child: StateMessage(
                icon: Icons.event_note,
                text: 'No events yet. Org officers can add them in the CMS.',
              ),
            )
          else
            for (final event in events) EventTile(event: event),
        ],
      ),
    );
  }
}
