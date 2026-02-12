import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A [DeveloperToolEntry] that displays the current FCM token in a dialog,
/// with options to copy or delete it.
///
/// Useful for debugging push notification registration and for easily pasting
/// the device token into Firebase Console, Postman, or backend admin tools.
DeveloperToolEntry fcmTokenToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'FCM Token',
    sectionLabel: sectionLabel,
    description: 'View or copy the FCM device token',
    icon: Icons.key,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _FcmTokenDialog();
        },
      );
    },
  );
}

class _FcmTokenDialog extends StatefulWidget {
  const _FcmTokenDialog();

  @override
  State<_FcmTokenDialog> createState() => _FcmTokenDialogState();
}

class _FcmTokenDialogState extends State<_FcmTokenDialog> {
  late Future<String?> _tokenFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _tokenFuture = FirebaseMessaging.instance.getToken();
  }

  void _refreshToken() {
    setState(() {
      _tokenFuture = FirebaseMessaging.instance.getToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.key, size: 24),
          SizedBox(width: 8),
          Expanded(child: Text('FCM Token')),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: FutureBuilder<String?>(
          future: _tokenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                _isDeleting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'Error loading FCM token:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            }

            final token = snapshot.data;
            if (token == null || token.isEmpty) {
              return const SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'No FCM token available.\n'
                    'Ensure Firebase is initialized and\n'
                    'notification permissions are granted.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Token',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    token,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () async {
            try {
              setState(() => _isDeleting = true);
              await FirebaseMessaging.instance.deleteToken();
              _refreshToken();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete token: $e')),
                );
              }
            } finally {
              if (mounted) setState(() => _isDeleting = false);
            }
          },
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Delete'),
        ),
        TextButton.icon(
          onPressed: _refreshToken,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Refresh'),
        ),
        TextButton.icon(
          onPressed: () async {
            final token = await _tokenFuture;
            if (token != null && token.isNotEmpty) {
              await Clipboard.setData(ClipboardData(text: token));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('FCM token copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
