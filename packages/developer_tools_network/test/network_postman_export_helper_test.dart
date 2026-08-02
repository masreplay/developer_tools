import 'dart:convert' show jsonDecode;
import 'dart:io' show Cookie;

import 'package:developer_tools_network/network_inspector/helper/network_postman_export_helper.dart';
import 'package:developer_tools_network/network_inspector/model/network_form_data_file.dart';
import 'package:developer_tools_network/network_inspector/model/network_from_data_field.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_request.dart';
import 'package:developer_tools_network/network_inspector/model/network_export_result.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_response.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

NetworkHttpCall _call({
  required int id,
  required String method,
  String server = 'api.example.com',
  String endpoint = '/v1/users',
  bool secure = true,
  Map<String, String>? headers,
  Map<String, dynamic>? query,
  dynamic body,
  String? contentType,
  List<Cookie>? cookies,
  List<NetworkFormDataField>? formFields,
  List<NetworkFormDataFile>? formFiles,
  int? responseStatus,
  Map<String, String>? responseHeaders,
  dynamic responseBody,
}) {
  final call = NetworkHttpCall(id)
    ..method = method
    ..server = server
    ..endpoint = endpoint
    ..uri = '$server$endpoint'
    ..secure = secure
    ..client = 'dio'
    ..duration = 123;

  call.request = NetworkHttpRequest()
    ..headers = headers ?? <String, String>{}
    ..queryParameters = query ?? <String, dynamic>{}
    ..body = body ?? ''
    ..contentType = contentType
    ..cookies = cookies ?? <Cookie>[]
    ..formDataFields = formFields
    ..formDataFiles = formFiles;

  if (responseStatus != null) {
    call.response = NetworkHttpResponse()
      ..status = responseStatus
      ..headers = responseHeaders
      ..body = responseBody;
  }

  return call;
}

/// Builds the collection and round-trips it through JSON so every assertion
/// runs against the exact artifact that gets written to disk.
Map<String, dynamic> _exportedJson(List<NetworkHttpCall> calls) {
  final Map<String, dynamic> collection =
      NetworkPostmanExportHelper.buildCollection(
        name: 'Test Collection',
        description: 'desc',
        calls: calls,
      );
  return jsonDecode(NetworkPostmanExportHelper.encode(collection))
      as Map<String, dynamic>;
}

