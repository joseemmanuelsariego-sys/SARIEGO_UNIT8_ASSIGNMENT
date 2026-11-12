import 'package:flutter/material.dart';

import '../data/orgs.dart';

class OrgCard extends StatelessWidget {
  const OrgCard({
    super.key,
    required this.org,
    required this.isFavorite,
    required this.isMember,
    required this.onTap,
    required this.onLongPress,
  });

  final Org org;
  final bool isFavorite;
  final bool isMember;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text(org.acronym.characters.first)),
        title: Text(org.name),
        subtitle: Text('${org.category.label} · ${org.members} members'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMember) const Chip(label: Text('Joined')),
            Icon(
              isFavorite ? Icons.star : Icons.star_border,
              semanticLabel: isFavorite ? 'Favorite' : 'Not favorite',
            ),
          ],
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
