import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single [DeveloperToolEntry] that opens a full-featured preferences browser
/// dialog. Supports viewing, searching, editing, adding, and deleting
/// individual shared preference entries.
DeveloperToolEntry preferencesBrowserToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Preferences Browser',
    sectionLabel: sectionLabel,
    description: 'Browse, search, edit, add, and delete preferences',
    icon: Icons.storage,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _PreferencesBrowserDialog();
        },
      );
    },
  );
}

class _PreferencesBrowserDialog extends StatefulWidget {
  const _PreferencesBrowserDialog();

  @override
  State<_PreferencesBrowserDialog> createState() =>
      _PreferencesBrowserDialogState();
}

class _PreferencesBrowserDialogState extends State<_PreferencesBrowserDialog> {
  SharedPreferences? _prefs;
  String _searchQuery = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
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

  List<String> get _filteredKeys {
    if (_prefs == null) return [];
    final keys = _prefs!.getKeys().toList()..sort();
    if (_searchQuery.isEmpty) return keys;
    final query = _searchQuery.toLowerCase();
    return keys.where((k) => k.toLowerCase().contains(query)).toList();
  }

  String _getValueDisplay(String key) {
    final prefs = _prefs!;
    final value = prefs.get(key);
    if (value == null) return 'null';
    return value.toString();
  }

  String _getTypeLabel(String key) {
    final value = _prefs!.get(key);
    if (value is bool) return 'bool';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is List) return 'List<String>';
    if (value is String) return 'String';
    return value.runtimeType.toString();
  }

  Color _getTypeColor(String key, ThemeData theme) {
    final value = _prefs!.get(key);
    if (value is bool) return Colors.orange;
    if (value is int) return Colors.blue;
    if (value is double) return Colors.teal;
    if (value is List) return Colors.purple;
    if (value is String) return Colors.green;
    return theme.colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.storage, size: 24),
          const SizedBox(width: 8),
          const Expanded(child: Text('Preferences Browser')),
          if (!_loading && _prefs != null)
            Text(
              '${_filteredKeys.length} key${_filteredKeys.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      content: SizedBox(
        width: 520,
        height: 520,
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : _buildContent(theme),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: _prefs == null ? null : _showAddDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
        TextButton.icon(
          onPressed: _loadPreferences,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reload'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      children: [
        // Search bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search keys...',
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 8),
        // Preferences list
        Expanded(
          child:
              _filteredKeys.isEmpty
                  ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No preferences stored'
                          : 'No preferences matching "$_searchQuery"',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                  : ListView.separated(
                    itemCount: _filteredKeys.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final key = _filteredKeys[index];
                      return _PreferenceItem(
                        prefKey: key,
                        value: _getValueDisplay(key),
                        typeLabel: _getTypeLabel(key),
                        typeColor: _getTypeColor(key, theme),
                        onEdit: () => _showEditDialog(key),
                        onDelete: () => _confirmDelete(key),
                        onCopy: () => _copyValue(key),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Future<void> _showAddDialog() async {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    String selectedType = 'String';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Preference'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: keyController,
                      decoration: const InputDecoration(
                        labelText: 'Key',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'String',
                          child: Text('String'),
                        ),
                        DropdownMenuItem(value: 'int', child: Text('int')),
                        DropdownMenuItem(
                          value: 'double',
                          child: Text('double'),
                        ),
                        DropdownMenuItem(value: 'bool', child: Text('bool')),
                        DropdownMenuItem(
                          value: 'List<String>',
                          child: Text('List<String>'),
                        ),
                      ],
                      onChanged: (v) {
                        setDialogState(() => selectedType = v ?? 'String');
                      },
                    ),
                    const SizedBox(height: 12),
                    if (selectedType == 'bool')
                      DropdownButtonFormField<String>(
                        value: 'true',
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'true', child: Text('true')),
                          DropdownMenuItem(
                            value: 'false',
                            child: Text('false'),
                          ),
                        ],
                        onChanged: (v) => valueController.text = v ?? 'true',
                      )
                    else
                      TextField(
                        controller: valueController,
                        decoration: InputDecoration(
                          labelText: 'Value',
                          isDense: true,
                          border: const OutlineInputBorder(),
                          hintText:
                              selectedType == 'List<String>'
                                  ? 'item1, item2, item3'
                                  : null,
                        ),
                        maxLines: selectedType == 'List<String>' ? 3 : 1,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final key = keyController.text.trim();
                    if (key.isEmpty) return;
                    await _savePreference(
                      key,
                      valueController.text,
                      selectedType,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditDialog(String key) async {
    final value = _prefs!.get(key);
    final typeLabel = _getTypeLabel(key);
    final controller = TextEditingController(
      text: value is List ? value.join(', ') : value?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit: $key'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(label: Text(typeLabel)),
                const SizedBox(height: 12),
                if (value is bool)
                  DropdownButtonFormField<String>(
                    value: value.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'true', child: Text('true')),
                      DropdownMenuItem(value: 'false', child: Text('false')),
                    ],
                    onChanged: (v) => controller.text = v ?? 'true',
                  )
                else
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Value',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      hintText:
                          typeLabel == 'List<String>'
                              ? 'item1, item2, item3'
                              : null,
                    ),
                    maxLines: typeLabel == 'List<String>' ? 3 : 1,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await _savePreference(key, controller.text, typeLabel);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePreference(String key, String rawValue, String type) async {
    final prefs = _prefs!;
    switch (type) {
      case 'String':
        await prefs.setString(key, rawValue);
      case 'int':
        final parsed = int.tryParse(rawValue);
        if (parsed != null) await prefs.setInt(key, parsed);
      case 'double':
        final parsed = double.tryParse(rawValue);
        if (parsed != null) await prefs.setDouble(key, parsed);
      case 'bool':
        await prefs.setBool(key, rawValue.toLowerCase() == 'true');
      case 'List<String>':
        final items = rawValue
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty);
        await prefs.setStringList(key, items.toList());
    }
    setState(() {});
  }

  Future<void> _confirmDelete(String key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Preference'),
          content: Text('Are you sure you want to delete "$key"?'),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _prefs!.remove(key);
      setState(() {});
    }
  }

  void _copyValue(String key) {
    final value = _prefs!.get(key);
    final text = '$key: $value';
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied "$key" to clipboard'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _PreferenceItem extends StatelessWidget {
  const _PreferenceItem({
    required this.prefKey,
    required this.value,
    required this.typeLabel,
    required this.typeColor,
    required this.onEdit,
    required this.onDelete,
    required this.onCopy,
  });

  final String prefKey;
  final String value;
  final String typeLabel;
  final Color typeColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: typeColor.withAlpha(80)),
              ),
              child: Text(
                typeLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: typeColor,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Key + value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prefKey,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Actions
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: onCopy,
              tooltip: 'Copy',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 16,
                color: theme.colorScheme.error,
              ),
              onPressed: onDelete,
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ),
    );
  }
}
