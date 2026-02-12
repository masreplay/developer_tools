import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';

import 'auth_overview_tool_entry.dart';
import 'available_biometrics_tool_entry.dart';
import 'copy_auth_status_tool_entry.dart';
import 'test_authenticate_tool_entry.dart';

/// Local Auth integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// ```dart
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: const [DeveloperToolsLocalAuth()],
///   ),
/// );
/// ```
class DeveloperToolsLocalAuth extends DeveloperToolsExtension {
  /// Creates a Local Auth developer tools extension.
  const DeveloperToolsLocalAuth({
    super.key,
    super.packageName = 'local_auth',
    super.displayName = 'Local Auth',
  });

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      authOverviewToolEntry(sectionLabel: sectionLabel),
      availableBiometricsToolEntry(sectionLabel: sectionLabel),
      testAuthenticateToolEntry(sectionLabel: sectionLabel),
      copyAuthStatusToolEntry(sectionLabel: sectionLabel),
    ];
  }

  @override
  Future<String?> debugInfo(BuildContext context) async {
    final buffer = StringBuffer();
    try {
      final auth = LocalAuthentication();
      final isSupported = await auth.isDeviceSupported();
      buffer.writeln('Device Supported: $isSupported');
    } catch (e) {
      buffer.writeln('Device Supported: error ($e)');
    }
    try {
      final auth = LocalAuthentication();
      final canCheck = await auth.canCheckBiometrics;
      buffer.writeln('Biometric Hardware: $canCheck');
    } catch (e) {
      buffer.writeln('Biometric Hardware: error ($e)');
    }
    try {
      final auth = LocalAuthentication();
      final biometrics = await auth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        buffer.writeln('Enrolled Biometrics: (none)');
      } else {
        buffer.writeln(
          'Enrolled Biometrics: ${biometrics.map(_biometricLabel).join(", ")}',
        );
      }
    } catch (e) {
      buffer.writeln('Enrolled Biometrics: error ($e)');
    }
    return buffer.toString();
  }

  static String _biometricLabel(BiometricType type) {
    return switch (type) {
      BiometricType.face => 'Face',
      BiometricType.fingerprint => 'Fingerprint',
      BiometricType.weak => 'Weak',
      BiometricType.strong => 'Strong',
      _ => type.name,
    };
  }
}
