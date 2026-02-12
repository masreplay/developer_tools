import 'dart:io' show Platform;

import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Single [DeveloperToolEntry] that opens a dialog showing all available device
/// information, organized by category (general, OS, hardware, identifiers).
///
/// Uses [DeviceInfoPlugin] to fetch platform-specific device info.
DeveloperToolEntry deviceOverviewToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Device Info',
    sectionLabel: sectionLabel,
    description: _platformDescription(),
    icon: Icons.phone_android,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _DeviceOverviewDialog();
        },
      );
    },
  );
}

String _platformDescription() {
  if (kIsWeb) return 'View web browser information';
  try {
    if (Platform.isAndroid) return 'View Android device information';
    if (Platform.isIOS) return 'View iOS device information';
    if (Platform.isMacOS) return 'View macOS device information';
    if (Platform.isLinux) return 'View Linux device information';
    if (Platform.isWindows) return 'View Windows device information';
  } catch (_) {}
  return 'View device information';
}

class _DeviceOverviewDialog extends StatefulWidget {
  const _DeviceOverviewDialog();

  @override
  State<_DeviceOverviewDialog> createState() => _DeviceOverviewDialogState();
}

class _DeviceOverviewDialogState extends State<_DeviceOverviewDialog> {
  late final Future<BaseDeviceInfo> _infoFuture;