void main() {
  group('NetworkPostmanExportHelper.buildCollection', () {
    test('produces valid v2.1 info and one item per call', () {
      final json = _exportedJson([
        _call(id: 1, method: 'GET'),
        _call(id: 2, method: 'DELETE'),
      ]);

      expect(json['info']['schema'], NetworkPostmanExportHelper.schemaV210);
      expect(json['info']['name'], 'Test Collection');
      expect(json['info']['description'], 'desc');
      expect((json['item'] as List), hasLength(2));
    });

    test('empty calls yields an empty item list', () {
      final json = _exportedJson(const []);
      expect((json['item'] as List), isEmpty);
    });

    test('maps method, headers, url parts and query params', () {
      final json = _exportedJson([
        _call(
          id: 1,
          method: 'GET',
          server: 'api.example.com',
          endpoint: '/v1/users',
          secure: true,
          headers: {'Authorization': 'Bearer abc', 'X-Tenant': 'acme'},
          query: {'page': 2, 'q': 'john'},
        ),
      ]);

      final request = json['item'][0]['request'] as Map<String, dynamic>;
      expect(request['method'], 'GET');

      final headers = (request['header'] as List).cast<Map<String, dynamic>>();
      expect(
        headers.firstWhere((h) => h['key'] == 'Authorization')['value'],
        'Bearer abc',
      );

      final url = request['url'] as Map<String, dynamic>;
      expect(url['protocol'], 'https');
      expect(url['host'], ['api', 'example', 'com']);
      expect(url['path'], ['v1', 'users']);
      expect(url['raw'], contains('page=2'));

      final query = (url['query'] as List).cast<Map<String, dynamic>>();
      expect(query.firstWhere((q) => q['key'] == 'q')['value'], 'john');
    });

    test('uses http scheme when call is not secure and server has no scheme', () {
      final json = _exportedJson([
        _call(id: 1, method: 'GET', server: 'plain.local', secure: false),
      ]);
      final url = json['item'][0]['request']['url'] as Map<String, dynamic>;
      expect(url['protocol'], 'http');
      expect(url['raw'], startsWith('http://plain.local'));
    });

    test('encodes a JSON Map body as raw json', () {
      final json = _exportedJson([
        _call(
          id: 1,
          method: 'POST',
          contentType: 'application/json',
          body: {'name': 'john', 'age': 30},
        ),
      ]);

      final body = json['item'][0]['request']['body'] as Map<String, dynamic>;
      expect(body['mode'], 'raw');
      expect(body['raw'], contains('"name": "john"'));
      expect(body['options']['raw']['language'], 'json');
    });

    test('maps multipart form data into formdata mode', () {
      final json = _exportedJson([
        _call(
          id: 1,
          method: 'POST',
          contentType: 'multipart/form-data',
          formFields: const [NetworkFormDataField('title', 'hello')],
          formFiles: const [
            NetworkFormDataFile('avatar.png', 'image/png', 1024),
          ],
        ),
      ]);

      final body = json['item'][0]['request']['body'] as Map<String, dynamic>;
      expect(body['mode'], 'formdata');
      final formdata = (body['formdata'] as List).cast<Map<String, dynamic>>();
      expect(formdata.firstWhere((e) => e['key'] == 'title')['type'], 'text');
      expect(
        formdata.firstWhere((e) => e['key'] == 'avatar.png')['type'],
        'file',
      );
    });

    test('folds request cookies into a Cookie header', () {
      final json = _exportedJson([
        _call(
          id: 1,
          method: 'GET',
          cookies: [Cookie('session', 'xyz'), Cookie('theme', 'dark')],
        ),
      ]);

      final headers =
          (json['item'][0]['request']['header'] as List)
              .cast<Map<String, dynamic>>();
      final cookieHeader = headers.firstWhere((h) => h['key'] == 'Cookie');
      expect(cookieHeader['value'], 'session=xyz; theme=dark');
    });

    test('captures the response as a saved example', () {
      final json = _exportedJson([
        _call(
          id: 1,
          method: 'GET',
          responseStatus: 200,
          responseHeaders: {'Content-Type': 'application/json'},
          responseBody: {'ok': true},
        ),
      ]);

      final responses = (json['item'][0]['response'] as List)
          .cast<Map<String, dynamic>>();
      expect(responses, hasLength(1));
      expect(responses[0]['code'], 200);
      expect(responses[0]['status'], 'OK');
      expect(responses[0]['body'], contains('"ok": true'));
    });

    test('omits response list when no response captured', () {
      final json = _exportedJson([_call(id: 1, method: 'GET')]);
      expect(json['item'][0]['response'], isNull);
    });

    test('omits status/code when response status is null (schema-safe)', () {
      // A timeout/connection error can leave the response without a status.
      // Postman's v2.1 schema rejects `status: null`, which would make the
      // whole collection fail to import — so the keys must be absent.
      final call = _call(id: 1, method: 'GET');
      call.response = NetworkHttpResponse()..status = null;

      final json = _exportedJson([call]);
      final response =
          (json['item'][0]['response'] as List).cast<Map<String, dynamic>>()[0];

      expect(response.containsKey('status'), isFalse);
      expect(response.containsKey('code'), isFalse);
    });
  });

  group('NetworkPostmanExportHelper.copyCalls', () {
    test('returns empty error for no calls', () async {
      final result = await NetworkPostmanExportHelper.copyCalls(calls: const []);
      expect(result.success, isFalse);
      expect(result.error, NetworkExportResultError.empty);
    });

    testWidgets('copies a valid Postman collection JSON to the clipboard', (
      tester,
    ) async {
      PackageInfo.setMockInitialValues(
        appName: 'TabadulX',
        packageName: 'iq.tabadul.x',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      String? clipboardText;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardText = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );

      final result = await NetworkPostmanExportHelper.copyCalls(
        calls: [_call(id: 1, method: 'GET')],
      );

      expect(result.success, isTrue);
      expect(clipboardText, isNotNull);
      final decoded = jsonDecode(clipboardText!) as Map<String, dynamic>;
      expect(decoded['info']['schema'], NetworkPostmanExportHelper.schemaV210);
      expect((decoded['item'] as List), hasLength(1));

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
  });
}
