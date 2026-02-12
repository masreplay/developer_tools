import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Single [DeveloperToolEntry] that copies all package information to the
/// clipboard as formatted text. Useful for quick bug reports.
DeveloperToolEntry packageCopyToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Copy Package Info',
    sectionLabel: sectionLabel,
    description: 'Copy app name, version, and build to clipboard',
    icon: Icons.copy_all,
    onTap: (BuildContext context) async {
      try {
        final info = await PackageInfo.fromPlatform();
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
