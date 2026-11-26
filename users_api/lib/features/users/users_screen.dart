import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/state_views.dart';
import 'widgets/user_list.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.select<SettingsModel, String?>((s) => s.city);

    // The filter chosen in Settings
    final visible = [
      for (final u in m.items)
        if (city == null || u.address.city == city) u,
    ];

    final Widget body;
    if (m.loading) {
      body = const LoadingView();
    } else {
      body = switch (m.error) {
        null => Column(
          children: [
            if (m.fromCache) StaleBanner(onRetry: m.load),
            Expanded(
              child: RefreshIndicator(
                onRefresh: m.load,
                child: UserList(visible),
              ),
            ),
          ],
        ),
        NoConnectionException() => Offline(onRetry: m.load),
        NotFoundException() || UnauthorizedException() => const RequestError(),
        ServerException(:final status) => ServerError(status, onRetry: m.load),
        BadResponseException() => const GenericError(),
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewUserScreen()),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
    );
  }
}
