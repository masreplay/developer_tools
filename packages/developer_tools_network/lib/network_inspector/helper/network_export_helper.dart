// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show JsonEncoder;
import 'dart:io' show Directory, File, FileMode, IOSink;

import 'package:developer_tools_network/network_inspector/core/network_utils.dart';
import 'package:developer_tools_network/network_inspector/helper/network_conversion_helper.dart';
import 'package:developer_tools_network/network_inspector/helper/operating_system.dart';
import 'package:developer_tools_network/network_inspector/model/network_export_result.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:developer_tools_network/network_inspector/utils/network_parser.dart';
import 'package:developer_tools_network/network_inspector/utils/curl.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class NetworkExportHelper {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');
  static const String _fileName = 'network_log';

  /// Format log based on [call] and tries to share it.
  static Future<NetworkExportResult> shareCall({
    required BuildContext context,
    required NetworkHttpCall call,
  }) async {
    final callLog = await NetworkExportHelper.buildFullCallLog(
      call: call,
      context: context,
    );

    if (callLog == null) {
      return NetworkExportResult(
        success: false,
        error: NetworkExportResultError.logGenerate,
      );
    }

    await SharePlus.instance.share(
      ShareParams(
        text: callLog,
        subject: context.i18n(NetworkTranslationKey.emailSubject),
      ),
    );

    return NetworkExportResult(success: true);
  }

  /// Format log based on [calls] and saves it to file.
  static Future<NetworkExportResult> saveCallsToFile(
    BuildContext context,
    List<NetworkHttpCall> calls,
  ) async {
    final bool permissionStatus = await _getPermissionStatus();
    if (!permissionStatus) {
      final bool status = await _requestPermission();
      if (!status) {
        return NetworkExportResult(
          success: false,
          error: NetworkExportResultError.permission,
        );
      }
    }

    return await _saveToFile(context, calls);
  }

  /// Returns current storage permission status. Checks permission for iOS
  /// For other platforms it returns true.
  static Future<bool> _getPermissionStatus() async {
    if (OperatingSystem.isIOS) {
      return Permission.storage.status.isGranted;
    } else {
      return true;
    }
  }

  /// Requests permissions for storage for iOS. For other platforms it doesn't
  /// make any action and returns true.
  static Future<bool> _requestPermission() async {
    if (OperatingSystem.isIOS) {
      return Permission.storage.request().isGranted;
    } else {
      return true;
    }
  }

  /// Saves [calls] to file. For android it uses external storage directory and
  /// for ios it uses application documents directory.
  static Future<NetworkExportResult> _saveToFile(
    BuildContext context,
    List<NetworkHttpCall> calls,
  ) async {
    try {
      if (calls.isEmpty) {
        return NetworkExportResult(
          success: false,
          error: NetworkExportResultError.empty,
        );
      }

      final Directory externalDir = await getApplicationCacheDirectory();
      final String fileName =
          '${_fileName}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final File file = File('${externalDir.path}/$fileName')..createSync();
      final IOSink sink = file.openWrite(mode: FileMode.append)
        ..write(await _buildNetworkLog(context: context));
      for (final NetworkHttpCall call in calls) {
        sink.write(_buildCallLog(context: context, call: call));
      }
      await sink.flush();
      await sink.close();

      return NetworkExportResult(success: true, path: file.path);
    } catch (exception) {
      NetworkUtils.log(exception.toString());
      return NetworkExportResult(
        success: false,
        error: NetworkExportResultError.file,
      );
    }
  }

  /// Builds log string based on data collected from package info.
  static Future<String> _buildNetworkLog({
    required BuildContext context,
  }) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return '${context.i18n(NetworkTranslationKey.saveHeaderTitle)}\n'
        '${context.i18n(NetworkTranslationKey.saveHeaderAppName)}  ${packageInfo.appName}\n'
        '${context.i18n(NetworkTranslationKey.saveHeaderPackage)} ${packageInfo.packageName}\n'
        '${context.i18n(NetworkTranslationKey.saveHeaderTitle)} ${packageInfo.version}\n'
        '${context.i18n(NetworkTranslationKey.saveHeaderBuildNumber)} ${packageInfo.buildNumber}\n'
        '${context.i18n(NetworkTranslationKey.saveHeaderGenerated)} ${DateTime.now().toIso8601String()}\n'
        '\n';
  }

  /// Build log string based on [call].
  static String _buildCallLog({
    required BuildContext context,
    required NetworkHttpCall call,
  }) {
    final StringBuffer stringBuffer =
        StringBuffer()..writeAll([
          '===========================================\n',
          '${context.i18n(NetworkTranslationKey.saveLogId)} ${call.id}\n',
          '============================================\n',
          '--------------------------------------------\n',
          '${context.i18n(NetworkTranslationKey.saveLogGeneralData)}\n',
          '--------------------------------------------\n',
          '${context.i18n(NetworkTranslationKey.saveLogServer)} ${call.server} \n',
          '${context.i18n(NetworkTranslationKey.saveLogMethod)} ${call.method} \n',
          '${context.i18n(NetworkTranslationKey.saveLogEndpoint)} ${call.endpoint} \n',
          '${context.i18n(NetworkTranslationKey.saveLogClient)} ${call.client} \n',
          '${context.i18n(NetworkTranslationKey.saveLogDuration)} ${NetworkConversionHelper.formatTime(call.duration)}\n',
          '${context.i18n(NetworkTranslationKey.saveLogSecured)} ${call.secure}\n',
          '${context.i18n(NetworkTranslationKey.saveLogCompleted)}: ${!call.loading} \n',
          '--------------------------------------------\n',
          '${context.i18n(NetworkTranslationKey.saveLogRequest)}\n',
          '--------------------------------------------\n',
          '${context.i18n(NetworkTranslationKey.saveLogRequestTime)} ${call.request?.time}\n',
          '${context.i18n(NetworkTranslationKey.saveLogRequestContentType)}: ${call.request?.contentType}\n',
          '${context.i18n(NetworkTranslationKey.saveLogRequestCookies)} ${_encoder.convert(call.request?.cookies)}\n',
          '${context.i18n(NetworkTranslationKey.saveLogRequestHeaders)} ${_encoder.convert(call.request?.headers)}\n',
        ]);

    if (call.request?.queryParameters.isNotEmpty ?? false) {
      stringBuffer.write(
        '${context.i18n(NetworkTranslationKey.saveLogRequestQueryParams)} ${_encoder.convert(call.request?.queryParameters)}\n',
      );
    }

    stringBuffer.writeAll([
      '${context.i18n(NetworkTranslationKey.saveLogRequestSize)} ${NetworkConversionHelper.formatBytes(call.request?.size ?? 0)}\n',
      '${context.i18n(NetworkTranslationKey.saveLogRequestBody)} ${NetworkParser.formatBody(context: context, body: call.request?.body, contentType: call.request?.contentType)}\n',
      '--------------------------------------------\n',
      '${context.i18n(NetworkTranslationKey.saveLogResponse)}\n',
      '--------------------------------------------\n',
      '${context.i18n(NetworkTranslationKey.saveLogResponseTime)} ${call.response?.time}\n',
      '${context.i18n(NetworkTranslationKey.saveLogResponseStatus)} ${call.response?.status}\n',
      '${context.i18n(NetworkTranslationKey.saveLogResponseSize)} ${NetworkConversionHelper.formatBytes(call.response?.size ?? 0)}\n',
      '${context.i18n(NetworkTranslationKey.saveLogResponseHeaders)} ${_encoder.convert(call.response?.headers)}\n',
      '${context.i18n(NetworkTranslationKey.saveLogResponseBody)} ${NetworkParser.formatBody(context: context, body: call.response?.body, contentType: NetworkParser.getContentType(context: context, headers: call.response?.headers))}\n',
    ]);

    if (call.error != null) {
      stringBuffer.writeAll([
        '--------------------------------------------\n',
        '${context.i18n(NetworkTranslationKey.saveLogError)}\n',
        '--------------------------------------------\n',
        '${context.i18n(NetworkTranslationKey.saveLogError)}: ${call.error?.error}\n',
      ]);

      if (call.error?.stackTrace != null) {
        stringBuffer.write(
          '${context.i18n(NetworkTranslationKey.saveLogStackTrace)}: ${call.error?.stackTrace}\n',
        );
      }
    }

    stringBuffer.writeAll([
      '--------------------------------------------\n',
      '${context.i18n(NetworkTranslationKey.saveLogCurl)}\n',
      '--------------------------------------------\n',
      Curl.getCurlCommand(call),
      '\n',
      '==============================================\n',
      '\n',
    ]);

    return stringBuffer.toString();
  }

  /// Builds full call log string (package info log and call log).
  static Future<String?> buildFullCallLog({
    required BuildContext context,
    required NetworkHttpCall call,
  }) async {
    try {
      return await _buildNetworkLog(context: context) +
          _buildCallLog(call: call, context: context);
    } catch (exception) {
      NetworkUtils.log('Failed to generate call log: $exception');
      return null;
    }
  }
}
