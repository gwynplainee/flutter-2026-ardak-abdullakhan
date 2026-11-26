import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'avatar_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _avatar;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSaved()); // restoring a saved photo is fine here
  }

  Future<void> _loadSaved() async {
    final file = await context.read<AvatarStore>().load();
    if (!mounted) return;
    setState(() => _avatar = file);
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // The gallery needs no permission.
  Future<void> _chooseFromGallery() => _pick(ImageSource.gallery);

  // The camera - ask AT THE TAP
  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    // a new enum value becomes a compile-time warning.
    switch (status) {
      case PermissionStatus.granted ||
          PermissionStatus.limited ||
          PermissionStatus.provisional:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        _snack(
          'The camera is needed to take a photo. '
          'You can still choose one from the gallery.',
        );
      case PermissionStatus.permanentlyDenied:
        await _showSettingsDialog();
      case PermissionStatus.restricted:
        _snack('The camera is restricted on this device.');
    }
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera access is off'),
        content: const Text(
          'To take a photo, allow the camera in the app settings. '
          'You can still choose a photo from the gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open == true) {
      await openAppSettings();
    }
  }

  Future<void> _pick(ImageSource source) async {
    final store = context.read<AvatarStore>();
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return; // 1) null check

      final file = await store.save(picked);
      await FileImage(file)
          .evict(); // same file name every time - drop the cached image
      if (!mounted) return; // 2) mounted
      setState(() => _avatar = file); // 3) setState
    } on Exception {
      if (!mounted) return;
      _snack('Could not get the photo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatar;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: avatar == null ? null : FileImage(avatar),
              child: avatar == null
                  ? const Text('U', style: TextStyle(fontSize: 32))
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
              onPressed: () => unawaited(_chooseFromGallery()),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
              onPressed: () => unawaited(_takePhoto()),
            ),
          ],
        ),
      ),
    );
  }
}
