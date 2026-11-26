# NOTES

## Level 1: Postman

GET /users -> 200, application/json; charset=utf-8, list of 10 users.

GET /users/999 -> 404, body: {}

POST /users (JSON body) -> 201, body = what I sent + "id": 11 added by the server.

GET /users?id=3 -> 200, a LIST with one user (not an object).

### User (top level)
| field    | JSON type | Dart type | nullable? |
|----------|-----------|-----------|-----------|
| id       | number    | int       | no        |
| name     | string    | String    | no        |
| username | string    | String    | no        |
| email    | string    | String    | no        |
| phone    | string    | String    | no        |
| website  | string    | String?   | yes (present in all 10 users, but I treat it as optional on purpose) |
| address  | object    | Address   | no        |
| company  | object    | record ({String name, String catchPhrase}) | no |

### address
| field   | JSON type | Dart type | nullable? |
|---------|-----------|-----------|-----------|
| street  | string    | String    | no |
| suite   | string    | String    | no |
| city    | string    | String    | no |
| zipcode | string    | String    | no |
| geo     | object    | Geo       | no (nested twice: address.geo) |

### address.geo
| field | JSON type | Dart type | nullable? |
|-------|-----------|-----------|-----------|
| lat   | STRING ("-37.3159") | double (double.parse) | no |
| lng   | STRING ("81.1496")  | double (double.parse) | no |

### company
| field      | JSON type | Dart type | nullable? |
|------------|-----------|-----------|-----------|
| name       | string    | String    | no |
| catchPhrase| string    | String    | no |
| bs         | string    | (not used)| - |


# Practice 12 Notes

## Package research

1. shared_preferences:
   Publisher: flutter.dev
   Last release: 2.5.6
   Platforms: Android, iOS, Linux, macOS, web, Windows
   Pub points: 160
   Dependencies: no dependencies of note
   License: BSD-3-Clause

2. flutter_secure_storage:
   Publisher: steenbakker.dev
   Last release: 11.2.0
   Platforms: all six platforms
   Pub points: 160 
   Dependencies: no dependencies of note
   License: BSD-3-Clause

3. path_provider:
   Publisher: flutter.dev
   Last release: 2.1.6
   Platforms: all platforms except web
   Pub points: 160
   Dependencies: no dependencies of note
   License: BSD-3-Clause

4. image_picker:
   Publisher: flutter.dev
   Last release: 1.2.4
   Platforms: all six platforms
   Pub points: 160
   Dependencies: no dependencies of note
   License: Apache-2.0, BSD-3-Clause

5. permission_handler:
   Publisher: baseflow.com
   Last release: 13.0.2
   Platforms: Android, iOS, web, Windows
   Pub points: 160
   Dependencies: no dependencies of note
   License: MIT

6. url_launcher:
   Publisher: flutter.dev
   Last release: 6.3.3
   Platforms: all six platforms
   Pub points: 160 
   Dependencies: no dependencies of note
   License: BSD-3-Clause

### Versions and the lock file

- `^1.2.0` means `>=1.2.0 <2.0.0`.
   - It accepts 1.2.0, 1.2.5, 1.3.0 and 1.9.9 (new features and fixes, no breaking changes under semver).
   - It refuses 1.1.9 (older than the minimum I need) and 2.0.0 (a major version may break the API).
- `pubspec.lock` is committed for an **app** so every teammate, CI run and release build uses
  exactly the same versions (reproducible builds). A library does not commit it.
- http resolved to <version from pubspec.lock>.
- `flutter pub outdated`: <package> could be newer (<current> -> <latest>) but I did not
  upgrade because <reason: caret blocks a new major / another package's constraint / want to read the changelog first>.

### Where would `prefs.setString('token', …)` have put the token?

- In a plain, unencrypted file in the app folder: on Android the SharedPreferences XML
  (or the DataStore file for the Async API), on iOS the UserDefaults plist.
- Who can read it: a device **backup**, **root / jailbreak**, or someone with a **cable**
  and a debug build.
- Secure storage uses the iOS **Keychain** and a key in the Android **Keystore**,
  protected by the OS.

### The two platform surprises

- **iOS:** Keychain items can **survive an uninstall**, so after a reinstall the old token
  may still be there and the app starts "signed in". Fix: remember a first-run flag in
  shared_preferences (which IS wiped on uninstall) and clear the Keychain when it is missing.
- **Android:** the Keystore key can be **invalidated when the lock screen is removed or
  changed**, so the encrypted token becomes unreadable. Fix: catch the exception, clear the
  store, and sign the user out (SecureStore.readToken does this).

### Camera permission sequence

- **Android:** 1st "Don't allow" -> `denied` (I may ask again). After the 2nd "Don't allow" the
  system stops showing the dialog and the status is `permanentlyDenied` (on some versions the
  2nd No already returns it). On the 3rd tap no system dialog appears, my own dialog does.
- **iOS:** the system dialog is shown **once**. After the 1st "Don't Allow" the status is
  already `permanentlyDenied`, so **1 No**. Only Settings can change it (`openAppSettings()`).
- The fourth Photos state on iOS (after granted, denied, restricted) is **limited**
  (iOS 14+: the user shared only selected photos).

### Why no `!` after a device await

`pickImage` returns null on Cancel, `launchUrl` returns false when no app can open the link,
and `request()` returns an enum with several values I must handle. Handle the No, and the
feature keeps working without the photo.