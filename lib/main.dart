import 'package:flutter/material.dart';
import 'package:flutter_2026_project/data.dart';

import 'profile_header.dart';
import 'info_row.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('My profile', style: TextStyle(fontFamily: 'Inter'))),
        body: Column(
          children: [
            const ProfileHeader(name: myName, university: myUniversity),
            ...[
              for (final fact in facts)
                InfoRow(label: fact.label, value: fact.value),
            ],
          ],
        ),
      ),
    );
  }
}
