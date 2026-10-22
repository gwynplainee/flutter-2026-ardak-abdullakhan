import '../models/countdown.dart';
import '../models/workout_session.dart';

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDateTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_months[d.month - 1]}, $hh:$mm';
}

String formatDuration(Duration d) {
  final days = d.inDays;
  final hours = d.inHours % 24;
  final minutes = d.inMinutes % 60;
  if (days > 0) return '${days}d ${hours}h';
  if (d.inHours > 0) return '${d.inHours}h ${minutes.toString().padLeft(2, '0')}min';
  return '$minutes min';
}

String formatPlaces(WorkoutSession s) {
  final (:taken, :free) = s.places;
  return '$taken / ${s.maxParticipants} joined · '
      '${free == 0 ? 'full' : '$free free'}';
}

String describeCountdown(Countdown c) => switch (c) {
  Upcoming(:final remaining) => 'Starts in ${formatDuration(remaining)}',
  Started(:final elapsed) => 'Started ${formatDuration(elapsed)} ago',
  Ended() => 'Ended',
};

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';