  @override
  void initState() {
    super.initState();
    _infoFuture = DeviceInfoPlugin().deviceInfo;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.phone_android, size: 24),
          SizedBox(width: 8),
          Expanded(child: Text('Device Info')),
        ],
      ),
      content: SizedBox(
        width: 480,
        height: 520,
        child: FutureBuilder<BaseDeviceInfo>(
          future: _infoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading device info:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }
            final info = snapshot.data!;
            return _buildInfoContent(context, info);
          },
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () async {
            try {
              final info = await _infoFuture;
              final text = _formatDeviceInfoForCopy(info);
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Device info copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (_) {}
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy All'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoContent(BuildContext context, BaseDeviceInfo info) {
    final List<Widget> children = [];

    if (info is AndroidDeviceInfo) {
      children.addAll(_buildAndroidInfo(info));
    } else if (info is IosDeviceInfo) {
      children.addAll(_buildIosInfo(info));
    } else if (info is MacOsDeviceInfo) {
      children.addAll(_buildMacOsInfo(info));
    } else if (info is LinuxDeviceInfo) {
      children.addAll(_buildLinuxInfo(info));
    } else if (info is WindowsDeviceInfo) {
      children.addAll(_buildWindowsInfo(info));
    } else if (info is WebBrowserInfo) {
      children.addAll(_buildWebInfo(info));
    } else {
      // Fallback: show raw data map
      children.add(const _SectionHeader('Device Info'));
      for (final entry in info.data.entries) {
        children.add(_InfoRow(entry.key, entry.value?.toString() ?? 'N/A'));
      }
    }

    return ListView(children: children);
  }

  List<Widget> _buildAndroidInfo(AndroidDeviceInfo info) {
    return [
      const _SectionHeader('General'),
      _InfoRow('Brand', info.brand),
      _InfoRow('Manufacturer', info.manufacturer),
      _InfoRow('Model', info.model),
      _InfoRow('Product', info.product),
      _InfoRow('Device', info.device),
      _InfoRow('Is Physical', info.isPhysicalDevice.toString()),
      const SizedBox(height: 8),
      const _SectionHeader('Android OS'),
      _InfoRow('Version', info.version.release),
      _InfoRow('SDK Int', info.version.sdkInt.toString()),
      _InfoRow('Security Patch', info.version.securityPatch ?? 'N/A'),
      _InfoRow('Codename', info.version.codename),
      _InfoRow('Incremental', info.version.incremental),
      _InfoRow('Preview SDK', info.version.previewSdkInt?.toString() ?? 'N/A'),
      _InfoRow('Base OS', info.version.baseOS ?? 'N/A'),
      const SizedBox(height: 8),
      const _SectionHeader('Hardware'),
      _InfoRow('Hardware', info.hardware),
      _InfoRow('Host', info.host),
      _InfoRow('Board', info.board),
      _InfoRow('Bootloader', info.bootloader),
      _InfoRow('Display', info.display),
      _InfoRow('Supported ABIs', info.supportedAbis.join(', ')),
      _InfoRow('Supported 32-bit ABIs', info.supported32BitAbis.join(', ')),
      _InfoRow('Supported 64-bit ABIs', info.supported64BitAbis.join(', ')),
      _InfoRow('System Features', '${info.systemFeatures.length} features'),
      const SizedBox(height: 8),
      const _SectionHeader('Identifiers'),
      _InfoRow('ID', info.id),
      _InfoRow('Fingerprint', info.fingerprint),
      _InfoRow('Serial', info.serialNumber),
      _InfoRow('Tags', info.tags),
      _InfoRow('Type', info.type),
    ];
  }

  List<Widget> _buildIosInfo(IosDeviceInfo info) {
    return [
      const _SectionHeader('General'),
      _InfoRow('Name', info.name),
      _InfoRow('Model', info.model),
      _InfoRow('Localized Model', info.localizedModel),
      _InfoRow('Is Physical', info.isPhysicalDevice.toString()),
      const SizedBox(height: 8),
      const _SectionHeader('iOS'),
      _InfoRow('System Name', info.systemName),
      _InfoRow('System Version', info.systemVersion),
      const SizedBox(height: 8),
      const _SectionHeader('Identifiers'),
      _InfoRow('Identifier For Vendor', info.identifierForVendor ?? 'N/A'),
      const SizedBox(height: 8),
      const _SectionHeader('Utsname'),
      _InfoRow('Sysname', info.utsname.sysname),
      _InfoRow('Nodename', info.utsname.nodename),
      _InfoRow('Release', info.utsname.release),
      _InfoRow('Version', info.utsname.version),
      _InfoRow('Machine', info.utsname.machine),
    ];
  }

  List<Widget> _buildMacOsInfo(MacOsDeviceInfo info) {
    return [
      const _SectionHeader('General'),
      _InfoRow('Computer Name', info.computerName),
      _InfoRow('Host Name', info.hostName),
      _InfoRow('Model', info.model),
      const SizedBox(height: 8),
      const _SectionHeader('macOS'),
      _InfoRow('OS Release', info.osRelease),
      _InfoRow('Major Version', info.majorVersion.toString()),
      _InfoRow('Minor Version', info.minorVersion.toString()),
      _InfoRow('Patch Version', info.patchVersion.toString()),
      _InfoRow('Kernel Version', info.kernelVersion),
      const SizedBox(height: 8),
      const _SectionHeader('Hardware'),
      _InfoRow('Architecture', info.arch),
      _InfoRow('Active CPUs', info.activeCPUs.toString()),
      _InfoRow('Memory Size', _formatBytes(info.memorySize)),
      _InfoRow('CPU Frequency', '${info.cpuFrequency} MHz'),
      const SizedBox(height: 8),
      const _SectionHeader('Identifiers'),
      _InfoRow('System GUID', info.systemGUID ?? 'N/A'),
    ];
  }

  List<Widget> _buildLinuxInfo(LinuxDeviceInfo info) {
    return [
      const _SectionHeader('General'),
      _InfoRow('Name', info.name),
      _InfoRow('Pretty Name', info.prettyName),
      _InfoRow('Version', info.version ?? 'N/A'),
      _InfoRow('Version ID', info.versionId ?? 'N/A'),
      _InfoRow('Version Codename', info.versionCodename ?? 'N/A'),
      const SizedBox(height: 8),
      const _SectionHeader('System'),
      _InfoRow('ID', info.id),
      _InfoRow('ID Like', info.idLike?.join(', ') ?? 'N/A'),
      _InfoRow('Build ID', info.buildId ?? 'N/A'),
      _InfoRow('Variant', info.variant ?? 'N/A'),
      _InfoRow('Variant ID', info.variantId ?? 'N/A'),
      _InfoRow('Machine ID', info.machineId ?? 'N/A'),
    ];
  }

  List<Widget> _buildWindowsInfo(WindowsDeviceInfo info) {
    return [
      const _SectionHeader('General'),
      _InfoRow('Computer Name', info.computerName),
      _InfoRow('Product Name', info.productName),
      _InfoRow('Number Of Cores', info.numberOfCores.toString()),
      _InfoRow('System Memory', '${info.systemMemoryInMegabytes} MB'),
      const SizedBox(height: 8),
      const _SectionHeader('Windows'),
      _InfoRow('Major Version', info.majorVersion.toString()),
      _InfoRow('Minor Version', info.minorVersion.toString()),
      _InfoRow('Build Number', info.buildNumber.toString()),
      _InfoRow('Platform ID', info.platformId.toString()),
      _InfoRow('Build Lab', info.buildLab),
      _InfoRow('Build Lab Ex', info.buildLabEx),
      _InfoRow('CSD Version', info.csdVersion),
      _InfoRow('Service Pack Major', info.servicePackMajor.toString()),
      _InfoRow('Service Pack Minor', info.servicePackMinor.toString()),
      _InfoRow('Edition ID', info.editionId ?? 'N/A'),
      _InfoRow('Product ID', info.productId),
      _InfoRow('Display Version', info.displayVersion),
      const SizedBox(height: 8),
      const _SectionHeader('Identifiers'),
      _InfoRow('Device ID', info.deviceId),
      _InfoRow('Registered Owner', info.registeredOwner),
    ];
  }

  List<Widget> _buildWebInfo(WebBrowserInfo info) {
    return [
      const _SectionHeader('Browser'),
      _InfoRow('Browser Name', info.browserName.name),
      _InfoRow('User Agent', info.userAgent ?? 'N/A'),
      _InfoRow('App Name', info.appName),
      _InfoRow('App Version', info.appVersion),
      _InfoRow('App Code Name', info.appCodeName),
      const SizedBox(height: 8),
      const _SectionHeader('Platform'),
      _InfoRow('Platform', info.platform ?? 'N/A'),
      _InfoRow('Product', info.product),
      _InfoRow('Product Sub', info.productSub ?? 'N/A'),
      _InfoRow('Vendor', info.vendor),
      _InfoRow('Vendor Sub', info.vendorSub),
      const SizedBox(height: 8),
      const _SectionHeader('Capabilities'),
      _InfoRow('Language', info.language ?? 'N/A'),
      _InfoRow('Languages', info.languages?.join(', ') ?? 'N/A'),
      _InfoRow('Hardware Concurrency', info.hardwareConcurrency.toString()),
      _InfoRow('Max Touch Points', info.maxTouchPoints.toString()),
    ];
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

String _formatDeviceInfoForCopy(BaseDeviceInfo info) {
  final buffer = StringBuffer();
  buffer.writeln('=== Device Info ===');

  if (info is AndroidDeviceInfo) {
    buffer.writeln('Platform: Android');
    buffer.writeln('Brand: ${info.brand}');
    buffer.writeln('Manufacturer: ${info.manufacturer}');
    buffer.writeln('Model: ${info.model}');
    buffer.writeln('Product: ${info.product}');
    buffer.writeln('Device: ${info.device}');
    buffer.writeln('Is Physical: ${info.isPhysicalDevice}');
    buffer.writeln('Android Version: ${info.version.release}');
    buffer.writeln('SDK Int: ${info.version.sdkInt}');
    buffer.writeln('Security Patch: ${info.version.securityPatch ?? "N/A"}');
    buffer.writeln('Hardware: ${info.hardware}');
    buffer.writeln('Board: ${info.board}');
    buffer.writeln('Bootloader: ${info.bootloader}');
    buffer.writeln('Display: ${info.display}');
    buffer.writeln('Fingerprint: ${info.fingerprint}');
    buffer.writeln('Supported ABIs: ${info.supportedAbis.join(", ")}');
    buffer.writeln('ID: ${info.id}');
    buffer.writeln('Serial: ${info.serialNumber}');
  } else if (info is IosDeviceInfo) {
    buffer.writeln('Platform: iOS');
    buffer.writeln('Name: ${info.name}');
    buffer.writeln('Model: ${info.model}');
    buffer.writeln('System Name: ${info.systemName}');
    buffer.writeln('System Version: ${info.systemVersion}');
    buffer.writeln('Is Physical: ${info.isPhysicalDevice}');
    buffer.writeln('Machine: ${info.utsname.machine}');
    buffer.writeln(
      'Identifier For Vendor: ${info.identifierForVendor ?? "N/A"}',
    );
  } else if (info is MacOsDeviceInfo) {
    buffer.writeln('Platform: macOS');
    buffer.writeln('Computer Name: ${info.computerName}');
    buffer.writeln('Host Name: ${info.hostName}');
    buffer.writeln('Model: ${info.model}');
    buffer.writeln('OS Release: ${info.osRelease}');
    buffer.writeln('Architecture: ${info.arch}');
    buffer.writeln('Active CPUs: ${info.activeCPUs}');
    buffer.writeln('Memory: ${info.memorySize} bytes');
    buffer.writeln('Kernel Version: ${info.kernelVersion}');
    buffer.writeln('System GUID: ${info.systemGUID ?? "N/A"}');
  } else if (info is LinuxDeviceInfo) {
    buffer.writeln('Platform: Linux');
    buffer.writeln('Name: ${info.name}');
    buffer.writeln('Pretty Name: ${info.prettyName}');
    buffer.writeln('Version: ${info.version ?? "N/A"}');
    buffer.writeln('ID: ${info.id}');
    buffer.writeln('Machine ID: ${info.machineId ?? "N/A"}');
  } else if (info is WindowsDeviceInfo) {
    buffer.writeln('Platform: Windows');
    buffer.writeln('Computer Name: ${info.computerName}');
    buffer.writeln('Product Name: ${info.productName}');
    buffer.writeln('Number Of Cores: ${info.numberOfCores}');
    buffer.writeln('System Memory: ${info.systemMemoryInMegabytes} MB');
    buffer.writeln('Build Number: ${info.buildNumber}');
    buffer.writeln('Device ID: ${info.deviceId}');
  } else if (info is WebBrowserInfo) {
    buffer.writeln('Platform: Web');
    buffer.writeln('Browser: ${info.browserName.name}');
    buffer.writeln('User Agent: ${info.userAgent ?? "N/A"}');
    buffer.writeln('App Name: ${info.appName}');
    buffer.writeln('Platform: ${info.platform ?? "N/A"}');
    buffer.writeln('Language: ${info.language ?? "N/A"}');
    buffer.writeln('Hardware Concurrency: ${info.hardwareConcurrency}');
  } else {
    for (final entry in info.data.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
  }

  return buffer.toString();
}

// ── Shared widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
