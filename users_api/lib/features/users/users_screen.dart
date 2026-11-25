import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/state_views.dart';
import 'widgets/user_list.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();

    final Widget body;
    if (m.loading) {
      body = const LoadingView();
    } else {
      body = switch (m.error) {
        null => RefreshIndicator(onRefresh: m.load, child: UserList(m.items)),
        NoConnectionException() => Offline(onRetry: m.load),
        NotFoundException() || UnauthorizedException() => const RequestError(),
        ServerException(:final status) => ServerError(status, onRetry: m.load),
        BadResponseException() => const GenericError(),
      };
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
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
