import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// A [DeveloperToolEntry] that opens the app's system settings page.
///
/// Useful when a permission is permanently denied and the user must change
/// it manually in settings; this action takes them there directly.
DeveloperToolEntry openAppSettingsToolEntry({
  String? sectionLabel,
}) {
  return DeveloperToolEntry(
    title: 'Open App Settings',
    sectionLabel: sectionLabel,
    description: 'Open the app\'s system settings page',
    icon: Icons.settings,
    onTap: (BuildContext context) async {
      final opened = await openAppSettings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              opened ? 'Opened app settings' : 'Could not open app settings',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    },
  );
}
