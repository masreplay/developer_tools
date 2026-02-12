import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Single [DeveloperToolEntry] that opens a dialog showing all available
/// package information: app name, package name, version, build number,
/// build signature, installer store, and install/update times.
DeveloperToolEntry packageOverviewToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Package Info',
    sectionLabel: sectionLabel,
    description: 'View app name, version, and build details',
    icon: Icons.info_outline,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _PackageOverviewDialog();
        },
      );
    },
  );
}

class _PackageOverviewDialog extends StatefulWidget {
  const _PackageOverviewDialog();

  @override
  State<_PackageOverviewDialog> createState() => _PackageOverviewDialogState();
}

class _PackageOverviewDialogState extends State<_PackageOverviewDialog> {
  late final Future<PackageInfo> _infoFuture;

  @override
  void initState() {
    super.initState();
    _infoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, size: 24),
          SizedBox(width: 8),
          Text('Package Info'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: FutureBuilder<PackageInfo>(
          future: _infoFuture,
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
                    'Error loading package info:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final info = snapshot.data!;
            return _buildInfoContent(context, info);
          },
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () async {
            try {
              final info = await _infoFuture;
              final text = _formatPackageInfoForCopy(info);
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Package info copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (_) {}
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy All'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoContent(BuildContext context, PackageInfo info) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App identity card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withAlpha(40)),
          ),
          child: Column(
            children: [
              Icon(Icons.apps, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                info.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'v${info.version} (${info.buildNumber})',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                info.packageName,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Details
        const _SectionHeader('Application'),
        _InfoRow('App Name', info.appName),
        _InfoRow('Package Name', info.packageName),
        _InfoRow('Version', info.version),
        _InfoRow('Build Number', info.buildNumber),
        const SizedBox(height: 8),
        const _SectionHeader('Build Details'),
        _InfoRow(
          'Build Signature',
          info.buildSignature.isEmpty ? '(none)' : info.buildSignature,
        ),
        _InfoRow('Installer Store', info.installerStore ?? '(unknown)'),
        const SizedBox(height: 8),
        const _SectionHeader('Timestamps'),
        _InfoRow(
          'Install Time',
          info.installTime != null
              ? _formatDateTime(info.installTime!)
              : '(unavailable)',
        ),
        _InfoRow(
          'Update Time',
          info.updateTime != null
              ? _formatDateTime(info.updateTime!)
              : '(unavailable)',
        ),
      ],
    );
  }

  static String _formatDateTime(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

String _formatPackageInfoForCopy(PackageInfo info) {
  final buffer = StringBuffer();
  buffer.writeln('=== Package Info ===');
  buffer.writeln('App Name: ${info.appName}');
  buffer.writeln('Package Name: ${info.packageName}');
  buffer.writeln('Version: ${info.version}');
  buffer.writeln('Build Number: ${info.buildNumber}');
  buffer.writeln(
    'Build Signature: ${info.buildSignature.isEmpty ? "(none)" : info.buildSignature}',
  );
  buffer.writeln('Installer Store: ${info.installerStore ?? "(unknown)"}');
  if (info.installTime != null) {
    buffer.writeln('Install Time: ${info.installTime!.toIso8601String()}');
  }
  if (info.updateTime != null) {
    buffer.writeln('Update Time: ${info.updateTime!.toIso8601String()}');
  }
  return buffer.toString();
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

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
