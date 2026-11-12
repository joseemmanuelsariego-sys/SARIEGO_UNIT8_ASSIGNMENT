import 'package:flutter/material.dart';

import '../data/orgs.dart';

/// The banner photo on the detail screen.
class OrgBanner extends StatelessWidget {
  const OrgBanner({super.key, required this.org});

  final Org org;

  Widget _placeholder(BuildContext context, IconData icon) => ColoredBox(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Center(child: Icon(icon, size: 48)),
  );

  @override
  Widget build(BuildContext context) {
    // bannerUrl is String?, so copy it to a local variable. After the null
    // check, Dart knows `url` is a String (type promotion).
    final url = org.bannerUrl;
    if (url == null) return _placeholder(context, Icons.groups);
    return Image.network(
      url,
      fit: BoxFit.cover,
      semanticLabel: 'Banner photo of ${org.name}',
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error, stack) =>
          _placeholder(context, Icons.broken_image),
    );
  }
}
