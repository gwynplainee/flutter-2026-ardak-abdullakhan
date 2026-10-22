class Profile {
  const Profile({required this.name, required this.group});

  const Profile.empty() : this(name: '', group: '');

  final String name;
  final String group;

  bool get isEmpty => name.trim().isEmpty;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);

  static String? validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 2) return 'Name must be at least 2 characters';
    if (v.length > 40) return 'Name must be at most 40 characters';
    return null;
  }

  static final RegExp _groupPattern = RegExp(r'^[A-Za-z]{2,5}-\d{3,4}$');

  static String? validateGroup(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Group is required';
    return _groupPattern.hasMatch(v) ? null : 'Use a format like CS-2301';
  }
}