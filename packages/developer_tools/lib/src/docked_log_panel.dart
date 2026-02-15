import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';

/// Docked log panel that shows recent entries from enabled log sources.
class DockedLogPanel extends StatelessWidget {
  const DockedLogPanel({
    required this.config,
    super.key,
  });

  final DeveloperToolsDockConfig config;

  @override
  Widget build(BuildContext context) {
    if (!config.enabled || config.enabledLogSourceIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final registry = DeveloperToolsLogSourceRegistry.instance;
    final sources = config.enabledLogSourceIds
        .map((id) => registry.get(id))
        .whereType<DeveloperToolsLogSource>()
        .toList();

    if (sources.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: Listenable.merge(
        [
          registry.listenable,
          ...sources.map((s) => s.listenable),
        ],
      ),
      builder: (BuildContext context, Widget? child) {
        final allEntries = <DeveloperToolsLogEntry>[];
        for (final source in sources) {
          allEntries.addAll(source.entries);
        }
        allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final visible = allEntries.take(config.maxVisibleEntries).toList();

        if (visible.isEmpty) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final maxHeight = 160.0;

        return Material(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
          elevation: 4,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.terminal,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Log',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: visible.length,
                    itemBuilder: (BuildContext context, int index) {
                      final entry = visible[index];
                      return _DockedLogEntry(entry: entry);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DockedLogEntry extends StatelessWidget {
  const _DockedLogEntry({required this.entry});

  final DeveloperToolsLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (entry.level) {
      DeveloperToolsLogLevel.info => theme.colorScheme.primary,
      DeveloperToolsLogLevel.warning => theme.colorScheme.tertiary,
      DeveloperToolsLogLevel.error => theme.colorScheme.error,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              entry.timeString,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.sourceId,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              entry.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
