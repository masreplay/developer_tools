import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// A [DeveloperToolEntry] that opens a dialog showing the full local
/// authentication status of the device.
///
/// Displays whether the device supports authentication at all, whether
/// biometric hardware is available, and which biometric types are currently
/// enrolled. Useful for quickly verifying auth-related capabilities during
/// development and QA.
DeveloperToolEntry authOverviewToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Auth Overview',
    sectionLabel: sectionLabel,
    description: 'View device support, biometric hardware, and enrolled types',
    icon: Icons.fingerprint,
    debugInfo: (BuildContext context) async {
      try {
        final auth = LocalAuthentication();
        final isSupported = await auth.isDeviceSupported();
        final canCheck = await auth.canCheckBiometrics;
        final biometrics = await auth.getAvailableBiometrics();

        final buffer = StringBuffer();
        buffer.writeln('Device Supported: $isSupported');
        buffer.writeln('Biometric Hardware: $canCheck');
        buffer.writeln(
          'Enrolled Biometrics: ${biometrics.isEmpty ? "(none)" : biometrics.map(_biometricLabel).join(", ")}',
        );
        return buffer.toString();
      } catch (e) {
        return 'Error checking auth status: $e';
      }
    },
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _AuthOverviewDialog();
        },
      );
    },
  );
}

String _biometricLabel(BiometricType type) {
  return switch (type) {
    BiometricType.face => 'Face',
    BiometricType.fingerprint => 'Fingerprint',
    BiometricType.weak => 'Weak',
    BiometricType.strong => 'Strong',
    _ => type.name,
  };
}

IconData _biometricIcon(BiometricType type) {
  return switch (type) {
    BiometricType.face => Icons.face,
    BiometricType.fingerprint => Icons.fingerprint,
    BiometricType.weak => Icons.lock_outline,
    BiometricType.strong => Icons.verified_user,
    _ => Icons.security,
  };
}

class _AuthOverviewDialog extends StatefulWidget {
  const _AuthOverviewDialog();

  @override
  State<_AuthOverviewDialog> createState() => _AuthOverviewDialogState();
}

class _AuthOverviewDialogState extends State<_AuthOverviewDialog> {
  late Future<_AuthStatus> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _loadStatus();
  }

  Future<_AuthStatus> _loadStatus() async {
    final auth = LocalAuthentication();
    final isSupported = await auth.isDeviceSupported();
    final canCheck = await auth.canCheckBiometrics;
    final biometrics = await auth.getAvailableBiometrics();
    return _AuthStatus(
      isDeviceSupported: isSupported,
      canCheckBiometrics: canCheck,
      availableBiometrics: biometrics,
    );
  }

  void _refresh() {
    setState(() {
      _statusFuture = _loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.fingerprint, size: 24),
          SizedBox(width: 8),
          Text('Auth Overview'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: FutureBuilder<_AuthStatus>(
          future: _statusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'Error loading auth status:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return _buildContent(context, snapshot.data!);
          },
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: _refresh,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Refresh'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, _AuthStatus status) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withAlpha(40)),
          ),
          child: Column(
            children: [
              Icon(
                status.isDeviceSupported ? Icons.verified_user : Icons.gpp_bad,
                size: 40,
                color:
                    status.isDeviceSupported
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                status.isDeviceSupported
                    ? 'Device Supported'
                    : 'Device Not Supported',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status.canCheckBiometrics
                    ? 'Biometric hardware available'
                    : 'No biometric hardware detected',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Device capabilities
        _SectionHeader('Device Capabilities'),
        _StatusRow(
          'Device Supported',
          status.isDeviceSupported,
          'Can use pin, pattern, passcode, or biometrics',
        ),
        _StatusRow(
          'Biometric Hardware',
          status.canCheckBiometrics,
          'Has fingerprint reader, face scanner, etc.',
        ),
        const SizedBox(height: 12),

        // Enrolled biometrics
        _SectionHeader('Enrolled Biometrics'),
        if (status.availableBiometrics.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No biometrics enrolled on this device.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...status.availableBiometrics.map(
            (type) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _biometricIcon(type),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _biometricLabel(type),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SelectableText(
                    '(${type.name})',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AuthStatus {
  const _AuthStatus({
    required this.isDeviceSupported,
    required this.canCheckBiometrics,
    required this.availableBiometrics,
  });

  final bool isDeviceSupported;
  final bool canCheckBiometrics;
  final List<BiometricType> availableBiometrics;
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

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.label, this.value, this.subtitle);

  final String label;
  final bool value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: value ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
