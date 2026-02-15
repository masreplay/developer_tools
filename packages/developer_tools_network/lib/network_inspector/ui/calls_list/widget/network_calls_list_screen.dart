import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/model/network_calls_list_sort_option.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_call_list_item_widget.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_scroll_behavior.dart';
import 'package:flutter/material.dart';

/// Widget which displays calls list. It's hosted in tab in calls list page.
class NetworkCallsListScreen extends StatelessWidget {
  const NetworkCallsListScreen({
    super.key,
    required this.calls,
    this.sortOption,
    this.sortAscending = false,
    required this.onListItemClicked,
  });

  final List<NetworkHttpCall> calls;
  final NetworkCallsListSortOption? sortOption;
  final bool sortAscending;
  final void Function(NetworkHttpCall) onListItemClicked;

  /// Returns sorted calls based [sortOption] and [sortAscending].
  List<NetworkHttpCall> get _sortedCalls => switch (sortOption) {
    NetworkCallsListSortOption.time =>
      sortAscending
          ? (calls..sort(
            (NetworkHttpCall call1, NetworkHttpCall call2) =>
                call1.createdTime.compareTo(call2.createdTime),
          ))
          : (calls..sort(
            (NetworkHttpCall call1, NetworkHttpCall call2) =>
                call2.createdTime.compareTo(call1.createdTime),
          )),
    NetworkCallsListSortOption.responseTime =>
      sortAscending
          ? (calls
            ..sort()
            ..sort(
              (NetworkHttpCall call1, NetworkHttpCall call2) =>
                  call1.response?.time.compareTo(call2.response!.time) ?? -1,
            ))
          : (calls..sort(
            (NetworkHttpCall call1, NetworkHttpCall call2) =>
                call2.response?.time.compareTo(call1.response!.time) ?? -1,
          )),
    NetworkCallsListSortOption.responseCode =>
      sortAscending
          ? (calls..sort(
            (NetworkHttpCall call1, NetworkHttpCall call2) =>
                call1.response?.status?.compareTo(call2.response!.status!) ??
                -1,
          ))
          : (calls..sort(
            (NetworkHttpCall call1, NetworkHttpCall call2) =>
                call2.response?.status?.compareTo(call1.response!.status!) ??
                -1,
          )),
    NetworkCallsListSortOption.responseSize =>
      sortAscending
          ? (calls..sort(
            (NetworkHttpCall call1, NetworkHttpCall call2) =>
                call1.response?.size.compareTo(call2.response!.size) ?? -1,
          ))
          : (calls..sort(
            (NetworkHttpCall call1, NetworkHttpCall call2) =>
                call2.response?.size.compareTo(call1.response!.size) ?? -1,
          )),
    NetworkCallsListSortOption.endpoint =>
      sortAscending
          ? (calls..sort(
            (NetworkHttpCall call1, NetworkHttpCall call2) =>
                call1.endpoint.compareTo(call2.endpoint),
          ))
          : (calls..sort(
            (NetworkHttpCall call1, NetworkHttpCall call2) =>
                call2.endpoint.compareTo(call1.endpoint),
          )),
    _ => calls,
  };

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NetworkScrollBehavior(),
      child: ListView.builder(
        itemCount: calls.length,
        itemBuilder:
            (_, int index) =>
                NetworkCallListItemWidget(_sortedCalls[index], onListItemClicked),
      ),
    );
  }
}
