import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/widget/network_call_expandable_list_row.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/widget/network_call_list_row.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_scroll_behavior.dart';
import 'package:flutter/material.dart';

/// Call error screen which displays info on HTTP call error.
class NetworkCallErrorScreen extends StatelessWidget {
  const NetworkCallErrorScreen({super.key, required this.call});

  final NetworkHttpCall call;

  @override
  Widget build(BuildContext context) {
    if (call.error != null) {
      final dynamic error = call.error?.error;
      final StackTrace? stackTrace = call.error?.stackTrace;
      final String errorText =
          error != null
              ? error.toString()
              : context.i18n(NetworkTranslationKey.callErrorScreenErrorEmpty);

      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: NetworkScrollBehavior(),
          child: ListView(
            children: [
              NetworkCallListRow(
                name: context.i18n(NetworkTranslationKey.callErrorScreenError),
                value: errorText,
              ),
              if (stackTrace != null)
                NetworkCallExpandableListRow(
                  name: context.i18n(
                    NetworkTranslationKey.callErrorScreenStacktrace,
                  ),
                  value: stackTrace.toString(),
                ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Text(context.i18n(NetworkTranslationKey.callErrorScreenEmpty)),
      );
    }
  }
}
