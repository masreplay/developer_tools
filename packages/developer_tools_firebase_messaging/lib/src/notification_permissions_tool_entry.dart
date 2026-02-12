import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// A [DeveloperToolEntry] that shows the current notification permission status
/// and provides a button to request permissions.
DeveloperToolEntry notificationPermissionsToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Notification Permissions',
    sectionLabel: sectionLabel,
    description: 'View and request notification permissions',
    icon: Icons.notifications_active,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _NotificationPermissionsDialog();
        },
      );
    },
  );
}

class _NotificationPermissionsDialog extends StatefulWidget {
  const _NotificationPermissionsDialog();

  @override
  State<_NotificationPermissionsDialog> createState() =>
      _NotificationPermissionsDialogState();
}

class _NotificationPermissionsDialogState
    extends State<_NotificationPermissionsDialog> {
  late Future<NotificationSettings> _settingsFuture;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _settingsFuture = FirebaseMessaging.instance.getNotificationSettings();
  }

  void _refresh() {
    setState(() {
      _settingsFuture = FirebaseMessaging.instance.getNotificationSettings();
    });
  }

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);
    try {
      await FirebaseMessaging.instance.requestPermission();
      _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to request permissions: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications_active, size: 24),
          SizedBox(width: 8),
          Expanded(child: Text('Notification Permissions')),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: FutureBuilder<NotificationSettings>(
          future: _settingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                _isRequesting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Error loading notification settings:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            }

            final settings = snapshot.data!;
            return ListView(
              shrinkWrap: true,
              children: [
                _SectionHeader('Authorization'),
                _StatusRow(
                  'Status',
                  _authorizationLabel(settings.authorizationStatus),
                  color: _authorizationColor(
                    settings.authorizationStatus,
                    theme,
                  ),
                ),
                const SizedBox(height: 8),
                _SectionHeader('Settings'),
                _SettingRow('Alert', settings.alert),
                _SettingRow('Announcement', settings.announcement),
                _SettingRow('Badge', settings.badge),
                _SettingRow('Car Play', settings.carPlay),
                _SettingRow('Critical Alert', settings.criticalAlert),
                _SettingRow('Lock Screen', settings.lockScreen),
                _SettingRow('Notification Center', settings.notificationCenter),
                _SettingRow('Sound', settings.sound),
                _SettingRow('Time Sensitive', settings.timeSensitive),
              ],
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: _requestPermission,
          icon: const Icon(Icons.security, size: 18),
          label: const Text('Request Permission'),
        ),
        TextButton.icon(
          onPressed: _refresh,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Refresh'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  static String _authorizationLabel(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized => 'Authorized',
      AuthorizationStatus.denied => 'Denied',
      AuthorizationStatus.notDetermined => 'Not Determined',
      AuthorizationStatus.provisional => 'Provisional',
    };
  }

  static Color _authorizationColor(
    AuthorizationStatus status,
    ThemeData theme,
  ) {
    return switch (status) {
      AuthorizationStatus.authorized => Colors.green,
      AuthorizationStatus.denied => theme.colorScheme.error,
      AuthorizationStatus.notDetermined => Colors.orange,
      AuthorizationStatus.provisional => Colors.blue,
    };
  }
}

// ── Shared widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color?.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(this.label, this.setting);

  final String label;
  final AppleNotificationSetting setting;

  @override
  Widget build(BuildContext context) {
    final (String text, IconData icon, Color color) = switch (setting) {
      AppleNotificationSetting.enabled => (
        'Enabled',
        Icons.check_circle,
        Colors.green,
      ),
      AppleNotificationSetting.disabled => (
        'Disabled',
        Icons.cancel,
        Theme.of(context).colorScheme.error,
      ),
      AppleNotificationSetting.notSupported => (
        'Not Supported',
        Icons.help_outline,
        Colors.grey,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
