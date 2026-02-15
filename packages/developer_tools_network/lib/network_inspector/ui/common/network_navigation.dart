import 'package:developer_tools_network/network_inspector/core/network_core.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/page/network_call_details_page.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/page/network_calls_list_page.dart';
import 'package:developer_tools_network/network_inspector/ui/stats/network_stats_page.dart';
import 'package:flutter/material.dart';

/// Simple navigation helper class for NetworkInspector.
class NetworkNavigation {
  /// Navigates to calls list page.
  static Future<void> navigateToCallsList({required NetworkInspectorCore core}) {
    return _navigateToPage(core: core, child: NetworkCallsListPage(core: core));
  }

  /// Navigates to call details page.
  static Future<void> navigateToCallDetails({
    required NetworkHttpCall call,
    required NetworkInspectorCore core,
  }) {
    return _navigateToPage(
      core: core,
      child: NetworkCallDetailsPage(call: call, core: core),
    );
  }

  /// Navigates to stats page.
  static Future<void> navigateToStats({required NetworkInspectorCore core}) {
    return _navigateToPage(core: core, child: NetworkStatsPage(core));
  }

  /// Common helper method which checks whether context is available for
  /// navigation and navigates to a specific page.
  static Future<void> _navigateToPage({
    required NetworkInspectorCore core,
    required Widget child,
  }) {
    var context = core.getContext();
    if (context == null) {
      throw StateError("Context is null in NetworkInspectorCore.");
    }
    return Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => child),
    );
  }
}
