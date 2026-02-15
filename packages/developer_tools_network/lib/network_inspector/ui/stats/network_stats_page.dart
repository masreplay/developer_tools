import 'package:developer_tools_network/network_inspector/core/network_core.dart';
import 'package:developer_tools_network/network_inspector/helper/network_conversion_helper.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_page.dart';
import 'package:developer_tools_network/network_inspector/ui/widget/network_stats_row.dart';
import 'package:developer_tools_network/network_inspector/utils/num_comparison.dart';
import 'package:flutter/material.dart';

/// General stats page for currently caught HTTP calls.
class NetworkStatsPage extends StatelessWidget {
  final NetworkInspectorCore networkCore;

  const NetworkStatsPage(this.networkCore, {super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkPage(
      core: networkCore,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${context.i18n(NetworkTranslationKey.networkInspector)} - '
            '${context.i18n(NetworkTranslationKey.statsTitle)}',
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: ListView(
            children: [
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsTotalRequests),
                '${_getTotalRequests()}',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsPendingRequests),
                '${_getPendingRequests()}',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsSuccessRequests),
                '${_getSuccessRequests()}',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsRedirectionRequests),
                '${_getRedirectionRequests()}',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsErrorRequests),
                '${_getErrorRequests()}',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsBytesSent),
                NetworkConversionHelper.formatBytes(_getBytesSent()),
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsBytesReceived),
                NetworkConversionHelper.formatBytes(_getBytesReceived()),
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsAverageRequestTime),
                NetworkConversionHelper.formatTime(_getAverageRequestTime()),
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsMaxRequestTime),
                NetworkConversionHelper.formatTime(_getMaxRequestTime()),
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsMinRequestTime),
                NetworkConversionHelper.formatTime(_getMinRequestTime()),
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsGetRequests),
                '${_getRequests('GET')} ',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsPostRequests),
                '${_getRequests('POST')} ',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsDeleteRequests),
                '${_getRequests('DELETE')} ',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsPutRequests),
                '${_getRequests('PUT')} ',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsPatchRequests),
                '${_getRequests('PATCH')} ',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsSecuredRequests),
                '${_getSecuredRequests()}',
              ),
              NetworkStatsRow(
                context.i18n(NetworkTranslationKey.statsUnsecuredRequests),
                '${_getUnsecuredRequests()}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns count of requests.
  int _getTotalRequests() => _calls.length;

  /// Returns count of success requests.
  int _getSuccessRequests() =>
      _calls
          .where(
            (NetworkHttpCall call) =>
                (call.response?.status.gte(200) ?? false) &&
                (call.response?.status.lt(300) ?? false),
          )
          .toList()
          .length;

  /// Returns count of redirection requests.
  int _getRedirectionRequests() =>
      _calls
          .where(
            (NetworkHttpCall call) =>
                (call.response?.status.gte(300) ?? false) &&
                (call.response?.status.lt(400) ?? false),
          )
          .toList()
          .length;

  /// Returns count of error requests.
  int _getErrorRequests() =>
      _calls
          .where(
            (NetworkHttpCall call) =>
                (call.response?.status.gte(400) ?? false) &&
                    (call.response?.status.lt(600) ?? false) ||
                const [-1, 0].contains(call.response?.status),
          )
          .toList()
          .length;

  /// Returns count of pending requests.
  int _getPendingRequests() =>
      _calls.where((NetworkHttpCall call) => call.loading).toList().length;

  /// Returns total bytes sent count.
  int _getBytesSent() => _calls.fold(
    0,
    (int sum, NetworkHttpCall call) => sum + (call.request?.size ?? 0),
  );

  /// Returns total bytes received count.
  int _getBytesReceived() => _calls.fold(
    0,
    (int sum, NetworkHttpCall call) => sum + (call.response?.size ?? 0),
  );

  /// Returns average request time of all calls.
  int _getAverageRequestTime() {
    int requestTimeSum = 0;
    int requestsWithDurationCount = 0;
    for (final NetworkHttpCall call in _calls) {
      if (call.duration != 0) {
        requestTimeSum = call.duration;
        requestsWithDurationCount++;
      }
    }
    if (requestTimeSum == 0) {
      return 0;
    }
    return requestTimeSum ~/ requestsWithDurationCount;
  }

  /// Returns max request time of all calls.
  int _getMaxRequestTime() {
    int maxRequestTime = 0;
    for (final NetworkHttpCall call in _calls) {
      if (call.duration > maxRequestTime) {
        maxRequestTime = call.duration;
      }
    }
    return maxRequestTime;
  }

  /// Returns min request time of all calls.
  int _getMinRequestTime() {
    int minRequestTime = 10000000;
    if (_calls.isEmpty) {
      minRequestTime = 0;
    } else {
      for (final NetworkHttpCall call in _calls) {
        if (call.duration != 0 && call.duration < minRequestTime) {
          minRequestTime = call.duration;
        }
      }
    }
    return minRequestTime;
  }

  /// Get all requests with [requestType].
  int _getRequests(String requestType) =>
      _calls.where((call) => call.method == requestType).toList().length;

  /// Get all secured requests count.
  int _getSecuredRequests() =>
      _calls.where((call) => call.secure).toList().length;

  /// Get unsecured requests count.
  int _getUnsecuredRequests() =>
      _calls.where((call) => !call.secure).toList().length;

  /// Get all calls from NetworkInspector.
  List<NetworkHttpCall> get _calls => networkCore.getCalls();
}
