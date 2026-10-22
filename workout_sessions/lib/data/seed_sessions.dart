import '../models/session_type.dart';
import '../models/workout_session.dart';

const List<String> _pool = [
  'Aigerim', 'Dana', 'Madi', 'Alina', 'Timur', 'Sofia', 'Ruslan', 'Aliya',
  'Nurlan', 'Kamila', 'Arman', 'Zhanna', 'Dias', 'Mira', 'Yerlan', 'Laura',
];

List<WorkoutSession> buildSeedSessions(DateTime now) {
  DateTime at(int days, int h, int m) =>
      DateTime(now.year, now.month, now.day + days, h, m);
  List<String> names(int n) => _pool.take(n).toList();

  return [
    // * 60-character title
    WorkoutSession(
      id: 's01',
      title: 'Saturday Morning Full-Body Strength and Conditioning Circuit',
      type: SessionType.strength,
      scheduledAt: at(2, 8, 0),
      maxParticipants: 12,
      participants: names(5),
      venue: 'Main Gym, Hall A',
      description: 'Squats, presses and a finisher circuit. All levels.',
    ),
    WorkoutSession(
      id: 's02',
      title: 'Evening Yoga Flow',
      type: SessionType.yoga,
      scheduledAt: at(1, 19, 0),
      maxParticipants: 10,
      participants: names(6),
      venue: 'Studio 2',
      description: 'Slow vinyasa to unwind after the day.',
    ),
    // * at its limit
    WorkoutSession(
      id: 's03',
      title: 'Spin Sprint 45',
      type: SessionType.cardio,
      scheduledAt: at(3, 18, 30),
      maxParticipants: 4,
      participants: names(4),
      venue: 'Cycle Room',
      description: 'Interval ride, bring a towel.',
    ),
    // * past
    WorkoutSession(
      id: 's04',
      title: 'Morning 5K Run',
      type: SessionType.cardio,
      scheduledAt: at(-2, 7, 0),
      maxParticipants: 15,
      participants: names(9),
      venue: 'Central Park Gate',
      description: 'Easy pace, conversation allowed.',
    ),
    // * online (venue is a link) and * without description
    WorkoutSession(
      id: 's05',
      title: 'Live HIIT from Home',
      type: SessionType.hiit,
      scheduledAt: at(1, 7, 0),
      maxParticipants: 30,
      participants: names(11),
      venue: 'https://meet.example.com/hiit-live',
      online: true,
    ),
    WorkoutSession(
      id: 's06',
      title: 'Pool Endurance Laps',
      type: SessionType.swimming,
      scheduledAt: at(4, 20, 0),
      maxParticipants: 8,
      participants: names(3),
      venue: 'City Pool, Lane 3',
      description: 'Pace groups by lane. Cap required.',
      favourite: true,
    ),
    WorkoutSession(
      id: 's07',
      title: 'Mobility Reset',
      type: SessionType.mobility,
      scheduledAt: at(5, 12, 15),
      maxParticipants: 20,
      participants: names(7),
      venue: 'https://meet.example.com/mobility',
      online: true,
      description: 'Lunch-break stretching for desk-bound backs.',
    ),
    WorkoutSession(
      id: 's08',
      title: 'Powerlifting Basics',
      type: SessionType.strength,
      scheduledAt: at(6, 17, 0),
      maxParticipants: 6,
      participants: names(2),
      venue: 'Main Gym, Rack Zone',
    ),
    WorkoutSession(
      id: 's09',
      title: 'Sunday Trail Run',
      type: SessionType.cardio,
      scheduledAt: at(7, 9, 0),
      maxParticipants: 14,
      participants: names(5),
      venue: 'Kok-Tobe Trailhead',
      description: '8 km with some climbing. Bring water.',
      favourite: true,
    ),
    WorkoutSession(
      id: 's10',
      title: 'Tabata Tuesday',
      type: SessionType.hiit,
      scheduledAt: at(-5, 18, 0),
      maxParticipants: 16,
      participants: names(10),
      venue: 'Outdoor Court',
      description: 'Eight rounds, twenty seconds on, ten off.',
    ),
    WorkoutSession(
      id: 's11',
      title: 'Hatha Yoga for Beginners',
      type: SessionType.yoga,
      scheduledAt: at(8, 10, 0),
      maxParticipants: 12,
      participants: names(4),
      venue: 'Studio 1',
      description: 'Foundations of breath and posture.',
    ),
    WorkoutSession(
      id: 's12',
      title: 'Aqua Intervals',
      type: SessionType.swimming,
      scheduledAt: at(10, 7, 30),
      maxParticipants: 10,
      participants: const [],
      venue: 'City Pool, Lane 1',
      description: 'Short fast repeats with rest on the wall.',
    ),
  ];
}