import '../data/orgs.dart';
import 'registration.dart';

/// One org the student has joined, and the form they sent to join it.
class Membership {
  const Membership({required this.org, required this.registration});

  final Org org;
  final Registration registration;
}
