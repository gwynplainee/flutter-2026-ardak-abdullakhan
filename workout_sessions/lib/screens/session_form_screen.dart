import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/session_type.dart';
import '../models/workout_session.dart';
import '../routes.dart';
import '../utils/dialogs.dart';
import '../utils/format.dart';

class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _venueCtrl = TextEditingController();
  final TextEditingController _limitCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _venueFocus = FocusNode();
  final FocusNode _limitFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  late final WorkoutSession _initial;
  late final bool _isNew;

  SessionType? _type;
  bool _online = false;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.args.session;
    _isNew = existing == null;
    _initial = existing ?? WorkoutSession.empty();

    _titleCtrl.text = _initial.title;
    _venueCtrl.text = _initial.venue;
    _limitCtrl.text = _initial.maxParticipants.toString();
    _descCtrl.text = _initial.description ?? '';
    _type = _initial.type;
    _online = _initial.online;

    final at = _initial.scheduledAt;
    _date = DateTime(at.year, at.month, at.day);
    _time = TimeOfDay(hour: at.hour, minute: at.minute);
    _dateCtrl.text = formatDate(at);
    _timeCtrl.text = formatTime(at.hour, at.minute);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _venueCtrl.dispose();
    _limitCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _titleFocus.dispose();
    _venueFocus.dispose();
    _limitFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  // ---- helpers ----

  DateTime? _combine() {
    final d = _date;
    final t = _time;
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  bool _computeDirty() =>
      _titleCtrl.text != _initial.title ||
          _venueCtrl.text != _initial.venue ||
          _limitCtrl.text != _initial.maxParticipants.toString() ||
          _descCtrl.text != (_initial.description ?? '') ||
          _type != _initial.type ||
          _online != _initial.online ||
          _combine() != _initial.scheduledAt;

  void _refreshDirty() {
    final dirty = _computeDirty();
    if (dirty != _dirty) setState(() => _dirty = dirty);
  }

  void _dismissKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();


  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = _date ?? today;
    final first = current.isBefore(today) ? current : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: first,
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateCtrl.text = formatDate(picked);
    });
    _refreshDirty();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeCtrl.text = formatTime(picked.hour, picked.minute);
    });
    _refreshDirty();
  }


  Future<void> _save() async {
    if (_saving) return; // a double tap cannot save twice
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final when = _combine() ?? _initial.scheduledAt;
    final desc = _descCtrl.text.trim();
    final saved = _initial.copyWith(
      title: _titleCtrl.text.trim(),
      type: _type,
      scheduledAt: when,
      maxParticipants:
      int.tryParse(_limitCtrl.text.trim()) ?? _initial.maxParticipants,
      venue: _venueCtrl.text.trim(),
      online: _online,
      description: desc,
      clearDescription: desc.isEmpty,
    );
    Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await confirmDialog(
          context,
          title: 'Discard changes?',
          message: 'Your edits will be lost.',
          confirmLabel: 'Discard',
          cancelLabel: 'Keep editing',
        );
        if (!mounted) return;
        if (discard) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New session' : 'Edit session')),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: _refreshDirty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    focusNode: _titleFocus,
                    maxLength: 60,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: WorkoutSession.validateTitle,
                    onFieldSubmitted: (_) => _venueFocus.requestFocus(),
                    onTapOutside: _dismissKeyboard,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SessionType>(
                    value: _type,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final t in SessionType.values)
                        DropdownMenuItem(
                          value: t,
                          child: Row(
                            children: [
                              Icon(t.icon, size: 20),
                              const SizedBox(width: 8),
                              Text(t.label),
                            ],
                          ),
                        ),
                    ],
                    validator: (v) => v == null ? 'Choose a category' : null,
                    onChanged: (v) {
                      setState(() => _type = v);
                      _refreshDirty();
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Online session'),
                    subtitle: const Text('The place becomes a link'),
                    value: _online,
                    onChanged: (v) {
                      setState(() => _online = v);
                      _refreshDirty();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _venueCtrl,
                    focusNode: _venueFocus,
                    keyboardType:
                    _online ? TextInputType.url : TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: _online ? 'Link' : 'Place',
                      hintText: _online ? 'https://meet.example.com/room' : null,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        WorkoutSession.validateVenue(v, online: _online),
                    onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                    onTapOutside: _dismissKeyboard,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _limitCtrl,
                    focusNode: _limitFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Max participants (1–500)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => WorkoutSession.validateMax(
                      v,
                      alreadyJoined: _initial.count,
                    ),
                    onFieldSubmitted: (_) => _descFocus.requestFocus(),
                    onTapOutside: _dismissKeyboard,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateCtrl,
                          readOnly: true,
                          onTap: _pickDate,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            suffixIcon: Icon(Icons.event),
                            border: OutlineInputBorder(),
                          ),
                          validator: (_) =>
                          _date == null ? 'Pick a date' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _timeCtrl,
                          readOnly: true,
                          onTap: _pickTime,
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            suffixIcon: Icon(Icons.schedule),
                            border: OutlineInputBorder(),
                          ),
                          validator: (_) {
                            if (_time == null) return 'Pick a time';
                            final when = _combine();
                            if (_isNew &&
                                when != null &&
                                when.isBefore(DateTime.now())) {
                              return 'Must be in the future';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtrl,
                    focusNode: _descFocus,
                    minLines: 2,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _descFocus.unfocus(),
                    onTapOutside: _dismissKeyboard,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}