/// The committees a new member can choose. An enhanced enum (5.1):
/// each value carries its own label.
enum Committee {
  events('Events'),
  logistics('Logistics'),
  media('Media'),
  finance('Finance');

  const Committee(this.label);
  final String label;
}

/// What the join form sends back when a student signs up.
/// Immutable: every field is final and set once in the constructor.
class Registration {
  const Registration({
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.yearLevel,
    required this.committee,
    required this.hoursPerWeek,
    required this.wantsUpdates,
  });

  final String fullName;
  final String email;
  final String studentId;
  final int yearLevel;
  final Committee committee;
  final int hoursPerWeek;
  final bool wantsUpdates;
}
