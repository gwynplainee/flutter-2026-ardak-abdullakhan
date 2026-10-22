import 'package:flutter/material.dart';

import '../models/workout_session.dart';
import '../utils/format.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onFavouriteToggle,
  });

  final WorkoutSession session;
  final VoidCallback onTap;
  final VoidCallback onFavouriteToggle;

  String? get _badge {
    if (session.isFull) return 'FULL';
    if (session.freePlaces <= 5) return '${session.freePlaces} left';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final badge = _badge;
    final avatarColor = session.type.color(scheme);
    final onAvatar = session.type.onColor(scheme);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: session.isPast ? 0.6 : 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CircleAvatar(
                          backgroundColor: avatarColor,
                          child: Icon(session.type.icon, color: onAvatar),
                        ),
                      ),
                      if (badge case final text?)
                        Positioned(
                          right: -6,
                          bottom: -6,
                          child: _Badge(text: text, isFull: session.isFull),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        session.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      _InfoLine(
                        icon: Icons.schedule,
                        text: session.isPast
                            ? '${formatDateTime(session.scheduledAt)} · past'
                            : formatDateTime(session.scheduledAt),
                      ),
                      _InfoLine(
                        icon: session.online
                            ? Icons.videocam_outlined
                            : Icons.place_outlined,
                        text: session.venue,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: session.favourite
                      ? 'Remove from favourites'
                      : 'Add to favourites',
                  onPressed: onFavouriteToggle,
                  icon: Icon(
                    session.favourite ? Icons.favorite : Icons.favorite_border,
                    color: session.favourite ? scheme.error : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.isFull});

  final String text;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isFull ? scheme.error : scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isFull ? scheme.onError : scheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}