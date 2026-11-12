// STARTER FILE: given to students as-is. Build your screens on top of it.
import 'dart:math';

enum OrgCategory {
  academic('Academic'),
  sports('Sports'),
  arts('Arts'),
  service('Service');

  const OrgCategory(this.label);
  final String label;
}

class Org {
  const Org({
    required this.id,
    required this.name,
    required this.acronym,
    required this.category,
    required this.description,
    required this.members,
    this.bannerUrl,
  });

  final String id;
  final String name;
  final String acronym;
  final OrgCategory category;
  final String description;
  final int members;

  /// Some orgs have no banner photo yet, so this can be null.
  final String? bannerUrl;
}

/// What the fake server does. Change it to see every state of your screen.
enum ServerMode { success, empty, error, random }

/// A pretend web service. It waits like a real network call, then returns
/// the orgs, returns an empty list, or throws an error.
class OrgRepository {
  OrgRepository({
    this.mode = ServerMode.success,
    this.delay = const Duration(seconds: 2),
  });

  ServerMode mode;
  final Duration delay;
  final _random = Random();

  Future<List<Org>> fetchOrgs() async {
    await Future<void>.delayed(delay);
    final result = mode == ServerMode.random
        ? ServerMode.values[_random.nextInt(3)]
        : mode;
    return switch (result) {
      ServerMode.error => throw Exception(
        'No connection. Check your internet and try again.',
      ),
      ServerMode.empty => const <Org>[],
      _ => sampleOrgs,
    };
  }
}

const List<Org> sampleOrgs = [
  Org(
    id: 'csc',
    name: 'Computer Science Circle',
    acronym: 'CSC',
    category: OrgCategory.academic,
    description:
        'Study groups, coding contests and tech talks for CS students.',
    members: 120,
    bannerUrl: 'https://picsum.photos/seed/csc/800/400',
  ),
  Org(
    id: 'itso',
    name: 'IT Student Organization',
    acronym: 'ITSO',
    category: OrgCategory.academic,
    description: 'Workshops on networking, web and mobile development.',
    members: 95,
    bannerUrl: 'https://picsum.photos/seed/itso/800/400',
  ),
  Org(
    id: 'robotics',
    name: 'CICT Robotics Club',
    acronym: 'CRC',
    category: OrgCategory.academic,
    description: 'Build robots and join national robotics competitions.',
    members: 40,
  ),
  Org(
    id: 'ballers',
    name: 'CICT Ballers',
    acronym: 'CB',
    category: OrgCategory.sports,
    description: 'Basketball team for intramurals and friendly games.',
    members: 25,
    bannerUrl: 'https://picsum.photos/seed/ballers/800/400',
  ),
  Org(
    id: 'shuttle',
    name: 'Shuttle Smashers',
    acronym: 'SS',
    category: OrgCategory.sports,
    description: 'Badminton club. Beginners welcome every Saturday.',
    members: 32,
  ),
  Org(
    id: 'pixel',
    name: 'Pixel Arts Guild',
    acronym: 'PAG',
    category: OrgCategory.arts,
    description: 'UI design, digital art and photography.',
    members: 58,
    bannerUrl: 'https://picsum.photos/seed/pixel/800/400',
  ),
  Org(
    id: 'tunog',
    name: 'Tunog CICT',
    acronym: 'TC',
    category: OrgCategory.arts,
    description: 'Band and choir. We play at college events.',
    members: 30,
  ),
  Org(
    id: 'tabang',
    name: 'Tabang Volunteers',
    acronym: 'TV',
    category: OrgCategory.service,
    description: 'Teach basic computer skills in Iloilo barangays.',
    members: 64,
    bannerUrl: 'https://picsum.photos/seed/tabang/800/400',
  ),
];
