# Workout Plans

A Flutter app for browsing workout sessions and joining them. The domain is
**workout plans**: each session has a title, a type (strength, cardio, yoga,
HIIT, swimming, mobility), a date and time, a place or a link when it is
online, a participant limit and the list of people who joined.

Three tabs: **Sessions** (search, filter, join), **Favourites**, **Profile**
(name, group, theme).

## Screenshots

| Phone, light | Phone, dark | Tablet, grid |
| --- | --- | --- |
| ![Phone light](docs/screenshots/phone-light.png) | ![Phone dark](docs/screenshots/phone-dark.png) | ![Tablet grid](docs/screenshots/tablet-grid.png) |

## Decisions

The list of sessions and the profile live in the shell's State, the one common ancestor of all three tabs, so tabs receive them as constructor parameters and send every change up through a callback; the theme mode lives one level higher in MyApp because MaterialApp needs it. The detail screen takes callbacks in its route arguments because it must change data it does not own, and it keeps a local copy of the session only so it can redraw at once. The form returns a value through pop because it is a question with an answer: the caller decides what to do with the new or edited session, and backing out returns null and changes nothing. The list is decided by a LayoutBuilder rather than MediaQuery because the layout should follow the width the tab is actually given, not the width of the whole screen, switching between a separated list and a grid whose cells are at most 360 px. The PopScope compares the current values of the title, place, limit, description, category, mode and date-time with the values the form opened with, so typing something and deleting it again does not count as a change. Save pops with the result directly and therefore never asks to discard. With week 9's tools I would move the sessions out of the shell's State into a shared observable state holder that screens listen to, so callbacks would no longer have to travel through route arguments.

## Run

```
flutter pub get
flutter run
flutter analyze
dart format .
```