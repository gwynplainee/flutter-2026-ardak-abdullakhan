import 'package:flutter/material.dart';

import '../models/workout_session.dart';
import 'session_card.dart';

class SessionResults extends StatelessWidget {
  const SessionResults({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onFavouriteToggle,
    this.bottomPadding = 12,
  });

  final List<WorkoutSession> sessions;
  final ValueChanged<WorkoutSession> onOpen;
  final ValueChanged<WorkoutSession> onFavouriteToggle;

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget cardAt(int i) {
          final s = sessions[i];
          return SessionCard(
            session: s,
            onTap: () => onOpen(s),
            onFavouriteToggle: () => onFavouriteToggle(s),
          );
        }

        final padding = EdgeInsets.fromLTRB(12, 8, 12, bottomPadding);

        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: padding,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 136,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, i) => cardAt(i),
          );
        }
        return ListView.separated(
          padding: padding,
          itemCount: sessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) => cardAt(i),
        );
      },
    );
  }
}