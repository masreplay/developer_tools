import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// A [DeveloperToolEntry] that copies all local authentication status
/// information to the clipboard as formatted text.
///
/// Includes device support, biometric hardware availability, and enrolled
/// biometric types. Useful for quick bug reports and sharing device
/// authentication capabilities with team members.
DeveloperToolEntry copyAuthStatusToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Copy Auth Status',
    sectionLabel: sectionLabel,
    description: 'Copy device auth capabilities to clipboard',
    icon: Icons.copy_all,
    debugInfo: (BuildContext context) async {
      try {
        return await _buildAuthReport();
      } catch (e) {
        return 'Error reading auth status: $e';
      }
    },
    onTap: (BuildContext context) async {
      try {
        final report = await _buildAuthReport();
        await Clipboard.setData(ClipboardData(text: report));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Auth status copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to copy auth status: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    },
  );
}

Future<String> _buildAuthReport() async {
  final auth = LocalAuthentication();
  final isSupported = await auth.isDeviceSupported();
  final canCheck = await auth.canCheckBiometrics;
  final biometrics = await auth.getAvailableBiometrics();

  final buffer = StringBuffer();
  buffer.writeln('=== Local Auth Status ===');
  buffer.writeln('Device Supported: $isSupported');
  buffer.writeln('Biometric Hardware: $canCheck');
  buffer.writeln(
    'Can Authenticate: ${canCheck || isSupported}',
  );
  buffer.writeln(
    'Enrolled Biometrics: ${biometrics.isEmpty ? "(none)" : biometrics.length.toString()}',
  );
  if (biometrics.isNotEmpty) {
    for (final type in biometrics) {
      buffer.writeln('  - ${_biometricLabel(type)} (${type.name})');
    }
  }
  return buffer.toString();
}

String _biometricLabel(BiometricType type) {
  return switch (type) {
    BiometricType.face => 'Face Recognition',
    BiometricType.fingerprint => 'Fingerprint',
    BiometricType.weak => 'Weak Biometric',
    BiometricType.strong => 'Strong Biometric',
    _ => type.name,
  };
}
