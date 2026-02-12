import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// A [DeveloperToolEntry] that deletes the current FCM token after a
/// confirmation dialog.
///
/// Useful for testing push notification re-registration flows or simulating
/// a fresh device state. After deletion, the next call to `getToken()` will
/// generate a new token.
DeveloperToolEntry deleteFcmTokenToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Delete FCM Token',
    sectionLabel: sectionLabel,
    description: 'Delete the current FCM device token',
    icon: Icons.delete_forever,
    onTap: (BuildContext context) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 24),
                SizedBox(width: 8),
                Expanded(child: Text('Delete FCM Token')),
              ],
            ),
            content: const Text(
              'This will delete the current FCM device token. '
              'The app will no longer receive push notifications until '
              'a new token is generated.\n\n'
              'Are you sure you want to continue?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                icon: const Icon(Icons.delete_forever, size: 18),
                label: const Text('Delete'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                  foregroundColor: Theme.of(dialogContext).colorScheme.onError,
                ),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !context.mounted) return;

      try {
        await FirebaseMessaging.instance.deleteToken();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('FCM token deleted successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete FCM token: $e')),
          );
        }
      }
    },
  );
}
