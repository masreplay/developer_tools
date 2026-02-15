import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'dart:async' show FutureOr;

import 'package:developer_tools_network/network_inspector/model/network_http_error.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_response.dart';

/// Definition of call stats.
typedef NetworkStats =
    ({int total, int successes, int redirects, int errors, int loading});

/// Definition of storage
abstract interface class NetworkStorage {
  /// Stream which returns all HTTP calls on change.
  abstract final Stream<List<NetworkHttpCall>> callsStream;

  /// Max calls number which should be stored.
  abstract final int maxCallsCount;

  /// Returns all HTTP calls.
  List<NetworkHttpCall> getCalls();

  /// Returns stats based on calls.
  NetworkStats getStats();

  /// Searches for call with specific [requestId]. It may return null.
  NetworkHttpCall? selectCall(int requestId);

  /// Adds new call to calls list.
  FutureOr<void> addCall(NetworkHttpCall call);

  /// Adds error to a specific call.
  FutureOr<void> addError(NetworkHttpError error, int requestId);

  /// Adds response to a specific call.
  FutureOr<void> addResponse(NetworkHttpResponse response, int requestId);

  /// Removes all calls.
  FutureOr<void> removeCalls();
}
