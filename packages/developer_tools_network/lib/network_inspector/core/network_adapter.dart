import 'package:developer_tools_network/network_inspector/core/network_core.dart';

/// Adapter mixin which is used in http client adapters.
mixin NetworkAdapter {
  late final NetworkInspectorCore networkCore;

  /// Injects [NetworkInspectorCore] into adapter.
  void injectCore(NetworkInspectorCore networkCore) =>
      this.networkCore = networkCore;
}
