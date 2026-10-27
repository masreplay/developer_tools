// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show JsonEncoder, base64Decode, jsonDecode;
import 'dart:io' show Directory, File;
import 'dart:typed_data' show Uint8List;

import 'package:archive/archive.dart' show Archive, ArchiveFile, ZipEncoder;
import 'package:developer_tools_network/network_inspector/core/network_utils.dart';
import 'package:developer_tools_network/network_inspector/model/network_export_result.dart';
import 'package:developer_tools_network/network_inspector/model/network_form_data_file.dart';
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
      'item': [
        for (int i = 0; i < calls.length; i++) _buildItem(calls[i], i),
      ],
    };
  }

  /// Encodes a [collection] map to a pretty-printed JSON string.
  static String encode(Map<String, dynamic> collection) =>
      _encoder.convert(collection);

  /// Every file the [calls] carried, as real files to share with the
  /// collection: multipart uploads (named as the collection's form-data `src`,
  /// so Postman finds them on replay) and images, videos or PDFs sent or
  /// received as base64 inside a JSON body (e.g. a selfie or a signature).
  static List<NetworkExportAttachment> buildAttachments(
    List<NetworkHttpCall> calls,
  ) {
    final List<NetworkExportAttachment> result = [];
    final Set<String> seen = {};
    for (int i = 0; i < calls.length; i++) {
      final NetworkHttpCall call = calls[i];
      for (final NetworkFormDataFile file
          in call.request?.formDataFiles ?? const <NetworkFormDataFile>[]) {
        final Uint8List? bytes = file.bytes;
        if (bytes != null) {
          result.add(NetworkExportAttachment(_attachmentName(i, file), bytes));
        }
      }
      void scan(String side, dynamic body) {
        _findBase64Media(body, '', (String key, Uint8List bytes, String ext) {
          final String name = _sanitizeFileName(
            '${_pad(i)}_${side}_${key.isEmpty ? 'body' : key}',
          );
          if (seen.add('$name.$ext')) {
            result.add(NetworkExportAttachment('$name.$ext', bytes));
          }
        });
      }

      scan('request', call.request?.body);
      scan('response', call.response?.body);
    }
    return result;
  }

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
      final String baseName =
          '${_sanitizeFileName(packageInfo.appName)}_network_'
          '${DateTime.now().millisecondsSinceEpoch}';
      final File file = File('${dir.path}/$baseName.zip')
        ..createSync(recursive: true)
        ..writeAsBytesSync(buildZip(name: baseName, json: json, calls: calls));

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

  /// One zip with the collection and every file it refers to, side by side, so
  /// unzipping into Postman's working directory makes every upload replayable.
  static List<int> buildZip({
    required String name,
    required String json,
    required List<NetworkHttpCall> calls,
  }) {
    final Archive archive = Archive()
      ..add(
        ArchiveFile.string('$name.postman_collection.json', json),
      );
    for (final NetworkExportAttachment attachment in buildAttachments(calls)) {
      archive.add(
        ArchiveFile.bytes(attachment.name, attachment.bytes),
      );
    }
    return ZipEncoder().encodeBytes(archive);
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
  static Map<String, dynamic> _buildItem(NetworkHttpCall call, int index) {
    final Map<String, dynamic> request = _buildRequest(call, index);
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

  static Map<String, dynamic> _buildRequest(NetworkHttpCall call, int index) {
    final Map<String, dynamic>? body = _buildBody(call.request, index);
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

  static Map<String, dynamic>? _buildBody(
    NetworkHttpRequest? request,
    int index,
  ) {
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
            {
              'key': file.fieldName ?? file.fileName ?? 'file',
              'type': 'file',
              'src': file.bytes != null
                  ? _attachmentName(index, file)
                  : file.fileName ?? '',
            },
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
          for (final MapEntry<String, dynamic> entry in queryParameters.entries)
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

  /// [body] with every base64 image, video or PDF replaced by a short label,
  /// so the inspector shows the file in "Files" instead of pages of base64.
  static dynamic labelBase64Media(dynamic body) {
    if (body is Map) {
      return {
        for (final entry in body.entries)
          entry.key: labelBase64Media(entry.value),
      };
    }
    if (body is List) return [for (final item in body) labelBase64Media(item)];
    if (body is! String) return body;
    String? label;
    _findBase64Media(body, '', (String key, Uint8List bytes, String ext) {
      if (key.isEmpty)
        label =
            '<$ext file, ${(bytes.length / 1024).toStringAsFixed(1)} kB, see Files>';
    });
    if (label != null) return label;
    final String trimmed = body.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        return labelBase64Media(jsonDecode(trimmed));
      } catch (_) {}
    }
    return body;
  }

  static String _pad(int index) => index.toString().padLeft(3, '0');

  /// The shared file name of an upload: its call's position, field and name,
  /// so two calls uploading `front_image.jpg` never overwrite each other.
  static String _attachmentName(
    int index,
    NetworkFormDataFile file,
  ) => _sanitizeFileName(
    '${_pad(index)}_${file.fieldName ?? 'file'}_${file.fileName ?? 'upload'}',
  );

  static const Map<String, List<int>> _signatures = {
    'jpg': [0xFF, 0xD8, 0xFF],
    'png': [0x89, 0x50, 0x4E, 0x47],
    'gif': [0x47, 0x49, 0x46, 0x38],
    'pdf': [0x25, 0x50, 0x44, 0x46],
    'webm': [0x1A, 0x45, 0xDF, 0xA3],
  };

  /// The media type of [bytes] by its magic number, or null when it is not one.
  static String? _mediaExtension(Uint8List bytes) {
    if (bytes.length > 8 &&
        String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp') {
      return 'mp4';
    }
    for (final MapEntry<String, List<int>> entry in _signatures.entries) {
      final List<int> magic = entry.value;
      if (bytes.length > magic.length &&
          Iterable<int>.generate(magic.length)
              .every((i) => bytes[i] == magic[i])) {
        return entry.key;
      }
    }
    return null;
  }

  static final RegExp _base64Payload = RegExp(
    r'^(?:data:[\w/+.-]+;base64,)?([A-Za-z0-9+/\r\n]{1000,}={0,2})$',
  );

  /// Walks a JSON body and reports every string that is a base64 image,
  /// video or PDF, with the JSON key it was under.
  static void _findBase64Media(
    dynamic value,
    String key,
    void Function(String key, Uint8List bytes, String ext) found,
  ) {
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          _findBase64Media(jsonDecode(trimmed), key, found);
        } catch (_) {}
        return;
      }
      final Match? match = _base64Payload.firstMatch(trimmed);
      if (match == null) return;
      try {
        final Uint8List bytes = base64Decode(
          match.group(1)!.replaceAll(RegExp(r'\s'), ''),
        );
        final String? ext = _mediaExtension(bytes);
        if (ext != null) found(key, bytes, ext);
      } catch (_) {}
    } else if (value is Map) {
      value.forEach(
        (k, v) => _findBase64Media(v, key.isEmpty ? '$k' : '${key}_$k', found),
      );
    } else if (value is List) {
      for (int i = 0; i < value.length; i++) {
        _findBase64Media(value[i], '${key}_$i', found);
      }
    }
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

/// A file exported next to the collection.
class NetworkExportAttachment {
  const NetworkExportAttachment(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}
