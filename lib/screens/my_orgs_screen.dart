import 'package:flutter/material.dart';

import '../data/orgs.dart';
import '../models/membership.dart';
import '../widgets/state_message.dart';

/// The orgs the student joined. HomeShell owns the data; this screen only
/// shows it and reports taps back through the callbacks.
class MyOrgsScreen extends StatelessWidget {
  const MyOrgsScreen({
    super.key,
    required this.memberships,
    required this.onLeave,
    required this.onBrowse,
  });

  final List<Membership> memberships;
  final ValueChanged<Org> onLeave;

  /// Switches HomeShell back to the Orgs tab.
  final VoidCallback onBrowse;

  Future<void> _confirmLeave(BuildContext context, Org org) async {
    // null when the dialog is closed by tapping outside it.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave ${org.acronym}?'),
        content: Text('You will no longer be a member of ${org.name}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onLeave(org);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('You left ${org.acronym}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orgs')),
      body: memberships.isEmpty
          ? StateMessage(
              icon: Icons.badge_outlined,
              text: "You haven't joined any org yet.",
              action: FilledButton(
                onPressed: onBrowse,
                child: const Text('Browse orgs'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: memberships.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = memberships[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(m.org.acronym.characters.first),
                  ),
                  title: Text(m.org.name),
                  subtitle: Text(
                    '${m.registration.committee.label} committee'
                    ' · ${m.registration.hoursPerWeek} h/week',
                  ),
                  trailing: IconButton(
                    tooltip: 'Leave ${m.org.acronym}',
                    icon: const Icon(Icons.logout),
                    onPressed: () => _confirmLeave(context, m.org),
                  ),
                );
              },
            ),
    );
  }
}
