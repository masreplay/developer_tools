// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show JsonEncoder;
import 'dart:io' show Directory, File;

import 'package:developer_tools_network/network_inspector/core/network_utils.dart';
import 'package:developer_tools_network/network_inspector/model/network_export_result.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_request.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Builds and exports a [Postman Collection v2.1][schema] from captured HTTP
/// calls.
///
/// Every captured call becomes one Postman request item carrying *all* of the
/// data the inspector has: method, full URL (protocol/host/path/query),
/// request headers (and cookies), the request body (raw JSON/text or
/// multipart form-data) and the captured response as a saved example
/// (status, headers, body). Extra metadata that has no native Postman field
/// (client, duration, sizes, timestamps) is preserved in the request
/// description so nothing is lost.
///
/// The collection is emitted as plain JSON maps (no external dependency) so the
/// output imports directly into Postman and the package stays compatible with
/// any toolchain.
///
/// [schema]: https://schema.getpostman.com/json/collection/v2.1.0/collection.json
class NetworkPostmanExportHelper {
  const NetworkPostmanExportHelper._();

  /// Postman Collection format v2.1 schema URL.
  static const String schemaV210 =
      'https://schema.getpostman.com/json/collection/v2.1.0/collection.json';

  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Pure builder — turns [calls] into a Postman Collection (v2.1) JSON map.
  /// Has no dependency on [BuildContext] or IO so it can be unit tested
  /// directly.
  static Map<String, dynamic> buildCollection({
    required String name,
    required List<NetworkHttpCall> calls,
    String? description,
  }) {
    return <String, dynamic>{
      'info': <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        'schema': schemaV210,
      },
      'item': [for (final NetworkHttpCall call in calls) _buildItem(call)],
    };
  }

  /// Encodes a [collection] map to a pretty-printed JSON string.
  static String encode(Map<String, dynamic> collection) =>
      _encoder.convert(collection);

  /// Builds a Postman collection from [calls], writes it to a
  /// `*.postman_collection.json` file in the application cache directory and
  /// opens the share sheet so it can be saved or imported into Postman.
  static Future<NetworkExportResult> exportCalls({
    required BuildContext context,
    required List<NetworkHttpCall> calls,
  }) async {
    if (calls.isEmpty) {
      return NetworkExportResult(
        success: false,
        error: NetworkExportResultError.empty,
      );
    }

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final (String name, String json) = await _buildNamedJson(
        packageInfo,
        calls,
      );

      final Directory dir = await getApplicationCacheDirectory();
      final String fileName =
          '${_sanitizeFileName(packageInfo.appName)}_network_'
          '${DateTime.now().millisecondsSinceEpoch}.postman_collection.json';
      final File file = File('${dir.path}/$fileName')
        ..createSync(recursive: true)
        ..writeAsStringSync(json);

      // sharePositionOrigin is required for the share popover on iPad and is
      // harmless on iPhone.
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: name,
          sharePositionOrigin: box != null && box.hasSize
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );

      return NetworkExportResult(success: true, path: file.path);
    } catch (exception) {
      NetworkUtils.log('Failed to export Postman collection: $exception');
      return NetworkExportResult(
        success: false,
        error: NetworkExportResultError.file,
      );
    }
  }

  /// Builds a Postman collection from [calls] and copies the raw JSON to the
  /// clipboard so it can be pasted directly into Postman (Import › Raw text).
  static Future<NetworkExportResult> copyCalls({
    required List<NetworkHttpCall> calls,
  }) async {
    if (calls.isEmpty) {
      return NetworkExportResult(
        success: false,
        error: NetworkExportResultError.empty,
      );
    }

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final (String _, String json) = await _buildNamedJson(packageInfo, calls);
      await Clipboard.setData(ClipboardData(text: json));
      return NetworkExportResult(success: true);
    } catch (exception) {
      NetworkUtils.log('Failed to copy Postman collection: $exception');
      return NetworkExportResult(
        success: false,
        error: NetworkExportResultError.file,
      );
    }
  }

  /// Builds the collection name and its encoded JSON from [packageInfo].
  static Future<(String, String)> _buildNamedJson(
    PackageInfo packageInfo,
    List<NetworkHttpCall> calls,
  ) async {
    final String name = '${packageInfo.appName} Network';
    final String description =
        'Exported from ${packageInfo.appName} '
        '(${packageInfo.packageName}) '
        'v${packageInfo.version}+${packageInfo.buildNumber} '
        'at ${DateTime.now().toIso8601String()} — ${calls.length} request(s).';

    final Map<String, dynamic> collection = buildCollection(
      name: name,
      description: description,
      calls: calls,
    );
    return (name, encode(collection));
  }

  /// Builds a single Postman item (request + saved response) for [call].
  static Map<String, dynamic> _buildItem(NetworkHttpCall call) {
    final Map<String, dynamic> request = _buildRequest(call);
    final String endpoint = call.endpoint.isNotEmpty ? call.endpoint : call.uri;
    final List<Map<String, dynamic>>? responses = _buildResponses(
      call,
      request,
    );

    return <String, dynamic>{
      'name': '${call.method} $endpoint'.trim(),
      'request': request,
      if (responses != null) 'response': responses,
    };
  }

  static Map<String, dynamic> _buildRequest(NetworkHttpCall call) {
    final Map<String, dynamic>? body = _buildBody(call.request);
    return <String, dynamic>{
      'method': call.method.isNotEmpty ? call.method : 'GET',
      'header': _buildHeaders(call.request),
      if (body != null) 'body': body,
      'url': _buildUrl(call),
      'description': _requestDescription(call),
    };
  }

  static List<Map<String, dynamic>> _buildHeaders(NetworkHttpRequest? request) {
    final Map<String, String> headers = request?.headers ?? const {};
    final List<Map<String, dynamic>> result = [
      for (final MapEntry<String, String> entry in headers.entries)
        {'key': entry.key, 'value': entry.value},
    ];

    // Preserve request cookies — fold them into a `Cookie` header when one
    // isn't already present in the captured headers.
    final cookies = request?.cookies ?? const [];
    final bool hasCookieHeader = headers.keys.any(
      (String key) => key.toLowerCase() == 'cookie',
    );
    if (cookies.isNotEmpty && !hasCookieHeader) {
      result.add({
        'key': 'Cookie',
        'value': cookies
            .map((cookie) => '${cookie.name}=${cookie.value}')
            .join('; '),
      });
    }

    return result;
  }

  static Map<String, dynamic>? _buildBody(NetworkHttpRequest? request) {
    if (request == null) return null;

    final fields = request.formDataFields ?? const [];
    final files = request.formDataFiles ?? const [];
    final bool isMultipart =
        fields.isNotEmpty ||
        files.isNotEmpty ||
        (request.contentType?.toLowerCase().contains('multipart') ?? false);

    if (isMultipart && (fields.isNotEmpty || files.isNotEmpty)) {
      return <String, dynamic>{
        'mode': 'formdata',
        'formdata': [
          for (final field in fields)
            {'key': field.name, 'type': 'text', 'value': field.value},
          for (final file in files)
            {'key': file.fileName ?? 'file', 'type': 'file', 'src': file.fileName ?? ''},
        ],
      };
    }

    final dynamic body = request.body;
    if (body == null) return null;

    final bool isJson =
        body is Map ||
        body is List ||
        (request.contentType?.toLowerCase().contains('json') ?? false);
    final String raw = (body is Map || body is List)
        ? _encoder.convert(body)
        : body.toString();
    if (raw.isEmpty) return null;

    return <String, dynamic>{
      'mode': 'raw',
      'raw': raw,
      'options': {
        'raw': {'language': isJson ? 'json' : 'text'},
      },
    };
  }

  static Map<String, dynamic> _buildUrl(NetworkHttpCall call) {
    final String server = call.server;
    final bool hasScheme =
        server.startsWith('http://') || server.startsWith('https://');
    final String protocol = hasScheme
        ? Uri.parse(server).scheme
        : (call.secure ? 'https' : 'http');
    final String host = hasScheme ? Uri.parse(server).host : server;
    final String endpoint = call.endpoint;

    final Map<String, dynamic> queryParameters =
        call.request?.queryParameters ?? const {};
    final String queryString = queryParameters.isEmpty
        ? ''
        : '?${queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    return <String, dynamic>{
      'raw': '$protocol://$host$endpoint$queryString',
      'protocol': protocol,
      'host': host.split('.'),
      'path': endpoint.split('/').where((part) => part.isNotEmpty).toList(),
      if (queryParameters.isNotEmpty)
        'query': [
          for (final MapEntry<String, dynamic> entry
              in queryParameters.entries)
            {'key': entry.key, 'value': entry.value?.toString()},
        ],
    };
  }

  static String _requestDescription(NetworkHttpCall call) {
    final NetworkHttpRequest? request = call.request;
    return [
      if (call.client.isNotEmpty) 'client: ${call.client}',
      'secure: ${call.secure}',
      'duration(ms): ${call.duration}',
      if (request != null) 'requestTime: ${request.time.toIso8601String()}',
      if (request != null) 'requestSize(bytes): ${request.size}',
      if (request?.contentType?.isNotEmpty ?? false)
        'contentType: ${request?.contentType}',
    ].join('\n');
  }

  static List<Map<String, dynamic>>? _buildResponses(
    NetworkHttpCall call,
    Map<String, dynamic> request,
  ) {
    final response = call.response;
    if (response == null) return null;

    final Map<String, String> headers = response.headers ?? const {};
    final dynamic body = response.body;
    final String bodyString = body == null
        ? ''
        : (body is Map || body is List)
        ? _encoder.convert(body)
        : body.toString();

    // Postman's v2.1 schema requires `status` to be a string and `code` a
    // number (neither may be null). Omit them when the captured response has no
    // status (e.g. a timeout/connection error) so the whole collection stays
    // importable instead of failing schema validation.
    final String? statusText = _statusText(response.status);

    return [
      <String, dynamic>{
        'name': 'Response ${response.status ?? ''}'.trim(),
        'originalRequest': request,
        if (response.status != null) 'code': response.status,
        if (statusText != null) 'status': statusText,
        'header': [
          for (final MapEntry<String, String> entry in headers.entries)
            {'key': entry.key, 'value': entry.value},
        ],
        'cookie': const [],
        'body': bodyString,
        'responseTime': call.duration,
        '_postman_previewlanguage': 'json',
      },
    ];
  }

  static String? _statusText(int? status) {
    if (status == null) return null;
    return switch (status) {
      200 => 'OK',
      201 => 'Created',
      204 => 'No Content',
      301 => 'Moved Permanently',
      302 => 'Found',
      304 => 'Not Modified',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      409 => 'Conflict',
      422 => 'Unprocessable Entity',
      429 => 'Too Many Requests',
      500 => 'Internal Server Error',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable',
      _ => status.toString(),
    };
  }

  static String _sanitizeFileName(String value) {
    final String sanitized = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final String trimmed = sanitized.replaceAll(RegExp(r'^_+|_+$'), '');
    return trimmed.isEmpty ? 'app' : trimmed;
  }
}
