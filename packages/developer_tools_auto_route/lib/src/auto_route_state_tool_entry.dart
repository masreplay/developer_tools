import 'package:auto_route/auto_route.dart';
import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';

/// Single [DeveloperToolEntry] that opens a dialog showing the router state,
/// current segments, route hierarchy, and child controllers.
DeveloperToolEntry autoRouteStateToolEntry(
  RoutingController router, {
  String? sectionLabel,
}) {
  return DeveloperToolEntry(
    title: 'Router State',
    sectionLabel: sectionLabel,
    description: _stateSummary(router),
    icon: Icons.settings_ethernet,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return _RouterStateDialog(router: router);
        },
      );
    },
  );
}

String _stateSummary(RoutingController router) {
  try {
    final childCount = router.childControllers.length;
    final canPop = router.canPop();
    return 'canPop: $canPop • $childCount child controller${childCount == 1 ? '' : 's'}';
  } catch (_) {
    return 'View router state flags, segments, and hierarchy.';
  }
}

class _RouterStateDialog extends StatelessWidget {
  const _RouterStateDialog({required this.router});

  final RoutingController router;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: router,
      builder: (BuildContext context, Widget? child) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings_ethernet, size: 24),
              SizedBox(width: 8),
              Text('Router State'),
            ],
          ),
          content: SizedBox(
            width: 480,
            height: 480,
            child: ListView(
              children: [
                _SectionHeader('State Flags'),
                _BoolRow(
                  'Is Root',
                  _safeBool(() => router.isRoot),
                  Icons.account_tree,
                ),
                _BoolRow(
                  'Is Top Most',
                  _safeBool(() => router.isTopMost),
                  Icons.vertical_align_top,
                ),
                _BoolRow(
                  'Can Pop',
                  _safeBool(() => router.canPop()),
                  Icons.arrow_back,
                ),
                _BoolRow(
                  'Can Navigate Back',
                  _safeBool(() => router.canNavigateBack),
                  Icons.undo,
                ),
                _BoolRow(
                  'Has Entries',
                  _safeBool(() => router.hasEntries),
                  Icons.list,
                ),
                _BoolRow(
                  'Managed By Widget',
                  _safeBool(() => router.managedByWidget),
                  Icons.widgets,
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  'Page Count',
                  _safe(() => router.pageCount.toString()),
                ),
                _InfoRow(
                  'Child Controllers',
                  _safe(() => router.childControllers.length.toString()),
                ),
                _InfoRow(
                  'State Hash',
                  _safe(() => router.stateHash.toString()),
                ),
                const SizedBox(height: 12),
                _SectionHeader('Current Segments'),
                _buildSegments(),
                const SizedBox(height: 12),
                _SectionHeader('Current Hierarchy'),
                _buildHierarchy(),
                if (_hasChildControllers()) ...[
                  const SizedBox(height: 12),
                  _SectionHeader('Child Controllers'),
                  _buildChildControllers(),
                ],
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
      },
    );
  }

  Widget _buildSegments() {
    try {
      final segments = router.currentSegments;
      if (segments.isEmpty) {
        return const _EmptyText('(no segments)');
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < segments.length; i++)
            _SegmentTile(index: i, segment: segments[i]),
        ],
      );
    } catch (_) {
      return const _EmptyText('N/A');
    }
  }

  Widget _buildHierarchy() {
    try {
      final hierarchy = router.currentHierarchy();
      if (hierarchy.isEmpty) {
        return const _EmptyText('(empty)');
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            hierarchy.map((segment) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  segment.toString(),
                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                ),
              );
            }).toList(),
      );
    } catch (_) {
      return const _EmptyText('N/A');
    }
  }

  bool _hasChildControllers() {
    try {
      return router.childControllers.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Widget _buildChildControllers() {
    try {
      final children = router.childControllers;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++)
            _ChildControllerTile(index: i, controller: children[i]),
        ],
      );
    } catch (_) {
      return const _EmptyText('N/A');
    }
  }

  static String _safe(String Function() getter, [String fallback = 'N/A']) {
    try {
      return getter();
    } catch (_) {
      return fallback;
    }
  }

  static bool? _safeBool(bool Function() getter) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }
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
            width: 140,
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoolRow extends StatelessWidget {
  const _BoolRow(this.label, this.value, this.icon);

  final String label;
  final bool? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color statusColor;
    final IconData statusIcon;

    if (value == null) {
      statusColor = theme.colorScheme.onSurfaceVariant;
      statusIcon = Icons.help_outline;
    } else if (value!) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = theme.colorScheme.onSurfaceVariant;
      statusIcon = Icons.cancel_outlined;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Icon(statusIcon, size: 18, color: statusColor),
          const SizedBox(width: 4),
          Text(
            value?.toString() ?? 'N/A',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({required this.index, required this.segment});

  final int index;
  final RouteMatch segment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${segment.name}  (${segment.stringMatch})',
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildControllerTile extends StatelessWidget {
  const _ChildControllerTile({required this.index, required this.controller});

  final int index;
  final RoutingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String type = controller.runtimeType.toString();
    String currentRoute;
    try {
      currentRoute = controller.current.name;
    } catch (_) {
      currentRoute = '(unknown)';
    }

    int pageCount;
    try {
      pageCount = controller.pageCount;
    } catch (_) {
      pageCount = 0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#$index  $type',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Current: $currentRoute  •  Pages: $pageCount',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
