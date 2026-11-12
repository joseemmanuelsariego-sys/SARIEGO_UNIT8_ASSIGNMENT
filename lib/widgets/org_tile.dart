import 'package:flutter/material.dart';

import '../data/orgs.dart';
import 'org_banner.dart';

/// One org in the grid view: banner on top, name below.
class OrgTile extends StatelessWidget {
  const OrgTile({
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
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stack: the star and the Joined label sit on top of the banner.
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  OrgBanner(org: org),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black54,
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        size: 18,
                        color: Colors.white,
                        semanticLabel: isFavorite ? 'Favorite' : 'Not favorite',
                      ),
                    ),
                  ),
                  if (isMember)
                    const Positioned(
                      left: 4,
                      bottom: 4,
                      child: Chip(
                        label: Text('Joined'),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(org.acronym, style: textTheme.titleMedium),
                  Text(
                    org.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
