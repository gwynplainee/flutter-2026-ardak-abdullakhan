import '../models/session_type.dart';
import '../models/workout_session.dart';


List<WorkoutSession> upcomingOnly(List<WorkoutSession> all) =>
    all.where((s) => !s.isPast).toList();

List<WorkoutSession> favouritesOf(List<WorkoutSession> all) =>
    all.where((s) => s.favourite).toList();

List<WorkoutSession> ofType(List<WorkoutSession> all, SessionType? type) => [
  for (final s in all)
    if (type == null || s.type == type) s,
];

List<WorkoutSession> sortedByDate(List<WorkoutSession> all) =>
    ([...all]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)));

List<String> titlesOf(List<WorkoutSession> all) =>
    all.map((s) => s.title).toList();

int totalJoined(List<WorkoutSession> all) =>
    all.fold(0, (sum, s) => sum + s.count);

bool anyFull(List<WorkoutSession> all) => all.any((s) => s.isFull);

Map<SessionType, int> countByType(List<WorkoutSession> all) => {
  for (final t in SessionType.values)
    t: all.where((s) => s.type == t).length,
};

List<WorkoutSession> withJoined(List<WorkoutSession> all, String name) =>
    all.where((s) => s.contains(name)).toList();

List<WorkoutSession> replaced(
    List<WorkoutSession> all, WorkoutSession updated) =>
    [for (final s in all) s.id == updated.id ? updated : s];