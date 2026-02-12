import 'dart:convert';

import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single [DeveloperToolEntry] with quick actions for shared preferences:
/// view summary, export as JSON, and clear all.
///
/// If [instance] is provided, it will be used instead of calling
/// [SharedPreferences.getInstance].
DeveloperToolEntry preferencesActionsToolEntry({
  String? sectionLabel,
  SharedPreferences? instance,
}) {
  return DeveloperToolEntry(
    title: 'Preferences Actions',
    sectionLabel: sectionLabel,
    description: 'Export, clear, and manage preferences',
    icon: Icons.settings_applications,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return _PreferencesActionsDialog(instance: instance);
        },
      );
    },
  );
}

class _PreferencesActionsDialog extends StatefulWidget {
  const _PreferencesActionsDialog({this.instance});

  final SharedPreferences? instance;

  @override
  State<_PreferencesActionsDialog> createState() =>
      _PreferencesActionsDialogState();
}

class _PreferencesActionsDialogState extends State<_PreferencesActionsDialog> {
  SharedPreferences? _prefs;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    if (widget.instance != null) {
      _prefs = widget.instance;
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings_applications, size: 24),
          SizedBox(width: 8),
          Text('Preferences Actions'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child:
            _loading
                ? const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                )
                : _error != null
                ? Text('Error: $_error')
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Summary
                    _SummaryCard(prefs: _prefs!),
                    const SizedBox(height: 16),
                    // Actions
                    _ActionTile(
                      icon: Icons.download,
                      iconColor: Colors.blue,
                      title: 'Export as JSON',
                      subtitle: 'Copy all preferences as JSON to clipboard',
                      onTap: _exportAsJson,
                    ),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.upload,
                      iconColor: Colors.teal,
                      title: 'Import from JSON',
                      subtitle: 'Import preferences from JSON in clipboard',
                      onTap: _importFromJson,
                    ),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.refresh,
                      iconColor: Colors.orange,
                      title: 'Reload Preferences',
                      subtitle: 'Refresh the cache from platform storage',
                      onTap: () async {
                        await _prefs!.reload();
                        setState(() {});
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preferences reloaded'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.delete_forever,
                      iconColor: theme.colorScheme.error,
                      title: 'Clear All Preferences',
                      subtitle:
                          'Remove all stored preferences (cannot be undone)',
                      onTap: _confirmClearAll,
                    ),
                  ],
                ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _exportAsJson() async {
    final prefs = _prefs!;
    final keys = prefs.getKeys().toList()..sort();
    final map = <String, Object?>{};
    for (final key in keys) {
      map[key] = prefs.get(key);
    }
    final json = const JsonEncoder.withIndent('  ').convert(map);
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${keys.length} preference${keys.length == 1 ? '' : 's'} to clipboard',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _importFromJson() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == null || data!.text!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clipboard is empty'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final Map<String, dynamic> map = jsonDecode(data.text!);
      final prefs = _prefs!;
      int imported = 0;

      for (final entry in map.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value is String) {
          await prefs.setString(key, value);
          imported++;
        } else if (value is int) {
          await prefs.setInt(key, value);
          imported++;
        } else if (value is double) {
          await prefs.setDouble(key, value);
          imported++;
        } else if (value is bool) {
          await prefs.setBool(key, value);
          imported++;
        } else if (value is List) {
          await prefs.setStringList(
            key,
            value.map((e) => e.toString()).toList(),
          );
          imported++;
        }
      }

      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported $imported preference${imported == 1 ? '' : 's'}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _confirmClearAll() async {
    final keyCount = _prefs!.getKeys().length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Preferences'),
          content: Text(
            'This will permanently delete all $keyCount stored preference${keyCount == 1 ? '' : 's'}.\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _prefs!.clear();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All preferences cleared'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

// ── Shared widgets ──────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keys = prefs.getKeys();

    int stringCount = 0;
    int intCount = 0;
    int doubleCount = 0;
    int boolCount = 0;
    int listCount = 0;

    for (final key in keys) {
      final value = prefs.get(key);
      if (value is bool) {
        boolCount++;
      } else if (value is int) {
        intCount++;
      } else if (value is double) {
        doubleCount++;
      } else if (value is List) {
        listCount++;
      } else if (value is String) {
        stringCount++;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${keys.length} Stored Preference${keys.length == 1 ? '' : 's'}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (stringCount > 0)
                _TypeBadge('String', stringCount, Colors.green),
              if (intCount > 0) _TypeBadge('int', intCount, Colors.blue),
              if (doubleCount > 0)
                _TypeBadge('double', doubleCount, Colors.teal),
              if (boolCount > 0) _TypeBadge('bool', boolCount, Colors.orange),
              if (listCount > 0) _TypeBadge('List', listCount, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge(this.label, this.count, this.color);

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
