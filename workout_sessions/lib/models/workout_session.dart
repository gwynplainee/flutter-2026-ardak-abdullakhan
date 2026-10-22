import 'dart:collection';
import 'dart:math' as math;

import 'countdown.dart';
import 'session_type.dart';

class WorkoutSession {
  static const Duration sessionLength = Duration(hours: 1);

  const WorkoutSession({
    required this.id,
    required this.title,
    required this.type,
    required this.scheduledAt,
    required this.maxParticipants,
    required List<String> participants,
    required this.venue,
    this.online = false,
    this.description,
    this.favourite = false,
  })  : _participants = participants,
        assert(maxParticipants >= 1, 'maxParticipants must be >= 1'),
        assert(participants.length <= maxParticipants,
        'more participants than places');

  factory WorkoutSession.empty() {
    final now = DateTime.now();
    return WorkoutSession(
      id: now.microsecondsSinceEpoch.toString(),
      title: '',
      type: SessionType.strength,
      scheduledAt: DateTime(now.year, now.month, now.day + 1, 18, 0),
      maxParticipants: 10,
      participants: const [],
      venue: '',
    );
  }

  final String id;
  final String title; // 3–60 chars
  final SessionType type;
  final DateTime scheduledAt;
  final int maxParticipants;

  final bool online;
  final String venue;

  final String? description;
  final bool favourite;

  final List<String> _participants;


  List<String> get participants => UnmodifiableListView(_participants);


  int get count => _participants.length;
  int get freePlaces => math.max(0, maxParticipants - count);
  bool get isFull => count >= maxParticipants;
  bool get isPast => scheduledAt.isBefore(DateTime.now());
  bool contains(String name) => _participants
      .any((p) => p.toLowerCase() == name.trim().toLowerCase());

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  String get venueLabel => online ? 'Link' : 'Venue';

  List<String> get detailLines => [
    type.label,
    '$venueLabel: $venue',
    if (description case final text?) text,
  ];

  Countdown countdownAt(DateTime now) {
    if (now.isBefore(scheduledAt)) {
      return Upcoming(scheduledAt.difference(now));
    }
    final elapsed = now.difference(scheduledAt);
    return elapsed < sessionLength ? Started(elapsed) : const Ended();
  }

  // ---- Immutable mutations ----

  WorkoutSession join(String name) {
    final clean = name.trim();
    if (clean.isEmpty || isFull || isPast || contains(clean)) return this;
    return copyWith(participants: [..._participants, clean]);
  }

  WorkoutSession leave(String name) => copyWith(
    participants: [
      for (final p in _participants)
        if (p.toLowerCase() != name.trim().toLowerCase()) p,
    ],
  );

  WorkoutSession toggleFavourite() => copyWith(favourite: !favourite);

  WorkoutSession copyWith({
    String? id,
    String? title,
    SessionType? type,
    DateTime? scheduledAt,
    int? maxParticipants,
    List<String>? participants,
    String? venue,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      // later changes to the caller's list can't leak in.
      participants: List<String>.of(participants ?? _participants),
      venue: venue ?? this.venue,
      online: online ?? this.online,
      description: clearDescription ? null : (description ?? this.description),
      favourite: favourite ?? this.favourite,
    );
  }

  // ---- Validation  ----

  static String? validateTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 3) return 'Title must be at least 3 characters';
    if (v.length > 60) return 'Title must be at most 60 characters';
    return null;
  }

  static String? validateVenue(String? value, {required bool online}) {
    final v = value?.trim() ?? '';
    if (online) {
      return v.contains('://') && v.length > 3
          ? null
          : 'Enter a valid link (must contain ://)';
    }
    return v.length >= 2 ? null : 'Enter a venue (at least 2 characters)';
  }

  static String? validateMax(String? value, {int alreadyJoined = 0}) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null) return 'Enter a whole number';
    if (n < 1) return 'At least 1 place';
    if (n < alreadyJoined) return 'Fewer than the $alreadyJoined already joined';
    return null;
  }
}