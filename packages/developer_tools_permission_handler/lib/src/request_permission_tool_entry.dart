import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// A [DeveloperToolEntry] that opens a dialog to select a permission and
/// request it, then shows the resulting status.
///
/// Useful for testing permission flows (e.g. camera, location) during
/// development without navigating through the app's normal UI.
DeveloperToolEntry requestPermissionToolEntry({
  String? sectionLabel,
}) {
  return DeveloperToolEntry(
    title: 'Request Permission',
    sectionLabel: sectionLabel,
    description: 'Select a permission and request it',
    icon: Icons.touch_app,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _RequestPermissionDialog();
        },
      );
    },
  );
}

class _RequestPermissionDialog extends StatefulWidget {
  const _RequestPermissionDialog();

  @override
  State<_RequestPermissionDialog> createState() =>
      _RequestPermissionDialogState();
}

class _RequestPermissionDialogState extends State<_RequestPermissionDialog> {
  Permission? _selectedPermission;
  bool _requesting = false;
  PermissionStatus? _resultStatus;
  String? _error;

  List<Permission> get _permissions =>
      Permission.values.where((p) => p != Permission.unknown).toList();

  Future<void> _request() async {
    final permission = _selectedPermission;
    if (permission == null) return;

    setState(() {
      _requesting = true;
      _resultStatus = null;
      _error = null;
    });

    try {
      final status = await permission.request();
      if (mounted) {
        setState(() {
          _requesting = false;
          _resultStatus = status;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _requesting = false;
          _error = e.toString();
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _resultStatus = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.touch_app, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Request Permission'),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<Permission>(
              value: _selectedPermission,
              decoration: const InputDecoration(
                labelText: 'Permission',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items:
                  _permissions
                      .map(
                        (p) => DropdownMenuItem<Permission>(
                          value: p,
                          child: Text(
                            p.toString().split('.').last,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      )
                      .toList(),
              onChanged:
                  _requesting
                      ? null
                      : (Permission? value) {
                        setState(() {
                          _selectedPermission = value;
                          _resultStatus = null;
                          _error = null;
                        });
                      },
            ),
            if (_requesting) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_resultStatus != null && !_requesting) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _resultStatus!.isGranted
                          ? colorScheme.primaryContainer
                          : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _resultStatus!.isGranted
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color:
                          _resultStatus!.isGranted
                              ? colorScheme.primary
                              : colorScheme.onErrorContainer,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SelectableText(
                        'Result: ${_resultStatus!.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color:
                              _resultStatus!.isGranted
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_error != null && !_requesting) ...[
              const SizedBox(height: 16),
              SelectableText(
                _error!,
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        if (_resultStatus != null || _error != null)
          TextButton(
            onPressed: _requesting ? null : _reset,
            child: const Text('Clear'),
          ),
        FilledButton(
          onPressed:
              _requesting || _selectedPermission == null ? null : _request,
          child: const Text('Request'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
