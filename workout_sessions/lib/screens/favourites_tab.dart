import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/workout_session.dart';
import '../routes.dart';
import '../utils/session_queries.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_results.dart';


class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.sessions,
    required this.profile,
    required this.onSessionChanged,
    required this.onSessionDeleted,
    required this.onSwitchTab,
  });

  final List<WorkoutSession> sessions;
  final Profile profile;
  final ValueChanged<WorkoutSession> onSessionChanged;
  final ValueChanged<String> onSessionDeleted;
  final ValueChanged<int> onSwitchTab;

  void _openDetail(BuildContext context, WorkoutSession s) {
    Navigator.pushNamed<void>(
      context,
      Routes.detail,
      arguments: DetailArgs(
        session: s,
        profile: profile,
        onChanged: onSessionChanged,
        onDeleted: onSessionDeleted,
        onSwitchTab: onSwitchTab,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favourites = sortedByDate(favouritesOf(sessions));

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        buttonLabel: 'Browse sessions',
        onPressed: () => onSwitchTab(0),
      );
    }
    return SessionResults(
      sessions: favourites,
      onOpen: (s) => _openDetail(context, s),
      onFavouriteToggle: (s) => onSessionChanged(s.toggleFavourite()),
    );
  }
}