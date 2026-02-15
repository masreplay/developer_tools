import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alice/alice.dart';

/// A [DeveloperToolEntry] that opens a dialog showing Alice inspector status
/// (e.g. whether the inspector is currently opened) with copy-to-clipboard.
///
/// Useful for debugging navigation or confirming inspector state. Requires an
/// [Alice] instance; if null, the dialog explains that the instance must be
/// provided.
DeveloperToolEntry inspectorStatusOverviewToolEntry({
  String? sectionLabel,
  Alice? instance,
}) {
  return DeveloperToolEntry(
    title: 'Inspector Status Overview',
    sectionLabel: sectionLabel,
    description: 'View Alice inspector state and copy status',
    icon: Icons.info_outline,
    debugInfo: (BuildContext context) async {
      if (instance == null) return 'Alice: instance not provided.';
      final opened = instance.isInspectorOpened;
      final hasKey = instance.getNavigatorKey() != null;
      return 'Alice: inspectorOpened=$opened, navigatorKeySet=$hasKey';
    },
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return _InspectorStatusOverviewDialog(instance: instance);
        },
      );
    },
  );
}

class _InspectorStatusOverviewDialog extends StatelessWidget {
  const _InspectorStatusOverviewDialog({this.instance});

  final Alice? instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (instance == null) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Inspector Status')),
          ],
        ),
        content: SelectableText(
          'Alice instance was not provided to DeveloperToolsAlice.\n\n'
          'Pass your Alice instance when building the extension:\n'
          'DeveloperToolsAlice(instance: alice)',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final alice = instance!;
    final isOpened = alice.isInspectorOpened;
    final hasNavigatorKey = alice.getNavigatorKey() != null;

    final buffer = StringBuffer();
    buffer.writeln('Inspector opened: $isOpened');
    buffer.writeln('Navigator key set: $hasNavigatorKey');
    final report = buffer.toString();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Inspector Status')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusRow(
              label: 'Inspector opened',
              value: isOpened.toString(),
              theme: theme,
            ),
            const SizedBox(height: 8),
            _StatusRow(
              label: 'Navigator key set',
              value: hasNavigatorKey.toString(),
              theme: theme,
            ),
            const SizedBox(height: 16),
            SelectableText(
              report,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: report));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
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

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
