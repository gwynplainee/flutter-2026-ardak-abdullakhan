import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

/// launchUrl answers false when nothing can handle the link
Future<void> _open(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(uri);
  } on PlatformException {
    ok = false;
  }
  if (!ok) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No app can open this')),
    );
  }
}

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
          _tile(
            Icons.email,
            'Email',
            user.email,
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          _tile(
            Icons.phone,
            'Phone',
            user.phone,
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          if (user.website case final site?)
            _tile(
              Icons.language,
              'Website',
              site,
              onTap: () => _open(context, Uri.parse('https://$site')),
            ),
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
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy token to clipboard'),
                onPressed: () async {
                  final store = context.read<SecureStore>();
                  final messenger = ScaffoldMessenger.of(context);
                  final token = await store.readToken();
                  if (token == null) return;
                  await Clipboard.setData(ClipboardData(text: token));
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Token copied')),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
