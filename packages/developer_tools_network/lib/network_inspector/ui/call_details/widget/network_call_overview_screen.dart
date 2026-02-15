import 'package:developer_tools_network/network_inspector/helper/network_conversion_helper.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/widget/network_call_list_row.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_scroll_behavior.dart';
import 'package:flutter/material.dart';

/// Screen which displays call overview data, for example method, server.
class NetworkCallOverviewScreen extends StatelessWidget {
  final NetworkHttpCall call;

  const NetworkCallOverviewScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: NetworkScrollBehavior(),
        child: ListView(
          children: [
            NetworkCallListRow(
              name: context.i18n(NetworkTranslationKey.callOverviewMethod),
              value: call.method,
            ),
            NetworkCallListRow(
              name: context.i18n(NetworkTranslationKey.callOverviewServer),
              value: call.server,
            ),
            NetworkCallListRow(
              name: context.i18n(NetworkTranslationKey.callOverviewEndpoint),
              value: call.endpoint,
            ),
            NetworkCallListRow(
              name: context.i18n(NetworkTranslationKey.callOverviewStarted),
              value: call.request?.time.toString(),
            ),
            NetworkCallListRow(
              name: context.i18n(NetworkTranslationKey.callOverviewFinished),
              value: call.response?.time.toString(),
            ),
            NetworkCallListRow(
              name: context.i18n(NetworkTranslationKey.callOverviewDuration),
              value: NetworkConversionHelper.formatTime(call.duration),
            ),
            NetworkCallListRow(
              name: context.i18n(NetworkTranslationKey.callOverviewBytesSent),
              value: NetworkConversionHelper.formatBytes(
                call.request?.size ?? 0,
              ),
            ),
            NetworkCallListRow(
              name: context.i18n(
                NetworkTranslationKey.callOverviewBytesReceived,
              ),
              value: NetworkConversionHelper.formatBytes(
                call.response?.size ?? 0,
              ),
            ),
            NetworkCallListRow(
              name: context.i18n(NetworkTranslationKey.callOverviewClient),
              value: call.client,
            ),
            NetworkCallListRow(
              name: context.i18n(NetworkTranslationKey.callOverviewSecure),
              value: call.secure.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
