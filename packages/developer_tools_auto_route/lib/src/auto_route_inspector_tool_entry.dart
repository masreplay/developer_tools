import 'package:auto_route/auto_route.dart';
import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';

/// Single [DeveloperToolEntry] that opens a dialog showing the current route
/// information including name, path, URL, params, query params, fragment, args,
/// meta, and breadcrumbs.
DeveloperToolEntry autoRouteInspectorToolEntry(
  RoutingController router, {
  String? sectionLabel,
}) {
  return DeveloperToolEntry(
    title: 'Route Inspector',
    sectionLabel: sectionLabel,
    description: _currentRouteSummary(router),
    icon: Icons.route,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return _RouteInspectorDialog(router: router);
        },
      );
    },
  );
}

String _currentRouteSummary(RoutingController router) {
  try {
    final name = router.current.name;
    final path = router.currentPath;
    return 'Current: $name ($path)';
  } catch (_) {
    return 'Inspect current route details, params, and breadcrumbs.';
  }
}

class _RouteInspectorDialog extends StatelessWidget {
  const _RouteInspectorDialog({required this.router});

  final RoutingController router;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: router,
      builder: (BuildContext context, Widget? child) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.route, size: 24),
              SizedBox(width: 8),
              Text('Route Inspector'),
            ],
          ),
          content: SizedBox(
            width: 480,
            height: 480,
            child: ListView(
              children: [
                _SectionHeader('Current Route'),
                _InfoRow('Name', _safe(() => router.current.name)),
                _InfoRow('Path', _safe(() => router.current.path)),
                _InfoRow('Match', _safe(() => router.current.match)),
                _InfoRow('Current Path', _safe(() => router.currentPath)),
                _InfoRow('Current URL', _safe(() => router.currentUrl)),
                _InfoRow(
                  'Fragment',
                  _safe(() => router.current.fragment),
                ),
                _InfoRow(
                  'Is Active',
                  _safe(() => router.current.isActive.toString()),
                ),
                const SizedBox(height: 8),
                _SectionHeader('Parameters'),
                _InfoRow(
                  'Path Params',
                  _safe(() => _formatParams(router.current.pathParams)),
                ),
                _InfoRow(
                  'Query Params',
                  _safe(() => _formatParams(router.current.queryParams)),
                ),
                _InfoRow(
                  'Args',
                  _safe(
                    () => router.current.args?.toString() ?? '(none)',
                  ),
                ),
                _InfoRow(
                  'Meta',
                  _safe(() {
                    final meta = router.current.meta;
                    return meta.isEmpty ? '(empty)' : meta.toString();
                  }),
                ),
                const SizedBox(height: 8),
                _SectionHeader('Top Route'),
                _InfoRow('Name', _safe(() => router.topRoute.name)),
                _InfoRow('Path', _safe(() => router.topRoute.path)),
                const SizedBox(height: 8),
                _SectionHeader('Breadcrumbs'),
                _buildBreadcrumbs(),
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

  Widget _buildBreadcrumbs() {
    try {
      final breadcrumbs = router.current.breadcrumbs;
      if (breadcrumbs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('(empty)', style: TextStyle(fontSize: 13)),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (int i = 0; i < breadcrumbs.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.chevron_right, size: 16),
                ),
              Chip(
                label: Text(
                  breadcrumbs[i].name,
                  style: const TextStyle(fontSize: 12),
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ],
        ),
      );
    } catch (_) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text('N/A', style: TextStyle(fontSize: 13)),
      );
    }
  }

  static String _safe(String Function() getter, [String fallback = 'N/A']) {
    try {
      final value = getter();
      return value.isEmpty ? '(empty)' : value;
    } catch (_) {
      return fallback;
    }
  }

  static String _formatParams(Parameters params) {
    final map = params.rawMap;
    if (map.isEmpty) return '(none)';
    return map.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}

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
            width: 120,
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
