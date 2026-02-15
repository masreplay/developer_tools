import 'package:developer_tools_network/network_inspector/core/network_core.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/model/network_calls_list_sort_option.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_calls_list_screen.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_empty_logs_widget.dart';
import 'package:flutter/material.dart';

/// Screen which is hosted in calls list page. It displays HTTP calls. It allows
/// to search call and sort items based on provided criteria.
class NetworkInspectorScreen extends StatefulWidget {
  const NetworkInspectorScreen({
    super.key,
    required this.networkCore,
    required this.queryTextEditingController,
    required this.sortOption,
    required this.sortAscending,
    required this.onListItemPressed,
  });

  final NetworkInspectorCore networkCore;
  final TextEditingController queryTextEditingController;
  final NetworkCallsListSortOption sortOption;
  final bool sortAscending;
  final void Function(NetworkHttpCall) onListItemPressed;

  @override
  State<NetworkInspectorScreen> createState() => _NetworkInspectorScreenState();
}

class _NetworkInspectorScreenState extends State<NetworkInspectorScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<NetworkHttpCall>>(
      stream: widget.networkCore.callsStream,
      builder: (context, AsyncSnapshot<List<NetworkHttpCall>> snapshot) {
        final List<NetworkHttpCall> calls = snapshot.data ?? [];
        final String query = widget.queryTextEditingController.text.trim();
        if (query.isNotEmpty) {
          calls.removeWhere(
            (NetworkHttpCall call) =>
                !call.endpoint.toLowerCase().contains(query.toLowerCase()),
          );
        }
        if (calls.isNotEmpty) {
          return NetworkCallsListScreen(
            calls: calls,
            sortOption: widget.sortOption,
            sortAscending: widget.sortAscending,
            onListItemClicked: widget.onListItemPressed,
          );
        } else {
          return const NetworkEmptyLogsWidget();
        }
      },
    );
  }
}
