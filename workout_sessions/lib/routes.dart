import 'package:flutter/material.dart';

import 'models/profile.dart';
import 'models/workout_session.dart';
import 'screens/session_detail_screen.dart';
import 'screens/session_form_screen.dart';

class DetailArgs {
  const DetailArgs({
    required this.session,
    required this.profile,
    required this.onChanged,
    required this.onDeleted,
    required this.onSwitchTab,
  });

  final WorkoutSession session;
  final Profile profile;
  final ValueChanged<WorkoutSession> onChanged;
  final ValueChanged<String> onDeleted;

  final ValueChanged<int> onSwitchTab;
}

class FormArgs {
  const FormArgs({this.session});
  final WorkoutSession? session;
}

abstract final class Routes {
  static const String home = '/';
  static const String detail = '/detail';
  static const String form = '/form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch ((settings.name, settings.arguments)) {
      (Routes.detail, final DetailArgs args) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => SessionDetailScreen(args: args),
      ),
      (Routes.form, final FormArgs args) => MaterialPageRoute<WorkoutSession>(
        settings: settings,
        builder: (context) => SessionFormScreen(args: args),
      ),
      _ => null,
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => const _NotFoundScreen(),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    );
  }
}