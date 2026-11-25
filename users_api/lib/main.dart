import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          UsersModel(UserRepository(ApiClient(http.Client())))..load(),
      child: const App(),
    ),
  );
}
