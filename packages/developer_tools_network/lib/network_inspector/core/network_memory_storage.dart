import 'dart:async';

import 'package:developer_tools_network/network_inspector/core/network_storage.dart';
import 'package:developer_tools_network/network_inspector/core/network_utils.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_error.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_response.dart';
import 'package:developer_tools_network/network_inspector/utils/num_comparison.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/subjects.dart';

/// Storage which uses memory to store calls data. It's a default storage
/// method.
class NetworkMemoryStorage implements NetworkStorage {
  NetworkMemoryStorage({required this.maxCallsCount})
    : _callsSubject = BehaviorSubject.seeded([]),
      assert(maxCallsCount > 0, 'Max calls count should be greater than 0');
  @override
  final int maxCallsCount;

  /// Subject which stores all HTTP calls.
  final BehaviorSubject<List<NetworkHttpCall>> _callsSubject;

  /// Stream which returns all HTTP calls on change.
  @override
  Stream<List<NetworkHttpCall>> get callsStream => _callsSubject.stream;

  /// Returns all HTTP calls.
  @override
  List<NetworkHttpCall> getCalls() => _callsSubject.value;

  /// Returns stats based on calls.
  @override
  NetworkStats getStats() {
    final List<NetworkHttpCall> calls = getCalls();

    return (
      total: calls.length,
      successes:
          calls
              .where(
                (NetworkHttpCall call) =>
                    (call.response?.status.gte(200) ?? false) &&
                    (call.response?.status.lt(300) ?? false),
              )
              .length,
      redirects:
          calls
              .where(
                (NetworkHttpCall call) =>
                    (call.response?.status.gte(300) ?? false) &&
                    (call.response?.status.lt(400) ?? false),
              )
              .length,
      errors:
          calls
              .where(
                (NetworkHttpCall call) =>
                    ((call.response?.status.gte(400) ?? false) &&
                        (call.response?.status.lt(600) ?? false)) ||
                    const [-1, 0].contains(call.response?.status),
              )
              .length,
      loading: calls.where((NetworkHttpCall call) => call.loading).length,
    );
  }

  /// Adds new call to calls list.
  @override
  void addCall(NetworkHttpCall call) {
    final int callsCount = _callsSubject.value.length;
    if (callsCount >= maxCallsCount) {
      final List<NetworkHttpCall> originalCalls = _callsSubject.value;
      originalCalls.removeAt(0);
      originalCalls.add(call);

      _callsSubject.add(originalCalls);
    } else {
      _callsSubject.add([..._callsSubject.value, call]);
    }
  }

  /// Adds error to a specific call.
  @override
  void addError(NetworkHttpError error, int requestId) {
    final NetworkHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return NetworkUtils.log('Selected call is null');
    }

    selectedCall.error = error;
    _callsSubject.add([..._callsSubject.value]);
  }

  /// Adds response to a specific call.
  @override
  void addResponse(NetworkHttpResponse response, int requestId) {
    final NetworkHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return NetworkUtils.log('Selected call is null');
    }

    selectedCall
      ..loading = false
      ..response = response
      ..duration =
          response.time.millisecondsSinceEpoch -
          (selectedCall.request?.time.millisecondsSinceEpoch ?? 0);

    _callsSubject.add([..._callsSubject.value]);
  }

  /// Removes all calls.
  @override
  void removeCalls() => _callsSubject.add([]);

  /// Searches for call with specific [requestId]. It may return null.
  @override
  NetworkHttpCall? selectCall(int requestId) => _callsSubject.value
      .firstWhereOrNull((NetworkHttpCall call) => call.id == requestId);
}
