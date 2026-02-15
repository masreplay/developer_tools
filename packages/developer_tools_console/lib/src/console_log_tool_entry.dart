import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'console_log.dart';
import 'console_log_entry.dart';

/// A [DeveloperToolEntry] that shows the console log (Flutter errors, etc.).
DeveloperToolEntry consoleLogToolEntry(
  BuildContext context, {
  String? sectionLabel,
}) {
  return DeveloperToolEntry(
    title: 'Console log',
    sectionLabel: sectionLabel,
    description: 'View Flutter errors and exceptions captured globally',
    icon: Icons.bug_report,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return _ConsoleLogDialog();
        },
      );
    },
  );
}

class _ConsoleLogDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final log = ConsoleLog.instance;

    return AlertDialog(
      title: const Text('Console log'),
      content: ListenableBuilder(
        listenable: log.listenable,
        builder: (BuildContext context, Widget? child) {
          final entries = log.entries.reversed.toList();
          return SizedBox(
            width: 480,
            height: 400,
            child: entries.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No errors captured yet.\n\n'
                        'FlutterError.onError and PlatformDispatcher.onError '
                        'are hooked when you add DeveloperToolsConsole.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (BuildContext context, int index) {
                      final entry = entries[index];
                      final time =
                          '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
                          '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
                          '${entry.timestamp.second.toString().padLeft(2, '0')}';

                      return ListTile(
                        dense: true,
                        leading: Icon(
                          _iconForLevel(entry.level),
                          size: 20,
                          color: _colorForLevel(context, entry.level),
                        ),
                        title: SelectableText(
                          entry.message,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                        subtitle: Text(
                          '$time  •  ${entry.level.name}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () => _showEntryDetails(context, entry),
                      );
                    },
                  ),
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            log.clear();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Clear log'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  IconData _iconForLevel(DeveloperToolsLogLevel level) {
    return switch (level) {
      DeveloperToolsLogLevel.info => Icons.info_outline,
      DeveloperToolsLogLevel.warning => Icons.warning_amber,
      DeveloperToolsLogLevel.error => Icons.error_outline,
    };
  }

  Color _colorForLevel(BuildContext context, DeveloperToolsLogLevel level) {
    final scheme = Theme.of(context).colorScheme;
    return switch (level) {
      DeveloperToolsLogLevel.info => scheme.primary,
      DeveloperToolsLogLevel.warning => scheme.tertiary,
      DeveloperToolsLogLevel.error => scheme.error,
    };
  }

  void _showEntryDetails(BuildContext context, ConsoleLogEntry entry) {
    final text = StringBuffer(entry.message);
    if (entry.stackTrace != null) {
      text.writeln('\n\nStack trace:');
      text.writeln(entry.stackTrace);
    }
    if (entry.details != null) {
      text.writeln('\n\nDetails:');
      text.writeln(entry.details);
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error details'),
        content: SingleChildScrollView(
          child: SelectableText(
            text.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text.toString()));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              }
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
