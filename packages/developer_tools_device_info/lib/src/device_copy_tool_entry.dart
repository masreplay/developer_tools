import 'dart:io' show Platform;

import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Single [DeveloperToolEntry] that copies all device information to the
/// clipboard as formatted text. Useful for quick bug reports.
///
/// If [instance] is provided, it will be used instead of creating a new one.
DeveloperToolEntry deviceCopyToolEntry({
  String? sectionLabel,
  DeviceInfoPlugin? instance,
}) {
  return DeveloperToolEntry(
    title: 'Copy Device Info',
    sectionLabel: sectionLabel,
    description: 'Copy all device info to clipboard',
    icon: Icons.copy_all,
    onTap: (BuildContext context) async {
      try {
        final info = await (instance ?? DeviceInfoPlugin()).deviceInfo;
        final text = _formatAllDeviceInfo(info);
        await Clipboard.setData(ClipboardData(text: text));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device info copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to copy device info: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    },
  );
}

String _formatAllDeviceInfo(BaseDeviceInfo info) {
  final buffer = StringBuffer();
  final timestamp = DateTime.now().toIso8601String();
  buffer.writeln('Device Info Report');
  buffer.writeln('Generated: $timestamp');
  buffer.writeln('=' * 40);
  buffer.writeln();

  // Platform identifier
  if (kIsWeb) {
    buffer.writeln('Platform: Web');
  } else {
    try {
      buffer.writeln('Platform: ${Platform.operatingSystem}');
      buffer.writeln('OS Version: ${Platform.operatingSystemVersion}');
      buffer.writeln('Dart Version: ${Platform.version}');
      buffer.writeln('Locale: ${Platform.localeName}');
      buffer.writeln('Num Processors: ${Platform.numberOfProcessors}');
    } catch (_) {
      buffer.writeln('Platform: Unknown');
    }
  }
  buffer.writeln();

  // All raw device info data
  buffer.writeln('--- Device Details ---');
  for (final entry in info.data.entries) {
    final value = entry.value;
    if (value is Map) {
      buffer.writeln('${entry.key}:');
      for (final subEntry in value.entries) {
        buffer.writeln('  ${subEntry.key}: ${subEntry.value}');
      }
    } else if (value is List) {
      buffer.writeln('${entry.key}: ${value.join(", ")}');
    } else {
      buffer.writeln('${entry.key}: $value');
    }
  }

  return buffer.toString();
}
