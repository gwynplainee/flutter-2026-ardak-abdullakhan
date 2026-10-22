import 'package:flutter/material.dart';

enum SessionType {
  strength('Strength', Icons.fitness_center),
  cardio('Cardio', Icons.directions_run),
  yoga('Yoga', Icons.self_improvement),
  hiit('HIIT', Icons.bolt),
  swimming('Swimming', Icons.pool),
  mobility('Mobility', Icons.accessibility_new);

  const SessionType(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    SessionType.strength => scheme.primary,
    SessionType.cardio => scheme.error,
    SessionType.yoga => scheme.tertiary,
    SessionType.hiit => scheme.secondary,
    SessionType.swimming => scheme.primaryContainer,
    SessionType.mobility => scheme.tertiaryContainer,
  };

  Color onColor(ColorScheme scheme) => switch (this) {
    SessionType.strength => scheme.onPrimary,
    SessionType.cardio => scheme.onError,
    SessionType.yoga => scheme.onTertiary,
    SessionType.hiit => scheme.onSecondary,
    SessionType.swimming => scheme.onPrimaryContainer,
    SessionType.mobility => scheme.onTertiaryContainer,
  };
}