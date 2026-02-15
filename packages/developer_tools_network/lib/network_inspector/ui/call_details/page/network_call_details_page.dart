// ignore_for_file: use_build_context_synchronously

import 'package:developer_tools_network/network_inspector/core/network_core.dart';
import 'package:developer_tools_network/network_inspector/helper/network_export_helper.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/model/network_call_details_tab.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/widget/network_call_error_screen.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/widget/network_call_overview_screen.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/widget/network_call_request_screen.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/widget/network_call_response_screen.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_page.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_theme.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

/// Call details page which displays 4 tabs: overview, request, response, error.
class NetworkCallDetailsPage extends StatefulWidget {
  final NetworkHttpCall call;
  final NetworkInspectorCore core;

  const NetworkCallDetailsPage({
    required this.call,
    required this.core,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _NetworkCallDetailsPageState();
}

/// State of call details page.
class _NetworkCallDetailsPageState extends State<NetworkCallDetailsPage>
    with SingleTickerProviderStateMixin {
  NetworkHttpCall get call => widget.call;

  @override
  Widget build(BuildContext context) {
    return NetworkPage(
      core: widget.core,
      child: StreamBuilder<List<NetworkHttpCall>>(
        stream: widget.core.callsStream,
        initialData: [widget.call],
        builder: (context, AsyncSnapshot<List<NetworkHttpCall>> callsSnapshot) {
          if (callsSnapshot.hasData && !callsSnapshot.hasError) {
            final NetworkHttpCall? call = callsSnapshot.data?.firstWhereOrNull(
              (NetworkHttpCall snapshotCall) => snapshotCall.id == widget.call.id,
            );
            if (call != null) {
              return DefaultTabController(
                length: 4,
                child: Scaffold(
                  appBar: AppBar(
                    bottom: TabBar(
                      indicatorColor: NetworkTheme.lightRed,
                      tabs:
                          NetworkCallDetailsTabItem.values.map((item) {
                            return Tab(
                              icon: _getTabIcon(item: item),
                              text: _getTabName(item: item),
                            );
                          }).toList(),
                    ),
                    title: Text(
                      '${context.i18n(NetworkTranslationKey.networkInspector)} -'
                      ' ${context.i18n(NetworkTranslationKey.callDetails)}',
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      NetworkCallOverviewScreen(call: widget.call),
                      NetworkCallRequestScreen(call: widget.call),
                      NetworkCallResponseScreen(call: widget.call),
                      NetworkCallErrorScreen(call: widget.call),
                    ],
                  ),
                  floatingActionButton:
                      widget.core.configuration.showShareButton
                          ? FloatingActionButton(
                            backgroundColor: NetworkTheme.lightRed,
                            key: const Key('share_key'),
                            onPressed: _shareCall,
                            child: const Icon(
                              Icons.share,
                              color: NetworkTheme.white,
                            ),
                          )
                          : null,
                ),
              );
            }
          }

          return Center(
            child: Text(context.i18n(NetworkTranslationKey.callDetailsEmpty)),
          );
        },
      ),
    );
  }

  /// Called when share button has been pressed. It encodes the [widget.call]
  /// and tries to invoke system action to share it.
  void _shareCall() async {
    await NetworkExportHelper.shareCall(context: context, call: widget.call);
  }

  /// Get tab name based on [item] type.
  String _getTabName({required NetworkCallDetailsTabItem item}) {
    switch (item) {
      case NetworkCallDetailsTabItem.overview:
        return context.i18n(NetworkTranslationKey.callDetailsOverview);
      case NetworkCallDetailsTabItem.request:
        return context.i18n(NetworkTranslationKey.callDetailsRequest);
      case NetworkCallDetailsTabItem.response:
        return context.i18n(NetworkTranslationKey.callDetailsResponse);
      case NetworkCallDetailsTabItem.error:
        return context.i18n(NetworkTranslationKey.callDetailsError);
    }
  }

  /// Get tab icon based on [item] type.
  Icon _getTabIcon({required NetworkCallDetailsTabItem item}) {
    switch (item) {
      case NetworkCallDetailsTabItem.overview:
        return const Icon(Icons.info_outline);
      case NetworkCallDetailsTabItem.request:
        return const Icon(Icons.arrow_upward);
      case NetworkCallDetailsTabItem.response:
        return const Icon(Icons.arrow_downward);
      case NetworkCallDetailsTabItem.error:
        return const Icon(Icons.warning);
    }
  }
}
