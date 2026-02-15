import 'package:developer_tools_network/network_inspector/core/network_adapter.dart';
import 'package:developer_tools_network/network_inspector/core/network_core.dart';
import 'package:developer_tools_network/network_inspector/model/network_configuration.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

export 'package:developer_tools_network/network_inspector/model/network_log.dart';
export 'package:developer_tools_network/network_inspector/core/network_memory_storage.dart';
export 'package:developer_tools_network/network_inspector/utils/network_parser.dart';

class NetworkInspector {
  /// NetworkInspector core instance
  late final NetworkInspectorCore _networkCore;

  /// Creates network instance.
  NetworkInspector({NetworkInspectorConfiguration? configuration}) {
    _networkCore = NetworkInspectorCore(
      configuration: configuration ?? NetworkInspectorConfiguration(),
    );
  }

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _networkCore.setNavigatorKey(navigatorKey);
  }

  /// Get currently used navigation key
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      _networkCore.configuration.navigatorKey;

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void showInspector() => _networkCore.navigateToCallListScreen();

  /// Handle generic http call. Can be used to any http client.
  void addHttpCall(NetworkHttpCall networkHttpCall) {
    assert(networkHttpCall.request != null, "Http call request can't be null");
    assert(networkHttpCall.response != null, "Http call response can't be null");

    _networkCore.addCall(networkHttpCall);
  }

  /// Adds new log to NetworkInspector logger.
  void addLog(NetworkLog log) => _networkCore.addLog(log);

  /// Adds list of logs to NetworkInspector logger
  void addLogs(List<NetworkLog> logs) => _networkCore.addLogs(logs);

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _networkCore.isInspectorOpened;

  /// Adds new adapter to NetworkInspector.
  void addAdapter(NetworkAdapter adapter) => adapter.injectCore(_networkCore);
}
