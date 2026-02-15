import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_report.dart';

/// A [DeveloperToolEntry] that opens a dialog showing the current status of
/// all requestable permissions (and service status where applicable).
///
/// Useful for quickly verifying which permissions are granted, denied, or
/// permanently denied during development.
DeveloperToolEntry permissionStatusOverviewToolEntry({
  String? sectionLabel,
}) {
  return DeveloperToolEntry(
    title: 'Permission Status Overview',
    sectionLabel: sectionLabel,
    description: 'View status of all permissions and copy report',
    icon: Icons.security,
    debugInfo: (BuildContext context) async => buildPermissionReport(),
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _PermissionStatusOverviewDialog();
        },
      );
    },
  );
}

class _PermissionStatusOverviewDialog extends StatefulWidget {
  const _PermissionStatusOverviewDialog();

  @override
  State<_PermissionStatusOverviewDialog> createState() =>
      _PermissionStatusOverviewDialogState();
}

class _PermissionStatusOverviewDialogState
    extends State<_PermissionStatusOverviewDialog> {
  List<_PermissionRow>? _rows;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final permissions =
          Permission.values.where((p) => p != Permission.unknown).toList();
      final rows = <_PermissionRow>[];
      for (final permission in permissions) {
        final status = await permission.status;
        ServiceStatus? serviceStatus;
        if (permission is PermissionWithService) {
          serviceStatus = await permission.serviceStatus;
        }
        rows.add(
          _PermissionRow(
            permission: permission,
            status: status,
            serviceStatus: serviceStatus,
          ),
        );
      }
      if (mounted) {
        setState(() {
          _rows = rows;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _copyReport() async {
    final report = await buildPermissionReport();
    await Clipboard.setData(ClipboardData(text: report));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission report copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.security, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Permission Status Overview')),
        ],
      ),
      content: SizedBox(
        width: 520,
        height: 480,
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        _error!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                )
                : _rows == null || _rows!.isEmpty
                ? const Center(child: Text('No permissions to show'))
                : ListView.builder(
                  itemCount: _rows!.length,
                  itemBuilder: (context, index) {
                    final row = _rows![index];
                    return _PermissionListTile(
                      permission: row.permission,
                      status: row.status,
                      serviceStatus: row.serviceStatus,
                      colorScheme: colorScheme,
                    );
                  },
                ),
      ),
      actions: <Widget>[
        if (!_loading && _error == null)
          TextButton.icon(
            onPressed: _copyReport,
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy report'),
          ),
        TextButton.icon(
          onPressed: _load,
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
}

class _PermissionRow {
  const _PermissionRow({
    required this.permission,
    required this.status,
    this.serviceStatus,
  });

  final Permission permission;
  final PermissionStatus status;
  final ServiceStatus? serviceStatus;
}

class _PermissionListTile extends StatelessWidget {
  const _PermissionListTile({
    required this.permission,
    required this.status,
    required this.serviceStatus,
    required this.colorScheme,
  });

  final Permission permission;
  final PermissionStatus status;
  final ServiceStatus? serviceStatus;
  final ColorScheme colorScheme;

  Color get _statusColor {
    if (status.isGranted) return colorScheme.primary;
    if (status.isPermanentlyDenied) return colorScheme.error;
    if (status.isDenied) return colorScheme.onSurfaceVariant;
    if (status.isRestricted) return colorScheme.error;
    if (status.isLimited) return colorScheme.tertiary;
    if (status.isProvisional) return colorScheme.secondary;
    return colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final permissionName = permission.toString().split('.').last;
    final statusText = status.name;
    final serviceText =
        serviceStatus != null ? ' (service: ${serviceStatus!.name})' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: SelectableText(
              permissionName,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _statusColor.withAlpha(80)),
            ),
            child: SelectableText(
              statusText + serviceText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _statusColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
