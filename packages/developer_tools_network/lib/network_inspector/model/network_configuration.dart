import 'package:developer_tools_network/network_inspector/core/network_logger.dart';
import 'package:developer_tools_network/network_inspector/core/network_memory_storage.dart';
import 'package:developer_tools_network/network_inspector/core/network_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class NetworkInspectorConfiguration with EquatableMixin {
  /// Default max calls count used in default memory storage.
  static const _defaultMaxCalls = 1000;

  /// Default max logs count.
  static const _defaultMaxLogs = 1000;

  /// Should user be notified with notification when there's new request caught
  /// by NetworkInspector. Default value is true.
  final bool showNotification;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors). Default value is true.
  final bool showInspectorOnShake;

  /// Icon url for notification. Default value is '@mipmap/ic_launcher'.
  final String notificationIcon;

  /// Directionality of app. Directionality of the app will be used if set to
  /// null. Default value is null.
  final TextDirection? directionality;

  /// Flag used to show/hide share button
  final bool showShareButton;

  /// Navigator key used to open inspector. Default value is null.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Storage where calls will be saved. The default storage is memory storage.
  final NetworkStorage networkStorage;

  /// Logger instance.
  final NetworkLogger networkLogger;

  NetworkInspectorConfiguration({
    this.showNotification = true,
    this.showInspectorOnShake = true,
    this.notificationIcon = '@mipmap/ic_launcher',
    this.directionality,
    this.showShareButton = true,
    GlobalKey<NavigatorState>? navigatorKey,
    NetworkStorage? storage,
    NetworkLogger? logger,
  }) : networkStorage =
           storage ?? NetworkMemoryStorage(maxCallsCount: _defaultMaxCalls),
       navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
       networkLogger = logger ?? NetworkLogger(maximumSize: _defaultMaxLogs);

  NetworkInspectorConfiguration copyWith({
    GlobalKey<NavigatorState>? navigatorKey,
    bool? showNotification,
    bool? showInspectorOnShake,
    String? notificationIcon,
    TextDirection? directionality,
    bool? showShareButton,
    NetworkStorage? networkStorage,
    NetworkLogger? networkLogger,
  }) => NetworkInspectorConfiguration(
    showNotification: showNotification ?? this.showNotification,
    showInspectorOnShake: showInspectorOnShake ?? this.showInspectorOnShake,
    notificationIcon: notificationIcon ?? this.notificationIcon,
    directionality: directionality ?? this.directionality,
    showShareButton: showShareButton ?? this.showShareButton,
    navigatorKey: navigatorKey ?? this.navigatorKey,
    storage: networkStorage ?? this.networkStorage,
    logger: networkLogger ?? this.networkLogger,
  );

  @override
  List<Object?> get props => [
    showNotification,
    showInspectorOnShake,
    notificationIcon,
    directionality,
    showShareButton,
    navigatorKey,
    networkStorage,
    networkLogger,
  ];
}
