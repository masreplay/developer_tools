import 'dart:convert';
import 'dart:typed_data';

import 'package:developer_tools_network/network_inspector/network_inspector.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio interceptor that records HTTP calls to [NetworkInspector].
///
/// Usage:
///
/// ```dart
/// final adapter = NetworkDioAdapter();
/// networkInspector.addAdapter(adapter);
/// dio.interceptors.add(adapter);
/// ```
class NetworkDioAdapter extends InterceptorsWrapper with NetworkAdapter {
  NetworkDioAdapter();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final call = NetworkHttpCall(options.hashCode);

    final uri = options.uri;
    call.method = options.method;
    var path = options.uri.path;
    if (path.isEmpty) path = '/';
    call
      ..endpoint = path
      ..server = uri.host
      ..client = 'Dio'
      ..uri = options.uri.toString();

    if (uri.scheme == 'https') call.secure = true;

    final request = NetworkHttpRequest();

    final dynamic data = options.data;
    if (data == null) {
      request
        ..size = 0
        ..body = '';
    } else {
      if (data is FormData) {
        request.body += 'Form data';
        if (data.fields.isNotEmpty == true) {
          final fields = <NetworkFormDataField>[];
          for (var entry in data.fields) {
            fields.add(NetworkFormDataField(entry.key, entry.value));
          }
          request.formDataFields = fields;
        }
        if (data.files.isNotEmpty == true) {
          final files = <NetworkFormDataFile>[];
          for (var entry in data.files) {
            files.add(
              NetworkFormDataFile(
                entry.value.filename,
                entry.value.contentType.toString(),
                entry.value.length,
                fieldName: entry.key,
                bytes: await _readBytes(entry.value),
              ),
            );
          }
          request.formDataFiles = files;
        }
      } else {
        request
          ..size = utf8.encode(data.toString()).length
          ..body = data;
      }
    }

    request
      ..time = DateTime.now()
      ..headers = NetworkParser.parseHeaders(headers: options.headers)
      ..contentType = options.contentType.toString()
      ..queryParameters = uri.queryParameters;

    call
      ..request = request
      ..response = NetworkHttpResponse();

    networkCore.addCall(call);
    handler.next(options);
  }

  // ponytail: holds each upload in memory once more; capped so a large video
  // upload does not double the app's memory. Raise the cap if exports miss files.
  static const int _maxCapturedFileBytes = 15 * 1024 * 1024;

  /// Reads a copy of [file] so the export can embed it. Works on a clone, so
  /// the stream Dio sends is untouched; returns null when that is not possible.
  static Future<Uint8List?> _readBytes(MultipartFile file) async {
    if (file.length > _maxCapturedFileBytes) return null;
    try {
      final builder = BytesBuilder(copy: false);
      await for (final chunk in file.clone().finalize()) {
        builder.add(chunk);
      }
      return builder.takeBytes();
    } catch (_) {
      return null;
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final httpResponse = NetworkHttpResponse()..status = response.statusCode;

    if (response.data == null) {
      httpResponse
        ..body = ''
        ..size = 0;
    } else {
      httpResponse
        ..body = response.data
        ..size = utf8.encode(response.data.toString()).length;
    }

    httpResponse.time = DateTime.now();
    final headers = <String, String>{};
    response.headers.forEach((header, values) {
      headers[header] = values.join(', ');
    });
    httpResponse.headers = headers;

    networkCore.addResponse(
      httpResponse,
      response.requestOptions.hashCode,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final httpError = NetworkHttpError()..error = err.toString();
    if (err is Error) {
      final basicError = err as Error;
      httpError.stackTrace = basicError.stackTrace;
    }

    networkCore.addError(httpError, err.requestOptions.hashCode);
    final httpResponse = NetworkHttpResponse()..time = DateTime.now();
    if (err.response == null) {
      httpResponse.status = -1;
      networkCore.addResponse(
        httpResponse,
        err.requestOptions.hashCode,
      );
    } else {
      httpResponse.status = err.response!.statusCode;

      if (err.response!.data == null) {
        httpResponse
          ..body = ''
          ..size = 0;
      } else {
        httpResponse
          ..body = err.response!.data
          ..size = utf8.encode(err.response!.data.toString()).length;
      }
      final headers = <String, String>{};
      err.response!.headers.forEach((header, values) {
        headers[header] = values.join(', ');
      });
      httpResponse.headers = headers;
      networkCore.addResponse(
        httpResponse,
        err.response!.requestOptions.hashCode,
      );
      networkCore.addLog(
        NetworkLog(
          message: err.toString(),
          level: DiagnosticLevel.error,
          error: err,
          stackTrace: err.stackTrace,
        ),
      );
    }
    handler.next(err);
  }
}
