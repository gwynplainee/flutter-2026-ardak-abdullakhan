import 'package:flutter/material.dart';

import '../data/seed_sessions.dart';
import '../models/profile.dart';
import '../models/workout_session.dart';
import '../screens/favourites_tab.dart';
import '../screens/profile_tab.dart';
import '../screens/sessions_tab.dart';
import '../utils/session_queries.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  List<WorkoutSession> _sessions = buildSeedSessions(DateTime.now());
  Profile _profile = const Profile.empty();
  int _tabIndex = 0;

  static const List<String> _titles = ['Sessions', 'Favourites', 'Profile'];


  void _onSessionChanged(WorkoutSession updated) {
    setState(() => _sessions = replaced(_sessions, updated));
  }

  void _onSessionAdded(WorkoutSession created) {
    setState(() => _sessions = [..._sessions, created]);
  }

  void _onSessionDeleted(String id) {
    setState(() => _sessions = [
      for (final s in _sessions)
        if (s.id != id) s,
    ]);
  }

  void _onProfileChanged(Profile updated) {
    setState(() => _profile = updated);
  }

  void _goToTab(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tabIndex = index);
  }


  Future<void> _showAbout() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Workout Plans\n'
              'Browse sessions, join them and keep your favourites.\n'
              'Version 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'This restores the original sessions and clears your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _sessions = buildSeedSessions(DateTime.now());
      _profile = const Profile.empty();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data reset')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tabIndex])),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Workout Plans',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmReset();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          SessionsTab(
            sessions: _sessions,
            profile: _profile,
            onSessionChanged: _onSessionChanged,
            onSessionAdded: _onSessionAdded,
            onSessionDeleted: _onSessionDeleted,
            onSwitchTab: _goToTab,
          ),
          FavouritesTab(
            sessions: _sessions,
            profile: _profile,
            onSessionChanged: _onSessionChanged,
            onSessionDeleted: _onSessionDeleted,
            onSwitchTab: _goToTab,
          ),
          ProfileTab(
            profile: _profile,
            sessions: _sessions,
            themeMode: widget.themeMode,
            onProfileChanged: _onProfileChanged,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}