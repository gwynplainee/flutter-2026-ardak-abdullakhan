import 'package:flutter/material.dart';

import '../user.dart';
import '../user_detail_screen.dart';

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No users in this city')),
          ),
        ],
      );
    }
    return ListView.separated(
      // must always scroll, otherwise pull-to-refresh does not work
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final u = users[i];
        return ListTile(
          title: Text(u.name),
          subtitle: Text('${u.email}\n${u.address.city}'),
          isThreeLine: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserDetailScreen(user: u)),
          ),
        );
      },
    );
  }
}
