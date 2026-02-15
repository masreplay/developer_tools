import 'package:developer_tools_network/network_inspector/model/network_http_error.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_request.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_response.dart';
import 'package:equatable/equatable.dart';

/// Definition of http calls data holder.
// ignore: must_be_immutable
class NetworkHttpCall with EquatableMixin {
  NetworkHttpCall(this.id);

  final int id;
  final DateTime createdTime = DateTime.now();
  String client = '';
  bool loading = true;
  bool secure = false;
  String method = '';
  String endpoint = '';
  String server = '';
  String uri = '';
  int duration = 0;

  NetworkHttpRequest? request;
  NetworkHttpResponse? response;
  NetworkHttpError? error;

  @override
  List<Object?> get props => [
    id,
    createdTime,
    client,
    loading,
    secure,
    method,
    endpoint,
    server,
    uri,
    duration,
    request,
    response,
    error,
  ];
}
