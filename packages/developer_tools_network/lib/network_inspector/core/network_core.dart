import 'dart:async' show FutureOr, StreamSubscription;

import 'package:developer_tools_network/network_inspector/core/network_storage.dart';
import 'package:developer_tools_network/network_inspector/core/network_utils.dart';
import 'package:developer_tools_network/network_inspector/helper/network_export_helper.dart';
import 'package:developer_tools_network/network_inspector/core/network_notification.dart';
import 'package:developer_tools_network/network_inspector/helper/operating_system.dart';
import 'package:developer_tools_network/network_inspector/model/network_configuration.dart';
import 'package:developer_tools_network/network_inspector/model/network_export_result.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_error.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_response.dart';
import 'package:developer_tools_network/network_inspector/model/network_log.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_navigation.dart';
import 'package:developer_tools_network/network_inspector/utils/shake_detector.dart';
import 'package:flutter/material.dart';

class NetworkInspectorCore {
  /// Configuration of network inspector
  late NetworkInspectorConfiguration _configuration;

  /// Detector used to detect device shakes
  ShakeDetector? _shakeDetector;

  /// Helper used for notification management
  NetworkNotification? _notification;

  /// Subscription for call changes
  StreamSubscription<List<NetworkHttpCall>>? _callsSubscription;

  /// Flag used to determine whether is inspector opened
  bool _isInspectorOpened = false;

  /// Creates network core instance
  NetworkInspectorCore({required NetworkInspectorConfiguration configuration}) {
    _configuration = configuration;
    _subscribeToCallChanges();
    if (_configuration.showNotification) {
      _notification = NetworkNotification();
      _notification?.configure(
        notificationIcon: _configuration.notificationIcon,
        openInspectorCallback: navigateToCallListScreen,
      );
    }
    if (_configuration.showInspectorOnShake) {
      if (OperatingSystem.isAndroid || OperatingSystem.isIOS) {
        _shakeDetector = ShakeDetector.autoStart(
          onPhoneShake: navigateToCallListScreen,
          shakeThresholdGravity: 4,
        );
      }
    }
  }

  /// Returns current configuration
  NetworkInspectorConfiguration get configuration => _configuration;

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _configuration = _configuration.copyWith(navigatorKey: navigatorKey);
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    _shakeDetector?.stopListening();
    _unsubscribeFromCallChanges();
  }

  /// Called when calls has been updated
  Future<void> _onCallsChanged(List<NetworkHttpCall>? calls) async {
    if (calls != null && calls.isNotEmpty) {
      final NetworkStats stats = _configuration.networkStorage.getStats();
      _notification?.showStatsNotification(
        context: getContext()!,
        stats: stats,
      );
    }
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  Future<void> navigateToCallListScreen() async {
    final BuildContext? context = getContext();
    if (context == null) {
      NetworkUtils.log(
        'Cant start NetworkInspector HTTP Inspector. Please add NavigatorKey to your '
        'application',
      );
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      await NetworkNavigation.navigateToCallsList(core: this);
      _isInspectorOpened = false;
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() =>
      _configuration.navigatorKey?.currentState?.overlay?.context;

  /// Add alice http call to calls subject
  FutureOr<void> addCall(NetworkHttpCall call) =>
      _configuration.networkStorage.addCall(call);

  /// Add error to existing alice http call
  FutureOr<void> addError(NetworkHttpError error, int requestId) =>
      _configuration.networkStorage.addError(error, requestId);

  /// Add response to existing alice http call
  FutureOr<void> addResponse(NetworkHttpResponse response, int requestId) =>
      _configuration.networkStorage.addResponse(response, requestId);

  /// Remove all calls from calls subject
  FutureOr<void> removeCalls() => _configuration.networkStorage.removeCalls();

  /// Selects call with given [requestId]. It may return null.
  @protected
  NetworkHttpCall? selectCall(int requestId) =>
      _configuration.networkStorage.selectCall(requestId);

  /// Returns stream which returns list of HTTP calls
  Stream<List<NetworkHttpCall>> get callsStream =>
      _configuration.networkStorage.callsStream;

  /// Returns all stored HTTP calls.
  List<NetworkHttpCall> getCalls() => _configuration.networkStorage.getCalls();

  /// Save all calls to file.
  Future<NetworkExportResult> saveCallsToFile(BuildContext context) =>
      NetworkExportHelper.saveCallsToFile(
        context,
        _configuration.networkStorage.getCalls(),
      );

  /// Adds new log to NetworkInspector logger.
  void addLog(NetworkLog log) => _configuration.networkLogger.add(log);

  /// Adds list of logs to NetworkInspector logger
  void addLogs(List<NetworkLog> logs) => _configuration.networkLogger.addAll(logs);

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _isInspectorOpened;

  /// Subscribes to storage for call changes.
  void _subscribeToCallChanges() {
    _callsSubscription = _configuration.networkStorage.callsStream.listen(
      _onCallsChanged,
    );
  }

  /// Unsubscribes storage for call changes.
  void _unsubscribeFromCallChanges() {
    _callsSubscription?.cancel();
    _callsSubscription = null;
  }
}
