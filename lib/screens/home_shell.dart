import 'package:flutter/material.dart';

import '../data/event_repository.dart';
import '../data/orgs.dart';
import '../models/membership.dart';
import 'events_screen.dart';
import 'my_orgs_screen.dart';
import 'org_list_screen.dart';
import 'schedule_screen.dart';

/// The app's frame: a NavigationBar with four destinations.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository, required this.events});

  final OrgRepository repository;
  final EventRepository events;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // Part 2: lifted state. The list, My Orgs and Schedule all need it, so it
  // lives in their common parent and goes down with callbacks.
  final Map<String, Membership> _memberships = {};

  void _join(Membership membership) {
    setState(() => _memberships[membership.org.id] = membership);
  }

  void _leave(Org org) {
    setState(() => _memberships.remove(org.id));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      OrgListScreen(
        repository: widget.repository,
        memberships: _memberships,
        onJoined: _join,
        events: widget.events,
      ),
      EventsScreen(repository: widget.events),
      MyOrgsScreen(
        memberships: _memberships.values.toList(),
        onLeave: _leave,
        onBrowse: () => setState(() => _index = 0),
      ),
      ScheduleScreen(joinedIds: _memberships.keys.toSet()),
    ];
    final count = _memberships.length;

    return Scaffold(
      // Part 2: IndexedStack keeps every page (and its State) alive.
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Orgs',
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: "What's On",
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.badge_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.badge),
            ),
            label: 'My Orgs',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
