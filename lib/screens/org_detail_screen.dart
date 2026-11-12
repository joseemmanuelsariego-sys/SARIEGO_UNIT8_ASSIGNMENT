import 'package:flutter/material.dart';

import '../data/event_repository.dart';
import '../data/fair_data.dart';
import '../data/orgs.dart';
import '../models/registration.dart';
import '../widgets/event_tile.dart';
import '../widgets/org_banner.dart';
import '../widgets/state_message.dart';
import 'join_form_screen.dart';

/// Shows one org in three tabs. Stateless: everything it needs comes in
/// from the parent.
class OrgDetailScreen extends StatelessWidget {
  const OrgDetailScreen({
    super.key,
    required this.org,
    required this.isMember,
    required this.events,
  });

  final Org org;
  final bool isMember;

  /// Where the Events tab gets this org's events (the CMS).
  final EventRepository events;

  Future<void> _join(BuildContext context) async {
    final registration = await Navigator.of(context).push<Registration>(
      MaterialPageRoute(builder: (_) => JoinFormScreen(org: org)),
    );
    if (registration != null && context.mounted) {
      // Pass the registration on to the list screen.
      Navigator.of(context).pop(registration);
    }
  }

  @override
  Widget build(BuildContext context) {
    // length, the number of tabs and the number of children must match.
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(org.acronym),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'About'),
              Tab(icon: Icon(Icons.people_outline), text: 'Officers'),
              Tab(icon: Icon(Icons.event_outlined), text: 'Events'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAbout(context),
            _buildOfficers(),
            OrgEventsTab(orgId: org.id, repository: events),
          ],
        ),
      ),
    );
  }

  Widget _buildAbout(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(aspectRatio: 2, child: OrgBanner(org: org)),
        ),
        const SizedBox(height: 16),
        Text(org.name, style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.category, size: 18, color: colors.primary),
            const SizedBox(width: 4),
            Text(org.category.label, style: textTheme.labelLarge),
            const SizedBox(width: 16),
            Icon(Icons.group, size: 18, color: colors.primary),
            const SizedBox(width: 4),
            Text('${org.members} members', style: textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 16),
        Text(org.description, style: textTheme.bodyLarge),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: isMember ? null : () => _join(context),
            icon: Icon(isMember ? Icons.check : Icons.how_to_reg),
            label: Text(isMember ? 'Already a member' : 'Join ${org.acronym}'),
          ),
        ),
      ],
    );
  }

  Widget _buildOfficers() {
    final officers = officersByOrg[org.id] ?? const <Officer>[];
    return ListView.separated(
      itemCount: officers.length,
      itemBuilder: (context, i) {
        final officer = officers[i];
        return ListTile(
          leading: CircleAvatar(child: Text(officer.name.characters.first)),
          title: Text(officer.name),
          subtitle: Text(officer.role),
        );
      },
      separatorBuilder: (context, i) => const Divider(height: 1),
    );
  }
}

/// The Events tab. Stateful, so the request starts once in initState and
/// not every time the tab is built.
class OrgEventsTab extends StatefulWidget {
  const OrgEventsTab({
    super.key,
    required this.orgId,
    required this.repository,
  });

  final String orgId;
  final EventRepository repository;

  @override
  State<OrgEventsTab> createState() => _OrgEventsTabState();
}

class _OrgEventsTabState extends State<OrgEventsTab> {
  late final Future<EventLoad> _future;

  @override
  void initState() {
    super.initState();
    // TODO 10: Load only this org's events from the CMS:
    // widget.repository.loadForOrg(...) with this tab's org id.
    _future = widget.repository.loadForOrg(widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventLoad>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return StateMessage(icon: Icons.cloud_off, text: '${snapshot.error}');
        }
        final events = snapshot.data!.events;
        if (events.isEmpty) {
          return const Center(child: Text('No events yet.'));
        }
        return ListView(
          children: [
            for (final event in events) EventTile(event: event, showOrg: false),
          ],
        );
      },
    );
  }
}
