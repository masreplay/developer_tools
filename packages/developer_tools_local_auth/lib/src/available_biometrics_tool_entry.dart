import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// A [DeveloperToolEntry] that shows a detailed list of all biometric types
/// currently enrolled on the device.
///
/// Each biometric type is shown with its icon, human-readable name, enum value,
/// and a brief description of what it represents. Useful for verifying which
/// biometric methods are available for authentication on the current device.
DeveloperToolEntry availableBiometricsToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Available Biometrics',
    sectionLabel: sectionLabel,
    description: 'View detailed list of enrolled biometric types',
    icon: Icons.security,
    debugInfo: (BuildContext context) async {
      try {
        final auth = LocalAuthentication();
        final biometrics = await auth.getAvailableBiometrics();
        if (biometrics.isEmpty) return 'No biometrics enrolled.';
        return 'Enrolled: ${biometrics.map((b) => b.name).join(", ")}';
      } catch (e) {
        return 'Error checking biometrics: $e';
      }
    },
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _AvailableBiometricsDialog();
        },
      );
    },
  );
}

class _AvailableBiometricsDialog extends StatefulWidget {
  const _AvailableBiometricsDialog();

  @override
  State<_AvailableBiometricsDialog> createState() =>
      _AvailableBiometricsDialogState();
}

class _AvailableBiometricsDialogState
    extends State<_AvailableBiometricsDialog> {
  late Future<List<BiometricType>> _biometricsFuture;

  @override
  void initState() {
    super.initState();
    _biometricsFuture = LocalAuthentication().getAvailableBiometrics();
  }

  void _refresh() {
    setState(() {
      _biometricsFuture = LocalAuthentication().getAvailableBiometrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.security, size: 24),
          SizedBox(width: 8),
          Text('Available Biometrics'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: FutureBuilder<List<BiometricType>>(
          future: _biometricsFuture,
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
                    'Error loading biometrics:\n${snapshot.error}',
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
          onPressed: () async {
            try {
              final biometrics = await _biometricsFuture;
              final text =
                  biometrics.isEmpty
                      ? 'No biometrics enrolled.'
                      : biometrics
                          .map((b) => '${_biometricLabel(b)} (${b.name})')
                          .join('\n');
              await Clipboard.setData(
                ClipboardData(text: 'Enrolled Biometrics:\n$text'),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biometrics info copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (_) {}
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy'),
        ),
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

  Widget _buildContent(BuildContext context, List<BiometricType> biometrics) {
    final theme = Theme.of(context);

    if (biometrics.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.no_encryption, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'No Biometrics Enrolled',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This device has no biometric methods enrolled.\n'
            'The user may need to set up fingerprint or face\n'
            'recognition in the device settings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withAlpha(50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${biometrics.length} biometric type${biometrics.length == 1 ? '' : 's'} enrolled',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Biometric list
        ...biometrics.map(
          (type) => _BiometricTile(type: type),
        ),
      ],
    );
  }
}

class _BiometricTile extends StatelessWidget {
  const _BiometricTile({required this.type});

  final BiometricType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _biometricIcon(type),
            size: 28,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _biometricLabel(type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  'BiometricType.${type.name}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _biometricDescription(type),
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

String _biometricLabel(BiometricType type) {
  return switch (type) {
    BiometricType.face => 'Face Recognition',
    BiometricType.fingerprint => 'Fingerprint',
    BiometricType.weak => 'Weak Biometric',
    BiometricType.strong => 'Strong Biometric',
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

String _biometricDescription(BiometricType type) {
  return switch (type) {
    BiometricType.face => 'Face ID or face-based authentication',
    BiometricType.fingerprint => 'Touch ID or fingerprint scanner',
    BiometricType.weak => 'Biometric that does not meet strong classification',
    BiometricType.strong =>
      'Biometric that meets strong classification (e.g. Class 3 Android)',
    _ => 'Platform-specific biometric type',
  };
}
