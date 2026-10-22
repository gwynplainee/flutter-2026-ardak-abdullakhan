import 'dart:async';

import 'package:flutter/material.dart';

import '../models/workout_session.dart';
import '../routes.dart';
import '../utils/dialogs.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late WorkoutSession _session;
  late DateTime _now;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _session = widget.args.session;
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _name => widget.args.profile.name.trim();
  bool get _joined => _name.isNotEmpty && _session.contains(_name);
  bool get _blocked => _session.isPast || (!_joined && _session.isFull);

  Future<void> _onPrimary() async {
    if (_name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () => widget.args.onSwitchTab(2),
          ),
        ),
      );
      return;
    }
    final leaving = _joined;
    final confirmed = await confirmDialog(
      context,
      title: leaving ? 'Leave this session?' : 'Join this session?',
      message: _session.title,
      confirmLabel: leaving ? 'Leave' : 'Join',
    );
    if (!mounted || !confirmed) return;

    final updated = leaving ? _session.leave(_name) : _session.join(_name);
    setState(() => _session = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _edit() async {
    final updated = await Navigator.pushNamed<WorkoutSession>(
      context,
      Routes.form,
      arguments: FormArgs(session: _session),
    );
    if (updated == null || !mounted) return;
    setState(() => _session = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _delete() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete session?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!mounted || !confirmed) return;
    widget.args.onDeleted(_session.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = _joined
        ? 'Leave'
        : _session.isPast
        ? 'Ended'
        : _session.isFull
        ? 'Full'
        : 'Join';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session'),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (action) => switch (action) {
                _MenuAction.edit => _edit(),
                _MenuAction.delete => _delete(),
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(session: _session, countdown: describeCountdown(_session.countdownAt(_now))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _session.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_session.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(session: _session),
                  _NamesTab(
                    session: _session,
                    myName: _name,
                    onJoin: _blocked ? null : _onPrimary,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _blocked ? null : _onPrimary,
                    icon: Icon(_joined ? Icons.logout : Icons.add),
                    label: Text(label),
                    style: _joined
                        ? FilledButton.styleFrom(
                      backgroundColor: scheme.errorContainer,
                      foregroundColor: scheme.onErrorContainer,
                    )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.session, required this.countdown});

  final WorkoutSession session;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = session.type.color(scheme);
    return AspectRatio(
      aspectRatio: 2,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/workout_header.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: scheme.surfaceContainerHighest),
            ),
          ),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: color,
              child: Icon(
                session.type.icon,
                size: 40,
                color: session.type.onColor(scheme),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _Pill(icon: session.type.icon, text: session.type.label),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _Pill(icon: Icons.timer_outlined, text: countdown),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(text, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDateTime(session.scheduledAt)),
          subtitle: const Text('Date'),
        ),
        ListTile(
          leading: Icon(session.online ? Icons.link : Icons.place_outlined),
          title: Text(session.venue),
          subtitle: Text(session.venueLabel),
        ),
        ListTile(
          leading: const Icon(Icons.group_outlined),
          title: Text(formatPlaces(session)),
          subtitle: const Text('Places'),
        ),
        if (session.description case final text?)
          ListTile(
            leading: const Icon(Icons.notes),
            title: Text(text),
            subtitle: const Text('About this session'),
          ),
      ],
    );
  }
}

class _NamesTab extends StatelessWidget {
  const _NamesTab({
    required this.session,
    required this.myName,
    required this.onJoin,
  });

  final WorkoutSession session;
  final String myName;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final names = session.participants;
    if (names.isEmpty) {
      return EmptyState(
        icon: Icons.group_outlined,
        message: 'Nobody has joined yet',
        buttonLabel: onJoin == null ? null : 'Be the first',
        onPressed: onJoin,
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (_, i) {
        final name = names[i];
        final isYou =
            myName.isNotEmpty && name.toLowerCase() == myName.toLowerCase();
        return ListTile(
          tileColor: isYou ? scheme.primaryContainer : null,
          leading: CircleAvatar(child: Text(name.characters.first)),
          title: Text(name),
          trailing: isYou ? const Chip(label: Text('You')) : null,
        );
      },
    );
  }
}