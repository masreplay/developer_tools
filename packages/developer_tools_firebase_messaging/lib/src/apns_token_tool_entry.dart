import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A [DeveloperToolEntry] that displays the current APNS token in a dialog,
/// with an option to copy it.
///
/// APNS (Apple Push Notification Service) tokens are only available on iOS and
/// macOS. On other platforms the token will be `null`.
///
/// Useful for debugging Apple push notification registration, verifying that
/// the APNS token is correctly provisioned, or pasting it into backend admin
/// tools that work directly with Apple's push notification service.
DeveloperToolEntry apnsTokenToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'APNS Token',
    sectionLabel: sectionLabel,
    description: 'View or copy the APNS device token (iOS/macOS)',
    icon: Icons.phone_iphone,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _ApnsTokenDialog();
        },
      );
    },
  );
}

class _ApnsTokenDialog extends StatefulWidget {
  const _ApnsTokenDialog();

  @override
  State<_ApnsTokenDialog> createState() => _ApnsTokenDialogState();
}

class _ApnsTokenDialogState extends State<_ApnsTokenDialog> {
  late Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = FirebaseMessaging.instance.getAPNSToken();
  }

  void _refreshToken() {
    setState(() {
      _tokenFuture = FirebaseMessaging.instance.getAPNSToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.phone_iphone, size: 24),
          SizedBox(width: 8),
          Expanded(child: Text('APNS Token')),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: FutureBuilder<String?>(
          future: _tokenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
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
                    'Error loading APNS token:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            }

            final token = snapshot.data;
            if (token == null || token.isEmpty) {
              return SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'No APNS token available.\n'
                    'APNS tokens are only available on iOS/macOS.\n'
                    'Ensure notification permissions are granted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
                    content: Text('APNS token copied to clipboard'),
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
