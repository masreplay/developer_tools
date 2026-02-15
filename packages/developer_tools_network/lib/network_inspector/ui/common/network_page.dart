import 'package:developer_tools_network/network_inspector/core/network_core.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_theme.dart';
import 'package:flutter/material.dart';

/// Common page widget which is used across NetworkInspector pages.
class NetworkPage extends StatelessWidget {
  const NetworkPage({super.key, required this.core, required this.child});

  final NetworkInspectorCore core;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          core.configuration.directionality ?? Directionality.of(context),
      child: Theme(data: NetworkTheme.getTheme(), child: child),
    );
  }
}
