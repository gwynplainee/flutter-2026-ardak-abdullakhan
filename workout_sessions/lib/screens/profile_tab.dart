import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/workout_session.dart';
import '../utils/session_queries.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.sessions,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<WorkoutSession> sessions;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static const List<(ThemeMode, String, IconData)> _themeOptions = [
    (ThemeMode.light, 'Light', Icons.light_mode_outlined),
    (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
    (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
  ];

  final GlobalKey<FormFieldState<String>> _nameKey =
  GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _groupKey =
  GlobalKey<FormFieldState<String>>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _groupCtrl = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _groupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.profile.name;
    _groupCtrl.text = widget.profile.group;
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.name != widget.profile.name &&
        _nameCtrl.text != widget.profile.name) {
      _nameCtrl.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group &&
        _groupCtrl.text != widget.profile.group) {
      _groupCtrl.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _groupCtrl.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  void _submitName(String value) {
    final valid = _nameKey.currentState?.validate() ?? false;
    if (valid) {
      widget.onProfileChanged(widget.profile.copyWith(name: value.trim()));
      _groupFocus.requestFocus();
    }
  }

  void _submitGroup(String value) {
    final valid = _groupKey.currentState?.validate() ?? false;
    if (valid) {
      widget.onProfileChanged(
        widget.profile.copyWith(group: value.trim().toUpperCase()),
      );
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name.trim();

    final lists = name.isEmpty ? 0 : withJoined(widget.sessions, name).length;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            child: name.isEmpty
                ? const Icon(Icons.person, size: 40)
                : Text(
              name.characters.first.toUpperCase(),
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: _nameKey,
          controller: _nameCtrl,
          focusNode: _nameFocus,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Saved when you submit',
            border: OutlineInputBorder(),
          ),
          validator: Profile.validateName,
          onFieldSubmitted: _submitName,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: _groupKey,
          controller: _groupCtrl,
          focusNode: _groupFocus,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Group',
            hintText: 'CS-2301',
            helperText: 'Saved when you submit',
            border: OutlineInputBorder(),
          ),
          validator: Profile.validateGroup,
          onFieldSubmitted: _submitGroup,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.event_available),
            title: Text('You are on $lists ${lists == 1 ? 'list' : 'lists'}'),
          ),
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final (mode, label, icon) in _themeOptions)
              ChoiceChip(
                avatar: Icon(icon, size: 18),
                label: Text(label),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}