import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Opened by name from the drawer: Navigator.pushNamed(context, '/about').
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const routeName = '/about';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About the fair')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.tertiary],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Icon(
                    Icons.celebration,
                    size: 56,
                    color: colors.onPrimary,
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Text(
                    'CICT Org Fair 2026',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.event),
            title: Text('November 5, 2026'),
            subtitle: Text('8:00 AM to 3:00 PM'),
          ),
          const ListTile(
            leading: Icon(Icons.place),
            title: Text('CICT Building lobby'),
            subtitle: Text(
              'West Visayas State University, La Paz, Iloilo City',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
              'Visit the booths, meet the officers, and join an org '
              'right from this app.',
            ),
          ),
          const Divider(),
          const VersionTile(),
        ],
      ),
    );
  }
}

class VersionTile extends StatelessWidget {
  const VersionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Loading version...'),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version unavailable'),
          );
        }

        final packageInfo = snapshot.data!;

        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(
            'Version ${packageInfo.version} '
            '(build ${packageInfo.buildNumber})',
          ),
        );
      },
    );
  }
}
