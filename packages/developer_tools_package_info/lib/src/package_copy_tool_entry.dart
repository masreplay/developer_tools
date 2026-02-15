import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Single [DeveloperToolEntry] that copies all package information to the
/// clipboard as formatted text. Useful for quick bug reports.
///
/// If [instance] is provided, it will be used instead of calling
/// [PackageInfo.fromPlatform].
DeveloperToolEntry packageCopyToolEntry({
  String? sectionLabel,
  PackageInfo? instance,
}) {
  return DeveloperToolEntry(
    title: 'Copy Package Info',
    sectionLabel: sectionLabel,
    description: 'Copy app name, version, and build to clipboard',
    icon: Icons.copy_all,
    debugInfo: (_) async {
      try {
        final info = instance ?? await PackageInfo.fromPlatform();
        final buffer = StringBuffer();
        buffer.writeln('App Name: ${info.appName}');
        buffer.writeln('Package Name: ${info.packageName}');
        buffer.writeln('Version: ${info.version}');
        buffer.writeln('Build Number: ${info.buildNumber}');
        if (info.buildSignature.isNotEmpty) {
          buffer.writeln('Build Signature: ${info.buildSignature}');
        }
        if (info.installerStore != null) {
          buffer.writeln('Installer Store: ${info.installerStore}');
        }
        if (info.installTime != null) {
          buffer.writeln(
            'Install Time: ${info.installTime!.toIso8601String()}',
          );
        }
        if (info.updateTime != null) {
          buffer.writeln('Update Time: ${info.updateTime!.toIso8601String()}');
        }
        return buffer.toString();
      } catch (e) {
        return 'Error fetching package info: $e';
      }
    },
    onTap: (BuildContext context) async {
      try {
        final info = instance ?? await PackageInfo.fromPlatform();
        final buffer = StringBuffer();
        buffer.writeln(
          '${info.appName} v${info.version} (${info.buildNumber})',
        );
        buffer.writeln('Package: ${info.packageName}');
        if (info.buildSignature.isNotEmpty) {
          buffer.writeln('Signature: ${info.buildSignature}');
        }
        if (info.installerStore != null) {
          buffer.writeln('Store: ${info.installerStore}');
        }
        await Clipboard.setData(ClipboardData(text: buffer.toString()));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Package info copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to copy package info: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    },
  );
}
