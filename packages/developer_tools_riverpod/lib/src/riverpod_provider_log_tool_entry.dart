import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';

import 'developer_tools_riverpod_base.dart';

/// Single `DeveloperToolEntry` that shows the Riverpod provider log and
/// allows clearing it.
DeveloperToolEntry riverpodProviderLogToolEntry(BuildContext context) {
  return DeveloperToolEntry(
    title: 'Riverpod provider log',
    description: 'Inspect and clear Riverpod provider lifecycle events.',
    icon: Icons.bug_report,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          final entries = riverpodProviderLog.entries.reversed.toList();

          return AlertDialog(
            title: const Text('Riverpod provider log'),
            content: entries.isEmpty
                ? const Text('No provider events recorded yet.')
                : SizedBox(
                    width: 420,
                    height: 420,
                    child: ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (BuildContext context, int index) {
                        final entry = entries[index];
                        final time =
                            '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}';

                        return ListTile(
                          dense: true,
                          leading: Icon(switch (entry.type) {
                            RiverpodProviderEventType.add =>
                              Icons.add_circle_outline,
                            RiverpodProviderEventType.update =>
                              Icons.change_circle_outlined,
                            RiverpodProviderEventType.fail =>
                              Icons.error_outline,
                            RiverpodProviderEventType.dispose =>
                              Icons.remove_circle_outline,
                            RiverpodProviderEventType.mutationStart =>
                              Icons.play_circle_outline,
                            RiverpodProviderEventType.mutationSuccess =>
                              Icons.check_circle_outline,
                            RiverpodProviderEventType.mutationError =>
                              Icons.error_outline,
                            RiverpodProviderEventType.mutationReset =>
                              Icons.refresh,
                          }, size: 20),
                          title: Text(
                            '[${entry.type.name.toUpperCase()}] ${entry.providerName}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            '$time  •  ${entry.message}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  riverpodProviderLog.clear();
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Clear log'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}
