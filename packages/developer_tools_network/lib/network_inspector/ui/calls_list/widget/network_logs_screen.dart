import 'package:developer_tools_network/network_inspector/core/network_logger.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_empty_logs_widget.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_log_list_widget.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_raw_log_list_widger.dart';
import 'package:flutter/material.dart';

/// Screen hosted in calls list which displays logs list.
class NetworkLogsScreen extends StatelessWidget {
  const NetworkLogsScreen({
    super.key,
    required this.scrollController,
    this.networkLogger,
    this.isAndroidRawLogsEnabled = false,
  });

  final ScrollController scrollController;
  final NetworkLogger? networkLogger;
  final bool isAndroidRawLogsEnabled;

  @override
  Widget build(BuildContext context) =>
      networkLogger != null
          ? isAndroidRawLogsEnabled
              ? NetworkRawLogListWidget(
                scrollController: scrollController,
                getRawLogs: networkLogger?.getAndroidRawLogs(),
              )
              : NetworkLogListWidget(
                logsStream: networkLogger?.logsStream,
                scrollController: scrollController,
              )
          : const NetworkEmptyLogsWidget();
}
