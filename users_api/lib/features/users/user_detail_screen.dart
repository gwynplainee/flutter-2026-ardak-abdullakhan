import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  ListTile _tile(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(value),
      subtitle: Text(label),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _tile(Icons.person, 'Username', user.username),
          _tile(Icons.email, 'Email', user.email),
          _tile(Icons.phone, 'Phone', user.phone, onTap: () {}),
          if (user.website case final site?)
            _tile(Icons.language, 'Website', site, onTap: () {}),
          _tile(
            Icons.home,
            'Address',
            '${a.street}, ${a.suite}, ${a.city} ${a.zipcode}',
          ),
          _tile(Icons.place, 'Geo', '${a.geo.lat}, ${a.geo.lng}'),
          _tile(
            Icons.business,
            'Company',
            '${user.company.name}\n${user.company.catchPhrase}',
          ),
        ],
      ),
    );
  }
}
