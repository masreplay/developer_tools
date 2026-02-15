import 'dart:io' show Cookie;

import 'package:developer_tools_network/network_inspector/model/network_form_data_file.dart';
import 'package:developer_tools_network/network_inspector/model/network_from_data_field.dart';
import 'package:equatable/equatable.dart';

/// Definition of http request data holder.
// ignore: must_be_immutable
class NetworkHttpRequest with EquatableMixin {
  int size = 0;
  DateTime time = DateTime.now();
  Map<String, String> headers = <String, String>{};
  dynamic body = '';
  String? contentType = '';
  List<Cookie> cookies = [];
  Map<String, dynamic> queryParameters = <String, dynamic>{};
  List<NetworkFormDataFile>? formDataFiles;
  List<NetworkFormDataField>? formDataFields;

  @override
  List<Object?> get props => [
    size,
    time,
    headers,
    body,
    contentType,
    cookies,
    queryParameters,
    formDataFiles,
    formDataFields,
  ];
}
