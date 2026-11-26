import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/profile/avatar_store.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // before any plugin

  // Read everything the first frame needs BEFORE runApp.
  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter'); // String?

  const store = SecureStore();
  final signedIn = await store.readToken() != null;

  final api = ApiClient.real(store);

  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStore>.value(value: store), // for the debug token button
        Provider<AvatarStore>.value(value: AvatarStore(prefs)),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(prefs, dark: dark, city: city),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthModel(store, signedIn: signedIn),
        ),
        ChangeNotifierProvider(
          create: (_) => UsersModel(UserRepository(api, UsersCache()))..load(),
        ),
      ],
      child: const App(),
    ),
  );
}
