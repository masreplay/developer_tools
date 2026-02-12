import 'package:auto_route/auto_route.dart';
import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'auto_route_inspector_tool_entry.dart';
import 'auto_route_stack_tool_entry.dart';
import 'auto_route_state_tool_entry.dart';

/// Auto Route integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// You must provide the [router] instance (typically your generated
/// `RootStackRouter`) so the extension can inspect navigation state:
///
/// ```dart
/// final _appRouter = AppRouter();
///
/// MaterialApp.router(
///   routerConfig: _appRouter.config(),
///   builder: DeveloperTools.builder(
///     extensions: [DeveloperToolsAutoRoute(router: _appRouter)],
///   ),
/// );
/// ```
class DeveloperToolsAutoRoute extends DeveloperToolsExtension {
  /// Creates an Auto Route developer tools extension.
  ///
  /// The [router] is typically the generated `RootStackRouter` (e.g.
  /// `AppRouter()`). Since [RoutingController] is a [ChangeNotifier],
  /// the inspector dialogs update live when navigation state changes.
  const DeveloperToolsAutoRoute({
    super.key,
    super.packageName = 'auto_route',
    super.displayName = 'Auto Route',
    required this.router,
  });

  /// The [RoutingController] instance to inspect.
  ///
  /// This is typically your generated `RootStackRouter` (e.g. `AppRouter()`).
  final RoutingController router;

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      autoRouteInspectorToolEntry(router, sectionLabel: sectionLabel),
      autoRouteStackToolEntry(router, sectionLabel: sectionLabel),
      autoRouteStateToolEntry(router, sectionLabel: sectionLabel),
    ];
  }

  @override
  Future<String?> debugInfo(BuildContext context) async {
    final buffer = StringBuffer();
    try {
      buffer.writeln('Current Route: ${router.current.name}');
      buffer.writeln('Current Path: ${router.currentPath}');
      buffer.writeln('Current URL: ${router.currentUrl}');
    } catch (_) {
      buffer.writeln('Current Route: (unavailable)');
    }
    try {
      final stack = router.stackData;
      buffer.writeln('Stack Depth: ${stack.length}');
      for (int i = 0; i < stack.length; i++) {
        buffer.writeln('  [$i] ${stack[i].name} (${stack[i].path})');
      }
    } catch (_) {
      buffer.writeln('Stack: (unavailable)');
    }
    try {
      buffer.writeln('Can Pop: ${router.canPop()}');
      buffer.writeln('Is Root: ${router.isRoot}');
      buffer.writeln('Child Controllers: ${router.childControllers.length}');
    } catch (_) {}
    return buffer.toString();
  }
}
