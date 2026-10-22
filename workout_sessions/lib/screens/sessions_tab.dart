import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/session_type.dart';
import '../models/workout_session.dart';
import '../routes.dart';
import '../utils/session_queries.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_results.dart';

class SessionsTab extends StatefulWidget {
  const SessionsTab({
    super.key,
    required this.sessions,
    required this.profile,
    required this.onSessionChanged,
    required this.onSessionAdded,
    required this.onSessionDeleted,
    required this.onSwitchTab,
  });

  final List<WorkoutSession> sessions;
  final Profile profile;
  final ValueChanged<WorkoutSession> onSessionChanged;
  final ValueChanged<WorkoutSession> onSessionAdded;
  final ValueChanged<String> onSessionDeleted;
  final ValueChanged<int> onSwitchTab;

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  SessionType? _type;
  bool _showPast = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<WorkoutSession> get _visible {
    final q = _search.trim().toLowerCase();
    return [
      for (final s in sortedByDate(ofType(widget.sessions, _type)))
        if ((_showPast || !s.isPast) &&
            (q.isEmpty ||
                s.title.toLowerCase().contains(q) ||
                s.venue.toLowerCase().contains(q)))
          s,
    ];
  }

  void _openDetail(WorkoutSession s) {
    Navigator.pushNamed<void>(
      context,
      Routes.detail,
      arguments: DetailArgs(
        session: s,
        profile: widget.profile,
        onChanged: widget.onSessionChanged,
        onDeleted: widget.onSessionDeleted,
        onSwitchTab: widget.onSwitchTab,
      ),
    );
  }

  Future<void> _createSession() async {
    final created = await Navigator.pushNamed<WorkoutSession>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    widget.onSessionAdded(created);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session created')),
    );
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _search = '';
      _type = null;
      _showPast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createSession,
        icon: const Icon(Icons.add),
        label: const Text('New session'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: 'Search by title or place',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.clear),
                  onPressed: _clearFilters,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _type == null,
                  onSelected: (_) => setState(() => _type = null),
                ),
                for (final t in SessionType.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: Icon(t.icon, size: 18),
                    label: Text(t.label),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilterChip(
                label: const Text('Show past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? (widget.sessions.isEmpty
                ? EmptyState(
              icon: Icons.fitness_center,
              message: 'No sessions yet',
              buttonLabel: 'Create a session',
              onPressed: _createSession,
            )
                : EmptyState(
              icon: Icons.search_off,
              message: 'Nothing matches your filters',
              buttonLabel: 'Clear filters',
              onPressed: _clearFilters,
            ))
                : SessionResults(
              sessions: visible,
              onOpen: _openDetail,
              onFavouriteToggle: (s) =>
                  widget.onSessionChanged(s.toggleFavourite()),
              bottomPadding: 88, // clears the FAB
            ),
          ),
        ],
      ),
    );
  }
}