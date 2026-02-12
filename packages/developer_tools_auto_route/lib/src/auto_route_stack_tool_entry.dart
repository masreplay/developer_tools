import 'package:auto_route/auto_route.dart';
import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';

/// Single [DeveloperToolEntry] that opens a dialog showing the full navigation
/// stack of the auto_route [RoutingController].
///
/// Each entry in the stack is displayed with its index, route name, and path.
/// The currently active route is visually highlighted.
DeveloperToolEntry autoRouteStackToolEntry(
  RoutingController router, {
  String? sectionLabel,
}) {
  return DeveloperToolEntry(
    title: 'Navigation Stack',
    sectionLabel: sectionLabel,
    description: _stackSummary(router),
    icon: Icons.layers,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return _NavigationStackDialog(router: router);
        },
      );
    },
  );
}

String _stackSummary(RoutingController router) {
  try {
    final count = router.stackData.length;
    return '$count page${count == 1 ? '' : 's'} in stack';
  } catch (_) {
    return 'View the current navigation stack.';
  }
}

class _NavigationStackDialog extends StatelessWidget {
  const _NavigationStackDialog({required this.router});

  final RoutingController router;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: router,
      builder: (BuildContext context, Widget? child) {
        List<RouteData> stackData;
        try {
          stackData = router.stackData;
        } catch (_) {
          stackData = [];
        }

        String currentName;
        try {
          currentName = router.current.name;
        } catch (_) {
          currentName = '';
        }

        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.layers, size: 24),
              const SizedBox(width: 8),
              Text('Navigation Stack (${stackData.length})'),
            ],
          ),
          content: SizedBox(
            width: 480,
            height: 480,
            child: stackData.isEmpty
                ? const Center(
                    child: Text(
                      'Stack is empty.\nNo pages have been pushed yet.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: stackData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final data = stackData[index];
                      final isCurrent = data.name == currentName;
                      return _StackEntryTile(
                        index: index,
                        routeData: data,
                        isCurrent: isCurrent,
                        onTap: () => _showRouteDetails(context, data),
                      );
                    },
                  ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showRouteDetails(BuildContext context, RouteData data) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(data.name),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow('Name', data.name),
                _DetailRow('Path', data.path),
                _DetailRow('Match', _safe(() => data.match)),
                _DetailRow(
                  'Path Params',
                  _safe(() => _formatMap(data.pathParams.rawMap)),
                ),
                _DetailRow(
                  'Query Params',
                  _safe(() => _formatMap(data.queryParams.rawMap)),
                ),
                _DetailRow('Fragment', _safe(() => data.fragment)),
                _DetailRow(
                  'Args',
                  _safe(() => data.args?.toString() ?? '(none)'),
                ),
                _DetailRow(
                  'Meta',
                  _safe(() {
                    final meta = data.meta;
                    return meta.isEmpty ? '(empty)' : meta.toString();
                  }),
                ),
                _DetailRow(
                  'Is Active',
                  _safe(() => data.isActive.toString()),
                ),
                _DetailRow(
                  'Has Pending Children',
                  _safe(() => data.hasPendingChildren.toString()),
                ),
                _DetailRow(
                  'Parent',
                  _safe(() => data.parent?.name ?? '(root)'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Back'),
            ),
          ],
        );
      },
    );
  }

  static String _safe(String Function() getter, [String fallback = 'N/A']) {
    try {
      final value = getter();
      return value.isEmpty ? '(empty)' : value;
    } catch (_) {
      return fallback;
    }
  }

  static String _formatMap(Map<String, dynamic> map) {
    if (map.isEmpty) return '(none)';
    return map.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}

class _StackEntryTile extends StatelessWidget {
  const _StackEntryTile({
    required this.index,
    required this.routeData,
    required this.isCurrent,
    this.onTap,
  });

  final int index;
  final RouteData routeData;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isCurrent
            ? theme.colorScheme.primaryContainer.withAlpha(128)
            : theme.colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: isCurrent
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  )
                : null,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrent
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              routeData.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'current',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        routeData.path,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

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
            width: 130,
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
