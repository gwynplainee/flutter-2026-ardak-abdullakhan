import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final items = context.watch<UsersModel>().items;

    final cities = {for (final u in items) u.address.city}.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (v) => settings.setDark(v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String?>(
              initialValue: cities.contains(settings.city)
                  ? settings.city
                  : null,
              decoration: const InputDecoration(labelText: 'City filter'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All cities'),
                ),
                for (final c in cities)
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: (c) => settings.setCity(c),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              final auth = context.read<AuthModel>();
              final navigator = Navigator.of(context);
              await auth.logout(); // deletes the token from secure storage
              navigator.popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
